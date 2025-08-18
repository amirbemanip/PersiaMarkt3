import 'package:flutter/material.dart';
import 'package:persia_markt/core/models/category_item.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/core/widgets/product_card_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';

class AffordableProductsSection extends StatelessWidget {
  final List<Product> products;
  final List<Store> stores;
  
  // Constructor was missing, added it back.
  const AffordableProductsSection({super.key, required this.products, required this.stores});

  @override
  Widget build(BuildContext context) {
    // --- FIXED: Dynamically find the "Economical" category ID ---
    final marketState = context.read<MarketDataBloc>().state;
    String? affordableCategoryId;

    if (marketState is MarketDataLoaded) {
      try {
        // Find the category by its Persian name.
        final affordableCategory = marketState.marketData.categories.firstWhere(
          (c) => c.name == 'اقتصادی',
        );
        affordableCategoryId = affordableCategory.id;
      } catch (e) {
        // If the category doesn't exist, do nothing.
        print('"اقتصادی" category not found.');
      }
    }

    // If the category ID couldn't be found, don't show the section.
    if (affordableCategoryId == null) {
      return const SizedBox.shrink();
    }

    // Filter products that belong to the dynamically found category ID.
    final affordableProducts = products.where((p) => p.categoryID == affordableCategoryId).toList();
    
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
          // Safely find the corresponding store.
          final store = stores.firstWhere(
            (s) => s.storeID == product.storeID,
            orElse: () => Store.empty(), // Return a dummy store if not found
          );
          if (store.storeID.isEmpty) return const SizedBox.shrink();
          
          return ProductCardView(product: product, store: store);
        },
      ),
    );
  }
}
