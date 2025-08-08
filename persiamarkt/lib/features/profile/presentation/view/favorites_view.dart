// lib/features/profile/presentation/view/favorites_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/widgets/product_list_item_view.dart';
import 'package:persia_markt/features/home/presentation/cubit/market_data_cubit.dart';
import 'package:persia_markt/features/home/presentation/cubit/market_data_state.dart';
import 'package:persia_markt/features/profile/presentation/cubit/favorites_cubit.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final marketState = context.watch<MarketDataCubit>().state;
    final favoriteProductIds = context.watch<FavoritesCubit>().state.productIds;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('محصولات مورد علاقه'),
        ),
        body: (marketState is MarketDataLoaded)
            ? (favoriteProductIds.isEmpty
                ? const Center(
                    child: Text('شما هنوز هیچ محصولی را لایک نکرده‌اید.'),
                  )
                : ListView.builder(
                    itemCount: favoriteProductIds.length,
                    itemBuilder: (context, index) {
                      final productId = favoriteProductIds[index];
                      final Product? product = marketState.marketData.products.firstWhere((p) => p.productID == productId);
                      
                      if (product == null) return const SizedBox.shrink();
                      
                      final store = marketState.marketData.stores.firstWhere((s) => s.storeID == product.storeID);

                      return ProductListItemView(product: product, store: store);
                    },
                  ))
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}