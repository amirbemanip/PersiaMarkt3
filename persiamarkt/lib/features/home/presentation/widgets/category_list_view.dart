// lib/features/home/presentation/widgets/category_list_view.dart
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            // اصلاح شده: با کلیک به صفحه جزئیات دسته‌بندی می‌رود
            onTap: () => context.go('/category/${category.categoryID}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: const AssetImage('assets/images/supermarket.png'),
                    backgroundColor: Colors.orange.shade100,
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
}