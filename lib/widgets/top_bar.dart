import 'dart:io';
import 'dart:math';

import 'package:editicert/logic/global_state_service.dart';
import 'package:editicert/logic/services.dart';
import 'package:editicert/logic/tool_service.dart';
import 'package:editicert/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

class TopBar extends StatelessWidget with GetItMixin {
  TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tool = watchX((Tool tool) => tool.tool);
    final transformationController = watchX((
      TransformationControllerData data,
    ) =>
        data.state);

    return Container(
      height: topbarHeight,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(.375),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: 8 +
            (Platform.isMacOS &&
                    !globalStateNotifier.state.value.states
                        .contains(GlobalStates.fullscreen)
                ? 80
                : 0),
        right: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...[
            (
              text: 'Move',
              shortcut: 'V',
              tool: ToolType.move,
              onTap: () {
                toolNotifier.setMove();
              },
              icon: Transform.rotate(
                angle: -pi / 5,
                alignment: const Alignment(-0.2, 0.3),
                child: const Icon(
                  Icons.navigation_outlined,
                  size: 18,
                ),
              )
            ),
            (
              text: 'Frame',
              shortcut: 'F',
              tool: ToolType.frame,
              onTap: () {
                toolNotifier.setFrame();
              },
              icon: const Icon(
                CupertinoIcons.grid,
                size: 18,
              )
            ),
            (
              text: 'Rectangle',
              shortcut: 'R',
              tool: ToolType.rectangle,
              onTap: () {
                toolNotifier.setRectangle();
              },
              icon: const Icon(
                CupertinoIcons.square,
                size: 18,
              )
            ),
            (
              text: 'Hand',
              shortcut: 'H',
              tool: ToolType.hand,
              onTap: () {
                toolNotifier.setHand();
              },
              icon: const Icon(
                CupertinoIcons.hand_raised,
                size: 18,
              )
            ),
            (
              text: 'Text',
              shortcut: 'T',
              tool: ToolType.text,
              onTap: () {
                toolNotifier.setText();
              },
              icon: const Icon(
                CupertinoIcons.textbox,
                size: 18,
              )
            ),
          ].map(
            (e) => Tooltip(
              richMessage: TextSpan(
                children: [
                  TextSpan(
                    text: '${e.text} ',
                  ),
                  TextSpan(
                    text: ' ${e.shortcut}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              child: Card(
                margin: EdgeInsets.zero,
                color: tool == e.tool
                    ? colorScheme.onSurface.withOpacity(.125)
                    : colorScheme.surface,
                elevation: 0,
                clipBehavior: Clip.hardEdge,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: InkWell(
                  onTap: e.onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(17.0),
                    child: e.icon,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            onPressed: () {
              transformationController.value = Matrix4.identity().scaled(
                transformationController.value.getMaxScaleOnAxis(),
                transformationController.value.getMaxScaleOnAxis(),
              );
            },
            icon: const Icon(
              Icons.navigation_rounded,
              size: 16,
            ),
            label: const Text('Recenter'),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder(
            valueListenable: transformationController,
            builder: (context, value, child) {
              return Text(
                '${(value.getMaxScaleOnAxis() * 100).truncate()}%',
              );
            },
          ),
        ],
      ),
    );
  }
}
