import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/models/category_item.dart';

class CategoryListView extends StatelessWidget {
  final List<CategoryItem> categories;
  const CategoryListView({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () => context.go('/category/${category.id}'),
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
                          // FIXED: Replaced deprecated withOpacity
                          color: Colors.black.withAlpha((255 * 0.1).round()),
                          blurRadius: 8.0,
                          spreadRadius: 2.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      // FIXED: Handle nullable iconUrl
                      child: (category.iconUrl != null && category.iconUrl!.isNotEmpty)
                          ? Image.network(
                              category.iconUrl!, // We know it's not null here
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2.0),
                                );
                              },
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
          );
        },
      ),
    );
  }

  /// A helper widget for showing a placeholder icon.
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
