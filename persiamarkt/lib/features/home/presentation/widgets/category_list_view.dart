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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // کمی پدینگ عمودی برای نمایش کامل سایه
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () => context.go('/category/${category.categoryID}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  // ======================= تغییر اصلی اینجاست =======================
                  // CircleAvatar با یک Container جایگزین شد تا بتوانیم سایه اضافه کنیم
                  Container(
                    width: 80,  // قطر دایره
                    height: 80, // قطر دایره
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/supermarket.png'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        // تعریف سایه ظریف
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // رنگ سایه بسیار ملایم
                          blurRadius: 8.0,  // میزان نرمی سایه
                          spreadRadius: 2.0, // میزان گستردگی
                          offset: const Offset(0, 4), // کمی به سمت پایین
                        ),
                      ],
                    ),
                  ),
                  // ================================================================
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