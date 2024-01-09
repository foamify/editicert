import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:editicert/models/element_model.dart';
import 'package:editicert/models/snap_line.dart';
import 'package:editicert/src/rust/frb_generated.dart';
import 'package:editicert/state/state.dart';
import 'package:editicert/util/constants.dart';
import 'package:editicert/util/element/translate.dart';
import 'package:editicert/util/extensions.dart';
import 'package:editicert/util/geometry.dart';
import 'package:editicert/widgets/canvas_interactive_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macos_window_utils/macos/ns_window_delegate.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:signals/signals_flutter.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:window_manager/window_manager.dart';

// part 'widgets/controller_widget.dart';
// part 'widgets/creator_widget.dart';
// part 'widgets/custom_cursor_widget.dart';
// part 'widgets/home_page.dart';
// part 'widgets/left_sidebar.dart';
part 'widgets/main_page.dart';
// part 'widgets/right_sidebar.dart';
// part 'widgets/top_bar.dart';
part 'widgets/canvas/marquee_widget.dart';
part 'widgets/canvas/marquee_paint.dart';
part 'widgets/canvas/snap_line_paint.dart';
part 'widgets/canvas/debug_points.dart';
part 'widgets/canvas/canvas_widget.dart';
part 'widgets/element/element_translator.dart';
part 'widgets/element/element_rotator.dart';
part 'widgets/element/element_side_resizer.dart';
part 'widgets/element/element_edge_resizer.dart';

void main() async {
  await RustLib.init();
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await windowManager.ensureInitialized();
  }

  if (!kIsWeb) {
    if (Platform.isMacOS) {
      await WindowManipulator.initialize(enableWindowDelegate: true);
      final delegate = _MyDelegate();
      WindowManipulator.addNSWindowDelegate(delegate);
      NSAppPresentationOptions.from({
        NSAppPresentationOption.fullScreen,
        NSAppPresentationOption.autoHideToolbar,
        NSAppPresentationOption.autoHideMenuBar,
        NSAppPresentationOption.autoHideDock,
      }).applyAsFullScreenPresentationOptions();

      await Future.wait([
        WindowManipulator.makeTitlebarTransparent(),
        WindowManipulator.enableFullSizeContentView(),
        WindowManipulator.hideTitle(),
        WindowManipulator.addToolbar(),
        WindowManipulator.setToolbarStyle(
          toolbarStyle: NSWindowToolbarStyle.unified,
        ),
      ]);
    }
  }

  runApp(const Main());
  if (!kIsWeb) {
    await windowManager.waitUntilReadyToShow();

    unawaited(windowManager.show());
    unawaited(windowManager.focus());
  }
}

class _MyDelegate extends NSWindowDelegate {
  @override
  void windowWillEnterFullScreen() {
    WindowManipulator.removeToolbar();
    super.windowDidEnterFullScreen();
  }

  @override
  void windowWillExitFullScreen() {
    WindowManipulator.addToolbar();
    super.windowWillExitFullScreen();
  }
}

// ignore: public_member_api_docs
class Main extends StatelessWidget {
  // ignore: public_member_api_docs
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    // final isSelectedEmpty =
    //     context.select((SelectedCubit selected) => selected.state.isEmpty);

