// part of '../main.dart';

// class RightSidebar extends StatefulWidget {
//   const RightSidebar({required this.toggleColorPicker, super.key});

//   final VoidCallback toggleColorPicker;

//   @override
//   State<RightSidebar> createState() => _RightSidebarState();
// }

// class _RightSidebarState extends State<RightSidebar> {
//   late final TextEditingController backgroundColorController;
//   late final TextEditingController backgroundWidthController;
//   late final TextEditingController backgroundHeightController;
//   final flipToggle = [false, false];

//   @override
//   void initState() {
//     super.initState();
//     final canvasData = context.canvasCubit.state;
//     backgroundColorController = TextEditingController(
//       text: canvasData.color
//           .toColor()
//           .value
//           .toRadixString(16)
//           .toUpperCase()
//           .substring(2),
//     );
//     backgroundWidthController = TextEditingController(
//       text: canvasData.size.x.toString(),
//     );
//     backgroundHeightController = TextEditingController(
//       text: canvasData.size.y.toString(),
//     );
//   }

//   @override
//   void dispose() {
//     backgroundColorController.dispose();
//     backgroundWidthController.dispose();
//     backgroundHeightController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final selected = context.selectedCubitWatch.state;
//     final canvasStateProvider = context.canvasCubitWatch.state;
//     final component = selected.firstOrNull == null
//         ? null
//         // ignore: avoid-unsafe-collection-methods
//         : context
//             .componentsCubitWatch
//             .state[
//                 // ignore: avoid-unsafe-collection-methods
//                 selected.first]
//             .transform;
//     final textTheme = Theme.of(context).textTheme;

//     final controls = component == null
//         ? null
//         : [
//             _InputGroup(
//               children: [
//                 _InputItem(
//                   tooltip: 'X-coordinate of the\n'
//                       'top-left edge of\n'
//                       'the component,\n'
//                       'relative to the canvas\n'
//                       'origin (top left)',
//                   prefix: Text(
//                     'X',
//                     style: textTheme.bodySmall,
//                     textAlign: TextAlign.center,
//                   ),
//                   keyboardType: TextInputType.number,
//                   controller: TextEditingController(
//                     text: component.pos.dx.toStringAsFixed(1),
//                   ),
//                 ),
//                 _InputItem(
//                   tooltip: 'Y-coordinate of the\n'
//                       'top-left edge of\n'
//                       'the component,\n'
//                       'relative to the canvas\n'
//                       'origin (top left)',
//                   prefix: Text(
//                     'Y',
//                     style: textTheme.bodySmall,
//                     textAlign: TextAlign.center,
//                   ),
//                   keyboardType: TextInputType.number,
//                   controller: TextEditingController(
//                     text: component.pos.dy.toStringAsFixed(1),
//                   ),
//                 ),
//               ],
//             ),
//             _InputGroup(
//               children: [
//                 _InputItem(
//                   tooltip: 'Width of the component',
//                   prefix: Text(
//                     'W',
//                     style: textTheme.bodySmall,
//                     textAlign: TextAlign.center,
//                   ),
//                   keyboardType: TextInputType.number,
//                   controller: TextEditingController(
//                     text: component.size.width.toStringAsFixed(1),
//                   ),
//                 ),
//                 _InputItem(
//                   tooltip: 'Height of the component',
//                   prefix: Text(
//                     'H',
//                     style: textTheme.bodySmall,
//                     textAlign: TextAlign.center,
//                   ),
//                   keyboardType: TextInputType.number,
//                   controller: TextEditingController(
//                     text: component.size.height.toStringAsFixed(1),
//                   ),
//                 ),
//               ],
//             ),
//             _InputGroup(
//               children: [
//                 _InputItem(
//                   tooltip: 'Rotation angle of the component',
//                   prefix: Transform.translate(
//                     offset: const Offset(-1, -1),
//                     child: const Icon(size: 14, CupertinoIcons.rotate_right),
//                   ),
//                   keyboardType: TextInputType.number,
//                   controller: TextEditingController(
//                     text:
//                         '${((component.angle % (pi * 2)) / pi * 180).toStringAsFixed(1)}°',
//                   ),
//                 ),
//                 _InputItem(
//                   tooltip: 'Corner radii of the component',
//                   prefix: Transform.translate(
//                     offset: const Offset(0, 1),
//                     child: const Icon(
//                       Icons.rounded_corner_rounded,
//                       size: 12,
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   controller: TextEditingController(text: '0'),
//                 ),
//               ],
//             ),
//             _InputGroup(
//               isSelected: [component.flipX, component.flipY],
//               onPressed: (index) {
//                 final center = component.rect.center;
//                 final angle = component.angle;

//                 final isFlipX = index == 0;
//                 final isFlipY = index == 1;

