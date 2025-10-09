import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:persia_markt/features/cart/presentation/cubit/cart_state.dart';
import 'package:persia_markt/features/profile/presentation/cubit/favorites_cubit.dart';
import 'package:persia_markt/features/profile/presentation/cubit/favorites_state.dart';

class ProductListItemView extends StatelessWidget {
  final Product product;
  final Store store;
  final VoidCallback? onImageTap;

  const ProductListItemView({
    super.key,
    required this.product,
    required this.store,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
      child: ListTile(
        onTap: () => context.go('/store/${store.storeID}?productId=${product.id}'),
        leading: GestureDetector(
          onTap: onImageTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: product.primaryImageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(color: Colors.white),
              ),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/supermarket.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        title: Text(
          product.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product.isOnSale)
              Text(
                '€${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.lineThrough,
                  fontSize: 12,
                ),
              ),
            if (product.isOnSale) const SizedBox(width: 8),
            Text(
              '€${product.effectivePrice.toStringAsFixed(2)}',
              style: TextStyle(
                color: product.isOnSale ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: _ProductActions(product: product, store: store),
      ),
    );
  }
}

class _ProductActions extends StatelessWidget {
  final Product product;
  final Store store;
  const _ProductActions({required this.product, required this.store});

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            final isLiked = state.productIds.contains(product.id);
            return IconButton(
              onPressed: () => context.read<FavoritesCubit>().toggleLike(product.id),
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.grey,
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            final quantity = state.items[product.id] ?? 0;

            if (quantity == 0) {
              return IconButton(
                onPressed: () => cartCubit.addProduct(product.id, store.storeID),
                icon: const Icon(Icons.add_circle_outline),
                color: Theme.of(context).colorScheme.primary,
                tooltip: 'افزودن به سبد خرید',
              );
            }

            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 22),
                  onPressed: () => cartCubit.removeProduct(product.id),
                ),
                Text(quantity.toString(), style: Theme.of(context).textTheme.bodyLarge),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 22),
                  onPressed: () => cartCubit.addProduct(product.id, store.storeID),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}