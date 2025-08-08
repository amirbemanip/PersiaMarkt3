// lib/features/home/presentation/widgets/affordable_products_section.dart
import 'package:flutter/material.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/core/widgets/product_card_view.dart';

class AffordableProductsSection extends StatelessWidget {
  final List<Product> products;
  final List<Store> stores;
  const AffordableProductsSection({super.key, required this.products, required this.stores});

  @override
  Widget build(BuildContext context) {
    // Filter products that belong to the "affordable" category
    final affordableProducts = products.where((p) => p.categoryID == 'cat007').toList();
    
    if (affordableProducts.isEmpty) {
      return const SizedBox.shrink(); // Return empty space if no affordable products
    }

    return SizedBox(
      height: 250, // Height for ProductCardView
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: affordableProducts.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final product = affordableProducts[index];
          final store = stores.firstWhere((s) => s.storeID == product.storeID);
          return ProductCardView(product: product, store: store);
        },
      ),
    );
  }
}