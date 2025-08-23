// lib/features/home/presentation/widgets/special_offers_section.dart
import 'package:flutter/material.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/core/widgets/product_card_view.dart';

class SpecialOffersSection extends StatelessWidget {
  final List<Product> products;
  final List<Store> stores;

  const SpecialOffersSection(
      {super.key, required this.products, required this.stores});

  @override
  Widget build(BuildContext context) {
    final discountedProducts = products.where((p) => p.isOnSale).toList();

    if (discountedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    // <<< رنگ‌ها را مستقیماً از تم اصلی برنامه می‌خوانیم
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // <<< گرادیان پس‌زمینه حالا از رنگ‌های اصلی و ثانویه تم استفاده می‌کند
        gradient: LinearGradient(
          colors: [
            colorScheme.secondary.withOpacity(0.2),
            colorScheme.primary.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        // <<< رنگ حاشیه نیز بر اساس رنگ اصلی تم تنظیم می‌شود
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: SizedBox(
        height: 250, // Height for ProductCardView
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: discountedProducts.length,
          itemBuilder: (context, index) {
            final product = discountedProducts[index];
            final store = stores.firstWhere(
              (s) => s.storeID == product.storeID,
              orElse: () => Store.empty(),
            );
            if (store.storeID.isEmpty) return const SizedBox.shrink();

            return ProductCardView(product: product, store: store);
          },
        ),
      ),
    );
  }
}