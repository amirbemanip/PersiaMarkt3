import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/config/app_routes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:persia_markt/core/models/category_item.dart';
// ۱. پکیج انیمیشن را ایمپورت کنید
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CategoryListView extends StatelessWidget {
  final List<CategoryItem> categories;
  const CategoryListView({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      // ۲. ListView.builder را با AnimationLimiter بپوشانید
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          itemBuilder: (context, index) {
            final category = categories[index];
            // ۳. هر آیتم را با کامپوننت‌های انیمیشن بپوشانید
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.categoryDetailPath(category.id)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha((255 * 0.1).round()),
                                  blurRadius: 8.0,
                                  spreadRadius: 2.0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: (category.iconUrl != null &&
                                      category.iconUrl!.isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: category.iconUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(color: Colors.white),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          _buildPlaceholderIcon(),
                                    )
                                  : _buildPlaceholderIcon(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Image.asset(
        'assets/images/supermarket.png',
        color: Colors.grey.shade400,
      ),
    );
  }
}