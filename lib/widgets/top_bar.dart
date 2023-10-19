part of '../main.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tool = context.watch<ToolCubit>().state;
    final transformationController =
        context.watch<CanvasTransformCubit>().state;
    final canvasEvents = context.watch<CanvasEventsCubit>();

    return Container(
      height: kTopbarHeight,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(.375)),
        ),
      ),
      padding: EdgeInsets.only(
        left: 8 +
            (!kIsWeb &&
                    Platform.isMacOS &&
                    !canvasEvents.state.contains(CanvasEvent.fullscreen)
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
                context.read<ToolCubit>().setMove();
              },
              icon: Transform.rotate(
                angle: -pi / 5,
                alignment: const Alignment(-0.2, 0.3),
                child: const Icon(Icons.navigation_outlined, size: 20),
              ),
            ),
            (
              text: 'Frame',
              shortcut: 'F',
              tool: ToolType.frame,
              onTap: () {
                context.read<ToolCubit>().setFrame();
              },
              icon: const Icon(CupertinoIcons.grid, size: 20),
            ),
            (
              text: 'Rectangle',
              shortcut: 'R',
              tool: ToolType.rectangle,
              onTap: () {
                context.read<ToolCubit>().setRectangle();
              },
              icon: const Icon(CupertinoIcons.square, size: 20),
            ),
            (
              text: 'Hand',
              shortcut: 'H',
              tool: ToolType.hand,
              onTap: () {
                context.read<ToolCubit>().setHand();
              },
              icon: const Icon(CupertinoIcons.hand_raised, size: 20),
            ),
            (
              text: 'Text',
              shortcut: 'T',
              tool: ToolType.text,
              onTap: () {
                context.read<ToolCubit>().setText();
              },
              icon: const Icon(CupertinoIcons.textbox, size: 20),
            ),
          ].map(
            (e) => Tooltip(
              richMessage: TextSpan(
                children: [
                  TextSpan(text: '${e.text} '),
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
                    padding: const EdgeInsets.all(17),
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
            icon: const Icon(Icons.navigation_rounded, size: 16),
            label: const Text('Recenter'),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder(
            valueListenable: transformationController,
            builder: (_, value, child) {
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
