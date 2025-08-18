// lib/core/widgets/store_list_item_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_cubit.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_state.dart';

class StoreListItemView extends StatelessWidget {
  final Store store;
  const StoreListItemView({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // سایه ملایم
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          onTap: () => context.go('/store/${store.storeID}'),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              store.storeImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/supermarket.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            store.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
          subtitle: Text(
            '${store.address}, ${store.city}',
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(store.rating.toString()),
                ],
              ),
              const SizedBox(height: 4),
              BlocBuilder<LocationCubit, LocationState>(
                builder: (context, locationState) {
                  if (locationState is LocationLoaded) {
                    final distance = Geolocator.distanceBetween(
                      locationState.position.latitude,
                      locationState.position.longitude,
                      store.latitude,  // اصلاح شد
                      store.longitude, // اصلاح شد
                    );
                    final distanceText = '${(distance / 1000).toStringAsFixed(1)} کیلومتر';
                    return Text(
                      distanceText,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
