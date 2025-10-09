// lib/features/cart/presentation/view/cart_view.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:persia_markt/core/config/app_routes.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';
import 'package:persia_markt/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:persia_markt/features/cart/presentation/cubit/cart_state.dart';
import 'package:persia_markt/l10n/app_localizations.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.yourShoppingCart)),
      body: BlocBuilder<MarketDataBloc, MarketDataState>(
        builder: (context, marketState) {
          if (marketState is! MarketDataLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              if (cartState.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 100, color: Colors.grey.shade400),
                      const SizedBox(height: 24),
                      Text(
                        l10n.yourCartIsEmpty,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                );
              }

              final cartProducts = marketState.marketData.products
                  .where((p) => cartState.items.containsKey(p.id))
                  .toList();

              final Map<String, List<Product>> productsByStore = {};
              for (var product in cartProducts) {
                productsByStore.putIfAbsent(product.storeID, () => []).add(product);
              }

              final double grandTotal = cartProducts.fold(0, (sum, item) {
                if (cartState.selectedStoreIds.contains(item.storeID)) {
                  final quantity = cartState.items[item.id] ?? 0;
                  return sum + (item.effectivePrice * quantity);
                }
                return sum;
              });

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: productsByStore.keys.length,
                      itemBuilder: (context, index) {
                        final storeId = productsByStore.keys.elementAt(index);
                        final store = marketState.marketData.stores
                            .firstWhere((s) => s.storeID == storeId);
                        final productsInStore = productsByStore[storeId]!;
                        final isStoreSelected = cartState.selectedStoreIds.contains(storeId);

                        final double storeSubtotal =
                            productsInStore.fold(0, (sum, item) {
                          final quantity = cartState.items[item.id] ?? 0;
                          return sum + (item.effectivePrice * quantity);
                        });

                        return Opacity(
                          opacity: isStoreSelected ? 1.0 : 0.5,
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SwitchListTile(
                                  title: Text(store.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                  value: isStoreSelected,
                                  onChanged: (bool value) {
                                    context
                                        .read<CartCubit>()
                                        .toggleStoreSelection(store.storeID);
                                  },
                                ),
                                const Divider(height: 1),
                                ...productsInStore.map((p) => _CartItemTile(
                                      product: p,
                                      quantity: cartState.items[p.id]!,
                                      isEnabled: isStoreSelected,
                                    )),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'جمع: €${storeSubtotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildCheckoutSection(context, grandTotal),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, double grandTotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('مجموع کل:', style: Theme.of(context).textTheme.headlineSmall),
              Text(
                '€${grandTotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: grandTotal > 0 ? () {
              context.push(AppRoutes.checkout);
            } : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              textStyle:
                  Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            child: const Text('ادامه فرآیند خرید'),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final Product product;
  final int quantity;
  final bool isEnabled;

  const _CartItemTile({
    required this.product,
    required this.quantity,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: product.primaryImageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(color: Colors.white),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
      title: Text(product.name),
      subtitle: Text('€${product.effectivePrice.toStringAsFixed(2)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: isEnabled ? () => cartCubit.removeProduct(product.id) : null,
            tooltip: 'کم کردن',
          ),
          Text(quantity.toString(),
              style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: isEnabled ? () => cartCubit.addProduct(product.id, product.storeID) : null,
            tooltip: 'اضافه کردن',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
            onPressed: isEnabled ? () => cartCubit.clearProductFromCart(product.id) : null,
            tooltip: 'حذف کامل',
          ),
        ],
      ),
    );
  }
}