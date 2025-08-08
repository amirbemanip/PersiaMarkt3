// lib/core/widgets/loading_shimmer.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// یک ویجت پایه برای ساخت افکت شیمر
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
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
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

// اسکلت صفحه اصلی در حالت لودینگ
class HomeLoadingShimmer extends StatelessWidget {
  const HomeLoadingShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer for Header
          const ShimmerBox(width: double.infinity, height: 120),
          const SizedBox(height: 24),
          // Shimmer for Categories
          const ShimmerBox(width: 150, height: 24),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: ShimmerBox(width: 90, height: 120, shape: CircleBorder()),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Shimmer for Banners
          const ShimmerBox(width: 150, height: 24),
          const SizedBox(height: 16),
          const ShimmerBox(width: double.infinity, height: 150),
          const SizedBox(height: 24),
          // Shimmer for Products
          const ShimmerBox(width: 150, height: 24),
          const SizedBox(height: 16),
           SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: ShimmerBox(width: 160, height: 220, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}