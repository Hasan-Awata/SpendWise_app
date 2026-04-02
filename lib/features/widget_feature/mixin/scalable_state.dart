import 'package:flutter/material.dart';

mixin ScalableState<T extends StatefulWidget> on State<T> {
  double scale = 1.0;

  void updateScale(double value) {
    if (scale != value) {
      setState(() {
        scale = value;
      });
    }
  }

  Widget wrapWithScale({required Widget child, double scaleFactor = 1.05}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => updateScale(scaleFactor),
      onTapUp: (_) => updateScale(1.0),
      onTapCancel: () => updateScale(1.0),
      child: MouseRegion(
        onEnter: (_) => updateScale(scaleFactor),
        onExit: (_) => updateScale(1.0),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: child,
        ),
      ),
    );
  }
}
