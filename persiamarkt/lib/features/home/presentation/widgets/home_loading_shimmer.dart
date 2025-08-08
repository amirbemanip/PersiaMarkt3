// lib/features/home/presentation/widgets/home_loading_shimmer.dart
import 'package:flutter/material.dart';
import 'package:persia_markt/core/widgets/loading_shimmer.dart';

class HomeLoadingShimmer extends StatelessWidget {
  const HomeLoadingShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header Shimmer
          const ShimmerBox(width: double.infinity, height: 180, shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const ShimmerBox(width: 150, height: 24),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          ShimmerBox(width: 80, height: 80, shape: CircleBorder()),
                          SizedBox(height: 8),
                          ShimmerBox(width: 60, height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const ShimmerBox(width: 150, height: 24),
                const SizedBox(height: 16),
                const ShimmerBox(width: double.infinity, height: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }
}