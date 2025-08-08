// lib/core/widgets/loading_shimmer.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A reusable shimmer box widget to indicate loading state.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shape;

  const ShimmerBox({
    Key? key,
    required this.width,
    required this.height,
    this.shape = const RoundedRectangleBorder(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey,
          shape: shape,
        ),
      ),
    );
  }
}