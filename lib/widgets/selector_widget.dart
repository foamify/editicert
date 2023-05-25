import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Marquee
class SelectorWidget extends ConsumerStatefulWidget {
  const SelectorWidget({super.key});

  @override
  ConsumerState<SelectorWidget> createState() => _SelectorWidgetState();
}

class _SelectorWidgetState extends ConsumerState<SelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      child: Stack(
        children: [],
      ),
    );
  }
}
