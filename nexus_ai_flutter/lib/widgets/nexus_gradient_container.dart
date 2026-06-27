import 'package:flutter/material.dart';

class NexusGradientContainer extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final double height;
  final EdgeInsets padding;

  const NexusGradientContainer({
    super.key,
    required this.child,
    this.gradient,
    this.height = double.infinity,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
        ),
      ),
      child: child,
    );
  }
}