//                 final width =
//                     isFlipX ? -component.rect.width : component.rect.width;
//                 final height =
//                     isFlipY ? -component.rect.height : component.rect.height;

//                 final newRect = Rect.fromCenter(
//                   center: center,
//                   width: width,
//                   height: height,
//                 );

//                 final newComponent = ComponentTransform(
//                   newRect.topLeft,
//                   newRect.size,
//                   angle,
//                   width < 0,
//                   height < 0,
//                 );

//                 setState(() {
//                   context.componentsCubit.replace(
//                     // ignore: avoid-unsafe-collection-methods
//                     selected.first,
//                     context
//                         .componentAt(index)
//                         .copyWith(transform: newComponent),
//                   );
//                   // ignore: avoid-unsafe-collection-methods
//                   final currentSelected = selected.first;
//                   context.selectedCubit.replaceAll({currentSelected});
//                 });
//               },
//               children: [
//                 _InputItem(
//                   tooltip: 'Is the component\nflipped horizontally',
//                   prefix: Transform.translate(
//                     offset: const Offset(1, 1),
//                     child: const Icon(size: 14, Icons.flip),
//                   ),
//                   suffix: const Text('Horizontal'),
//                 ),
//                 _InputItem(
//                   tooltip: 'Is the component\nflipped vertically',
//                   prefix: Transform.translate(
//                     offset: const Offset(0, 1),
//                     child: Transform.rotate(
//                       angle: pi / 2,
//                       child: const Icon(size: 14, Icons.flip),
//                     ),
//                   ),
//                   suffix: const Text('Vertical'),
//                 ),
//               ],
//             ),
//           ];

//     final backgroundControl = SizedBox(
//       height: 16,
//       child: Row(
//         children: [
//           SizedBox(
//             width: kGextFieldWidth,
//             child: Row(
//               children: [
//                 Container(
//                   width: 16,
//                   height: 16,
//                   margin: const EdgeInsets.only(right: 6),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(2),
//                     border: Border.all(color: Colors.white, width: .5),
//                     color: canvasStateProvider.color.toColor(),
//                   ),
//                   child: InkWell(
//                     onTap: widget.toggleColorPicker,
//                     child: const SizedBox.shrink(),
//                   ),
//                 ),
//                 Expanded(
//                   child: TextField(
//                     maxLength: 6,
//                     onChanged: (value) => context.canvasCubit.update(
//                       backgroundColor: value.toColor,
//                     ),
//                     controller: backgroundColorController,
//                     style: textTheme.bodySmall,
//                     decoration: const InputDecoration(
//                       hintText: '',
//                       counter: SizedBox.shrink(),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.only(top: 32),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: Text(
//               '${(canvasStateProvider.color.toColor().opacity * 100).truncate()}%',
//               style: textTheme.bodySmall,
//             ),
//           ),
//           Expanded(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   hoverColor: Colors.transparent,
//                   splashColor: Colors.transparent,
//                   focusColor: Colors.transparent,
//                   highlightColor: Colors.transparent,
//                   padding: EdgeInsets.zero,
//                   constraints:
//                       BoxConstraints.tight(const Size(18, double.infinity)),
//                   onPressed: () => context.canvasCubit.update(
//                     backgroundHidden: !canvasStateProvider.hidden,
//                   ),
//                   icon: Icon(
//                     canvasStateProvider.hidden
//                         ? CupertinoIcons.eye_slash
//                         : CupertinoIcons.eye,
//                     size: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );

//     final canvasSizeControlData = [
//       (
//         children: [
//           (
//             prefix: Text(
//               'W',
//               style: textTheme.bodySmall,
//               textAlign: TextAlign.center,
//             ),
//             keyboardType: TextInputType.number,
//             controller: backgroundWidthController,
//             onChanged: (String text) {
//               print('test');
//               print(canvasStateProvider.size);
//               context.canvasCubit.update(
//                 backgroundSize: Size(
//                   double.parse(text),
//                   canvasStateProvider.size.y,
//                 ),
//               );
//               print(canvasStateProvider.size);
//             },
//           ),
//           (
//             prefix: Text(
//               'H',
//               style: textTheme.bodySmall,
//               textAlign: TextAlign.center,
//             ),
//             keyboardType: TextInputType.number,
//             controller: backgroundHeightController,
//             onChanged: (String text) => context.canvasCubit.update(
//                   backgroundSize: Size(
//                     canvasStateProvider.size.x,
//                     double.parse(text),
//                   ),
//                 ),
//           ),
//         ],
//       ),
//     ];

