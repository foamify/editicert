import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:editicert/models/component_transform.dart';
import 'package:editicert/models/component_data.dart';
import 'package:editicert/models/component_type.dart';
import 'package:editicert/state/canvas_cubit.dart';
import 'package:editicert/state/component_index_cubit.dart';
import 'package:editicert/state/components_cubit.dart';
import 'package:editicert/state/state.dart';
import 'package:editicert/util/constants.dart';
import 'package:editicert/util/extensions.dart';
import 'package:editicert/util/get_it.dart';
import 'package:editicert/util/utils.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_window_utils/macos/ns_window_delegate.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:window_manager/window_manager.dart';

part 'widgets/canvas.dart';

part 'widgets/controller_widget.dart';

part 'widgets/creator_widget.dart';

part 'widgets/selector_widget.dart';

part 'widgets/left_sidebar.dart';

part 'widgets/right_sidebar.dart';

part 'widgets/top_bar.dart';

part 'widgets/home_page.dart';

part 'widgets/custom_cursor_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await windowManager.ensureInitialized();
  }

  if (!kIsWeb) {
    if (Platform.isMacOS) {
      await WindowManipulator.initialize(enableWindowDelegate: true);
      final delegate = _MyDelegate();
      WindowManipulator.addNSWindowDelegate(delegate);
      final options = NSAppPresentationOptions.from({
        NSAppPresentationOption.fullScreen,
        NSAppPresentationOption.autoHideToolbar,
        NSAppPresentationOption.autoHideMenuBar,
        NSAppPresentationOption.autoHideDock,
      });

      options.applyAsFullScreenPresentationOptions();

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

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SelectedCubit(),
        ),
        BlocProvider(
          create: (_) => HoveredCubit(),
        ),
        BlocProvider(
          create: (_) => ComponentIndexCubit(),
        ),
        BlocProvider(
          create: (_) => CanvasCubit(),
        ),
        BlocProvider(
          create: (_) => ComponentsCubit([]),
        ),
      ],
      child: Main(),
    ),
  );
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

class Main extends StatelessWidget {
  Main({super.key});

  @override
  Widget build(BuildContext context) {
    final isSelectedEmpty =
        context.select((SelectedCubit selected) => selected.state.isEmpty);

    return PlatformMenuBar(
      menus: kIsWeb || !Platform.isMacOS
          ? []
          : [
              const PlatformMenu(
                label: 'Application',
                menus: [
                  PlatformMenuItemGroup(members: [
                    PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.about,
                    ),
                  ]),
                  PlatformMenuItemGroup(members: [
                    PlatformMenuItem(label: 'Preferences'),
                  ]),
                  PlatformMenuItemGroup(members: [
                    PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.minimizeWindow,
                    ),
                    PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.zoomWindow,
                    ),
                    PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.hide,
                    ),
                    PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.hideOtherApplications,
                    ),
                    PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.toggleFullScreen,
                    ),
                    PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.quit,
                    ),
                  ]),
                ],
              ),
              const PlatformMenu(
                label: 'File',
                menus: [
                  PlatformMenuItem(
                    label: 'New Project',
                    shortcut:
                        SingleActivator(LogicalKeyboardKey.keyN, meta: true),
                  ),
                  PlatformMenuItem(
                    label: 'Open Project',
                    shortcut:
                        SingleActivator(LogicalKeyboardKey.keyO, meta: true),
                  ),
                  PlatformMenuItem(
                    label: 'Save',
                    shortcut:
                        SingleActivator(LogicalKeyboardKey.keyS, meta: true),
                  ),
                  PlatformMenuItem(
                    label: 'Save As',
                    shortcut: SingleActivator(
                      LogicalKeyboardKey.keyS,
                      meta: true,
                      shift: true,
                    ),
                  ),
                  PlatformMenuItem(
                    label: 'Close Project',
                    shortcut:
                        SingleActivator(LogicalKeyboardKey.keyW, meta: true),
                  ),
                ],
              ),
              const PlatformMenu(label: 'Assets', menus: [
                PlatformMenu(label: 'Import', menus: [
                  PlatformMenuItem(label: 'File'),
                ]),
              ]),
              PlatformMenu(
                label: 'Tools',
                menus: [
                  PlatformMenuItem(
                    label: 'Move',
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyV),
                    onSelected: () => context.read<ToolCubit>().setMove(),
                  ),
                  PlatformMenuItem(
                    label: 'Frame',
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyF),
                    onSelected: () => context.read<ToolCubit>().setFrame(),
                  ),
                  PlatformMenuItem(
                    label: 'Rectangle',
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyR),
                    onSelected: () => context.read<ToolCubit>().setRectangle(),
                  ),
                  PlatformMenuItem(
                    label: 'Hand',
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyH),
                    onSelected: () => context.read<ToolCubit>().setHand(),
                  ),
                  PlatformMenuItem(
                    label: 'Text',
                    shortcut: const SingleActivator(LogicalKeyboardKey.keyT),
                    onSelected: () => context.read<ToolCubit>().setText(),
                  ),
                ],
              ),
              PlatformMenu(
                label: 'Shortcuts',
                menus: [
                  PlatformMenuItem(
                    label: 'Remove Selected',
                    shortcut: Platform.isMacOS
                        ? const SingleActivator(LogicalKeyboardKey.backspace)
                        : const SingleActivator(LogicalKeyboardKey.delete),
                    onSelected: isSelectedEmpty
                        ? null
                        : context.deleteSelectedComponent,
                  ),
                  PlatformMenuItem(
                    label: 'Bring Backward',
                    shortcut:
                        const SingleActivator(LogicalKeyboardKey.bracketLeft),
                    onSelected:
                        isSelectedEmpty ? null : context.handleGoBackward,
                  ),
                  PlatformMenuItem(
                    label: 'Bring Forward',
                    shortcut:
                        const SingleActivator(LogicalKeyboardKey.bracketRight),
                    onSelected:
                        isSelectedEmpty ? null : context.handleGoForward,
                  ),
                ],
              ),
            ],
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
        home: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => CanvasEventsCubit()),
            BlocProvider(create: (_) => CanvasTransformCubit()),
            BlocProvider(create: (_) => KeysCubit()),
            BlocProvider(create: (_) => PointerCubit(Offset.zero)),
            BlocProvider(create: (_) => ToolCubit(ToolType.move)),
            //
            BlocProvider(create: (_) => DebugPointCubit()),
          ],
          child: HomePage(),
        ),
      ),
    );
  }
}
