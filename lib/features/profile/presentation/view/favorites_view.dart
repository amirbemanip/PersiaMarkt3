// lib/features/profile/presentation/view/favorites_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/core/widgets/product_list_item_view.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';
import 'package:persia_markt/features/profile/presentation/cubit/favorites_cubit.dart';
import 'package:persia_markt/features/profile/presentation/cubit/favorites_state.dart';
import 'package:persia_markt/l10n/app_localizations.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favoritesTitle)),
      body: BlocBuilder<MarketDataBloc, MarketDataState>(
        builder: (context, marketState) {
          if (marketState is MarketDataLoaded) {
            return BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favoritesState) {
                final favoriteProducts = marketState.marketData.products
                    .where((p) => favoritesState.productIds.contains(p.id))
                    .toList();

                if (favoriteProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 100, color: Colors.grey.shade400),
                        const SizedBox(height: 24),
                        Text(
                          'لیست علاقه‌مندی‌های شما خالی است',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: favoriteProducts.length,
                  itemBuilder: (context, index) {
                    final product = favoriteProducts[index];
                    final store = marketState.marketData.stores.firstWhere(
                      (s) => s.storeID == product.storeID,
                    );
                    return ProductListItemView(product: product, store: store);
                  },
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}