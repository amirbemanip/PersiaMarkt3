import 'package:flutter/material.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/core/widgets/store_list_item_view.dart';

class StoresByCitySection extends StatelessWidget {
  final List<Store> stores;
  const StoresByCitySection({super.key, required this.stores});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Store>> storesByCity = {};
    for (var store in stores) {
      if (store.city != null && store.city!.isNotEmpty) {
        storesByCity.putIfAbsent(store.city!, () => []).add(store);
      }
    }

    if (storesByCity.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: storesByCity.keys.length,
      itemBuilder: (context, index) {
        final city = storesByCity.keys.elementAt(index);
        final cityStores = storesByCity[city]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(city, style: Theme.of(context).textTheme.headlineSmall),
            ),
            // حتماً اسپرد استفاده شود
            ...cityStores.map((store) => StoreListItemView(store: store)).toList(),
          ],
        );
      },
    );
  }
}