//     final canvasSizeControl = canvasSizeControlData.map(
//       (control) => Padding(
//         padding: sidebarPaddingHorizontal,
//         child: SizedBox(
//           height: 32,
//           child: Row(
//             children: [
//               ...control.children.map(
//                 (controlInner) => SizedBox(
//                   width: kGextFieldWidth,
//                   child: Row(
//                     children: [
//                       // w: 24
//                       Container(
//                         width: 16,
//                         height: 16,
//                         margin: const EdgeInsets.only(right: 6),
//                         child: controlInner.prefix,
//                       ),
//                       // w: 72
//                       Expanded(
//                         child: TextField(
//                           onChanged: controlInner.onChanged,
//                           cursorHeight: 12,
//                           style: textTheme.bodySmall,
//                           decoration: const InputDecoration.collapsed(
//                             hintText: '',
//                           ),
//                           keyboardType: controlInner.keyboardType,
//                           controller: controlInner.controller,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     return Container(
//       width: kSidebarWidth,
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//       ),
//       child: ListView(
//         children: [
//           ...[
//             (
//               title: Text('Background', style: textTheme.labelMedium),
//               contents: [
//                 Padding(
//                   padding: sidebarPaddingHorizontal,
//                   child: backgroundControl,
//                 ),
//                 const SizedBox(height: 8),
//                 ...canvasSizeControl,
//               ],
//             ),
//             if (component != null)
//               (
//                 title: Text('Component', style: textTheme.labelMedium),
//                 contents: [
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       left: sidebarPaddingSize - sidebarPaddingStep,
//                       right: 16,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ...?controls?.mapIndexed(
//                           (i, outerContent) => Padding(
//                             padding: EdgeInsets.only(
//                               bottom: i == controls.length - 1 ? 0 : 8.0,
//                             ),
//                             child: SizedBox(
//                               height: 24,
//                               child: ToggleButtons(
//                                 isSelected:
//                                     outerContent.isSelected ?? [true, true],
//                                 onPressed: outerContent.onPressed,
//                                 disabledBorderColor: Colors.transparent,
//                                 // borderColor: Colors.transparent,
//                                 borderWidth: 0,
//                                 // color: Colors.transparent,
//                                 // fillColor: Colors.transparent,
//                                 disabledColor: Colors.white,
//                                 textStyle: textTheme.bodySmall,
//                                 children: [
//                                   ...outerContent.children.mapIndexed(
//                                     (index, innerContent) => Padding(
//                                       padding: index == 0
//                                           ? const EdgeInsets.only(
//                                               left: sidebarPaddingStep,
//                                             )
//                                           : i == 3
//                                               ? const EdgeInsets.only(
//                                                   left: sidebarPaddingStep,
//                                                 )
//                                               : EdgeInsets.zero,
//                                       child: Tooltip(
//                                         waitDuration:
//                                             const Duration(milliseconds: 1500),
//                                         message: innerContent.tooltip,
//                                         child: SizedBox(
//                                           width: kGextFieldWidth -
//                                               (i == 3 && index == 0 ? 4 : 0),
//                                           child: Row(
//                                             children: [
//                                               // w: 24
//                                               Container(
//                                                 width: 16,
//                                                 height: 16,
//                                                 margin: const EdgeInsets.only(
//                                                   right: 6,
//                                                 ),
//                                                 child: innerContent.prefix,
//                                               ),
//                                               // w: 72
//                                               if (innerContent.controller !=
//                                                   null)
//                                                 Expanded(
//                                                   child: TextField(
//                                                     cursorHeight: 12,
//                                                     style: textTheme.bodySmall,
//                                                     decoration:
//                                                         const InputDecoration
//                                                             .collapsed(
//                                                       hintText: '',
//                                                     ),
//                                                     keyboardType: innerContent
//                                                         .keyboardType,
//                                                     controller:
//                                                         innerContent.controller,
//                                                   ),
//                                                 ),
//                                               if (innerContent.suffix != null)
//                                                 innerContent.suffix!,
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//           ].map((content) {
//             final title = content.title;
//             return Container(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(color: Colors.grey.withOpacity(.5)),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: sidebarPaddingHorizontal,
//                     child: SizedBox(height: 32, child: title),
//                   ),
//                   ...content.contents.map((content2) => content2),
//                 ],
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }

// class _InputItem {
//   const _InputItem({
//     required this.tooltip,
//     required this.prefix,
//     this.suffix,
//     this.keyboardType,
//     this.controller,
//   });

//   final String tooltip;
//   final Widget prefix;
//   final Widget? suffix;
//   final TextInputType? keyboardType;
//   final TextEditingController? controller;
// }

// class _InputGroup {
//   const _InputGroup({
//     required this.children,
//     this.isSelected,
//     this.onPressed,
//   });

//   final List<_InputItem> children;
//   final List<bool>? isSelected;
//   final void Function(int index)? onPressed;
// }
