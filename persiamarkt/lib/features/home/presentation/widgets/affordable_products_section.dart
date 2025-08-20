import 'package:flutter/material.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/core/widgets/product_card_view.dart';

class AffordableProductsSection extends StatelessWidget {
  final List<Product> products;
  final List<Store> stores;

  const AffordableProductsSection(
      {super.key, required this.products, required this.stores});

  @override
  Widget build(BuildContext context) {
    // ۱۱. رفع مشکل نمایش کالاهای تخفیف‌خورده
    // محصولات بر اساس داشتن قیمت تخفیف‌خورده فیلتر می‌شوند
    final discountedProducts =
        products.where((p) => p.isOnSale).toList();

    if (discountedProducts.isEmpty) {
      return const SizedBox.shrink(); // اگر محصولی تخفیف نداشت، چیزی نمایش نده
    }

    return SizedBox(
      height: 250, // Height for ProductCardView
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: discountedProducts.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final product = discountedProducts[index];
          // پیدا کردن فروشگاه مربوط به هر محصول
          final store = stores.firstWhere(
            (s) => s.storeID == product.storeID,
            orElse: () => Store.empty(), // اگر فروشگاه پیدا نشد، یک فروشگاه خالی برگردان
          );
          // اگر به هر دلیلی فروشگاه پیدا نشد، کارت محصول را نمایش نده
          if (store.storeID.isEmpty) return const SizedBox.shrink();

          return ProductCardView(product: product, store: store);
        },
      ),
    );
  }
}