    return PlatformMenuBar(
      menus: []
      // menus: kIsWeb || !Platform.isMacOS
      //     ? []
      //     : [
      //         const PlatformMenu(
      //           label: 'Application',
      //           menus: [
      //             PlatformMenuItemGroup(
      //               members: [
      //                 PlatformProvidedMenuItem(
      //                   type: PlatformProvidedMenuItemType.about,
      //                 ),
      //               ],
      //             ),
      //             PlatformMenuItemGroup(
      //               members: [PlatformMenuItem(label: 'Preferences')],
      //             ),
      //             PlatformMenuItemGroup(
      //               members: [
      //                 PlatformProvidedMenuItem(
      //                   type: PlatformProvidedMenuItemType.minimizeWindow,
      //                 ),
      //                 PlatformProvidedMenuItem(
      //                   type: PlatformProvidedMenuItemType.zoomWindow,
      //                 ),
      //                 PlatformProvidedMenuItem(
      //                   type: PlatformProvidedMenuItemType.hide,
      //                 ),
      //                 PlatformProvidedMenuItem(
      //                   type:
      //                       PlatformProvidedMenuItemType.hideOtherApplications,
      //                 ),
      //                 PlatformProvidedMenuItem(
      //                   type: PlatformProvidedMenuItemType.toggleFullScreen,
      //                 ),
      //                 PlatformProvidedMenuItem(
      //                   type: PlatformProvidedMenuItemType.quit,
      //                 ),
      //               ],
      //             ),
      //           ],
      //         ),
      //         const PlatformMenu(
      //           label: 'File',
      //           menus: [
      //             PlatformMenuItem(
      //               label: 'New Project',
      //               shortcut:
      //                   SingleActivator(LogicalKeyboardKey.keyN, meta: true),
      //             ),
      //             PlatformMenuItem(
      //               label: 'Open Project',
      //               shortcut:
      //                   SingleActivator(LogicalKeyboardKey.keyO, meta: true),
      //             ),
      //             PlatformMenuItem(
      //               label: 'Save',
      //               shortcut:
      //                   SingleActivator(LogicalKeyboardKey.keyS, meta: true),
      //             ),
      //             PlatformMenuItem(
      //               label: 'Save As',
      //               shortcut: SingleActivator(
      //                 LogicalKeyboardKey.keyS,
      //                 meta: true,
      //                 shift: true,
      //               ),
      //             ),
      //             PlatformMenuItem(
      //               label: 'Close Project',
      //               shortcut:
      //                   SingleActivator(LogicalKeyboardKey.keyW, meta: true),
      //             ),
      //           ],
      //         ),
      //         const PlatformMenu(
      //           label: 'Assets',
      //           menus: [
      //             PlatformMenu(
      //               label: 'Import',
      //               menus: [PlatformMenuItem(label: 'File')],
      //             ),
      //           ],
      //         ),
      //         PlatformMenu(
      //           label: 'Tools',
      //           menus: [
      //             PlatformMenuItem(
      //               label: 'Move',
      //               shortcut: const SingleActivator(LogicalKeyboardKey.keyV),
      //               onSelected: () => context.read<ToolCubit>().setMove(),
      //             ),
      //             PlatformMenuItem(
      //               label: 'Frame',
      //               shortcut: const SingleActivator(LogicalKeyboardKey.keyF),
      //               onSelected: () => context.read<ToolCubit>().setFrame(),
      //             ),
      //             PlatformMenuItem(
      //               label: 'Rectangle',
      //               shortcut: const SingleActivator(LogicalKeyboardKey.keyR),
      //               onSelected: () => context.read<ToolCubit>().setRectangle(),
      //             ),
      //             PlatformMenuItem(
      //               label: 'Hand',
      //               shortcut: const SingleActivator(LogicalKeyboardKey.keyH),
      //               onSelected: () => context.read<ToolCubit>().setHand(),
      //             ),
      //             PlatformMenuItem(
      //               label: 'Text',
      //               shortcut: const SingleActivator(LogicalKeyboardKey.keyT),
      //               onSelected: () => context.read<ToolCubit>().setText(),
      //             ),
      //           ],
      //         ),
      //         PlatformMenu(
      //           label: 'Shortcuts',
      //           menus: [
      //             PlatformMenuItem(
      //               label: 'Remove Selected',
      //               shortcut: Platform.isMacOS
      //                   ? const SingleActivator(LogicalKeyboardKey.backspace)
      //                   : const SingleActivator(LogicalKeyboardKey.delete),
      //               onSelected: isSelectedEmpty
      //                   ? null
      //                   : context.deleteSelectedComponent,
      //             ),
      //             PlatformMenuItem(
      //               label: 'Bring Backward',
      //               shortcut:
      //                   const SingleActivator(LogicalKeyboardKey.bracketLeft),
      //               onSelected:
      //                   isSelectedEmpty ? null : context.handleGoBackward,
      //             ),
      //             PlatformMenuItem(
      //               label: 'Bring Forward',
      //               shortcut:
      //                   const SingleActivator(LogicalKeyboardKey.bracketRight),
      //               onSelected:
      //                   isSelectedEmpty ? null : context.handleGoForward,
      //             ),
      //           ],
      //         ),
      //       ],
      ,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Editicert',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const MainPage(),
      ),
    );
  }
}
