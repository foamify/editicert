import 'package:collection/collection.dart';
import 'package:editicert/logic/component_index_service.dart';
import 'package:editicert/logic/component_service.dart';
import 'package:editicert/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class LeftSidebar extends StatefulWidget with GetItStatefulWidgetMixin {
  LeftSidebar({super.key});

  @override
  State<LeftSidebar> createState() => _LeftSidebarState();
}

class _LeftSidebarState extends State<LeftSidebar> with GetItStateMixin {
  @override
  Widget build(BuildContext context) {
    final components = watchX((Components components) => components.state);
    final selected = watchX((Selected selected) => selected.state);
    final hovered = watchX((Hovered hovered) => hovered.state);

    final mqSize = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: sidebarWidth,
      color: colorScheme.surface,
      child: ListView(
        children: components
            .mapIndexed(
              (i, e) => Container(
                padding: const EdgeInsets.only(right: 8),
                height: 32,
                decoration: BoxDecoration(
                  color:
                      selected.contains(i) ? colorScheme.surfaceVariant : null,
                  border: Border.all(
                    strokeAlign: BorderSide.strokeAlignInside,
                    color: !hovered.contains(i) || selected.contains(i)
                        ? Colors.transparent
                        : Colors.blueAccent.withOpacity(.5),
                  ),
                ),
                // color: Colors.transparent,
                child: MouseRegion(
                  onEnter: (event) => hoveredNotifier.add(i),
                  onExit: (event) => hoveredNotifier.remove(i),
                  child: InkWell(
                    onTap: () {
                      selectedNotifier
                        ..clear()
                        ..add(i);
                    },
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          child: Icon(
                            Icons.rectangle_outlined,
                            size: 12,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.name.replaceAll('\n', ' '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        if (hovered.contains(i))
                          SizedBox(
                            width: 18 * 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints.tight(
                                    Size(
                                      e.locked ? 14 : 18,
                                      double.infinity,
                                    ),
                                  ),
                                  onPressed: () => componentsNotifier.replace(
                                    i,
                                    locked: !e.locked,
                                  ),
                                  icon: Icon(
                                    e.locked
                                        ? CupertinoIcons.lock_fill
                                        : CupertinoIcons.lock_open_fill,
                                    size: 14,
                                  ),
                                ),
                                IconButton(
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints.tight(
                                    const Size(
                                      18,
                                      double.infinity,
                                    ),
                                  ),
                                  onPressed: () => componentsNotifier.replace(
                                    i,
                                    hidden: !e.hidden,
                                  ),
                                  icon: Icon(
                                    e.hidden
                                        ? CupertinoIcons.eye_slash
                                        : CupertinoIcons.eye,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // child: ListTile(
                  //   textColor: e.hidden ? Colors.grey : null,
                  //   iconColor: e.hidden ? Colors.grey : null,
                  //   onTap: () {
                  // selected
                  //       ..clear()
                  //       ..add(i);
                  //   },
                  //   hoverColor: Colors.transparent,
                  //   // selected: selected.contains(i),
                  //   horizontalTitleGap: 4,
                  //   title: Text(
                  //     e.name,
                  //     style: const TextStyle(fontSize: 12),
                  //   ),
                  //   leading: const Icon(
                  //     CupertinoIcons.square,
                  //     size: 16,
                  //   ),
                  //   contentPadding: const EdgeInsets.only(
                  //       left: 4, right: 6),
                  //   trailing: hovered.contains(i)
                  //       ? SizedBox(
                  //           width: 18 * 2,
                  //           child: Row(
                  //             mainAxisAlignment:
                  //                 MainAxisAlignment
                  //                     .spaceBetween,
                  //             children: [
                  //               IconButton(
                  //                 hoverColor:
                  //                     Colors.transparent,
                  //                 splashColor:
                  //                     Colors.transparent,
                  //                 focusColor:
                  //                     Colors.transparent,
                  //                 highlightColor:
                  //                     Colors.transparent,
                  //                 padding: EdgeInsets.zero,
                  //                 constraints: BoxConstraints
                  //                     .tight(Size(
                  //                         e.locked ? 14 : 18,
                  //                         double.infinity)),
                  //                 onPressed: () =>
                  //                     .read(componentsProvider
                  //                         .notifier)
                  //                     .replace(i,
                  //                         locked: !e.locked),
                  //                 icon: Icon(
                  //                   e.locked
                  //                       ? CupertinoIcons
                  //                           .lock_fill
                  //                       : CupertinoIcons
                  //                           .lock_open_fill,
                  //                   size: 14,
                  //                 ),
                  //               ),
                  //               IconButton(
                  //                 hoverColor:
                  //                     Colors.transparent,
                  //                 splashColor:
                  //                     Colors.transparent,
                  //                 focusColor:
                  //                     Colors.transparent,
                  //                 highlightColor:
                  //                     Colors.transparent,
                  //                 padding: EdgeInsets.zero,
                  //                 constraints:
                  //                     BoxConstraints.tight(
                  //                         const Size(
                  //                             18,
                  //                             double
                  //                                 .infinity)),
                  //                 onPressed: () =>
                  //                     .read(componentsProvider
                  //                         .notifier)
                  //                     .replace(i,
                  //                         hidden: !e.hidden),
                  //                 icon: Icon(
                  //                   e.hidden
                  //                       ? CupertinoIcons
                  //                           .eye_slash
                  //                       : CupertinoIcons.eye,
                  //                   size: 14,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         )
                  //       : null,
                  // ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}