import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';
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
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        onTap: () => context.go('/store/${store.storeID}?productId=${product.id}'),
        leading: GestureDetector(
          onTap: onImageTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.primaryImageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
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
        subtitle: Text(
          product.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ۲. نمایش قیمت قبل و بعد از تخفیف
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (product.isOnSale)
                  Text(
                    '€${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 11,
                    ),
                  ),
                Text(
                  '€${product.effectivePrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: product.isOnSale ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            _FavoriteButton(productId: product.id),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final String productId;
  const _FavoriteButton({required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final isLiked = state.productIds.contains(productId);
        return IconButton(
          onPressed: () => context.read<FavoritesCubit>().toggleLike(productId),
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey,
          ),
        );
      },
    );
  }
}
