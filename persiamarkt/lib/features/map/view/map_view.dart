// lib/features/map/view/map_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_cubit.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_state.dart';

class MapView extends StatefulWidget {
  final String? lat;
  final String? lng;
  final String? focus;

  const MapView({super.key, this.lat, this.lng, this.focus});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final MapController _mapController;
  bool _hasFocused = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _tryFocusStore(List<Store> stores) {
    if (_hasFocused) return;
    if (widget.focus != null && widget.focus!.isNotEmpty) {
      final store = stores.firstWhere(
        (s) => s.storeID == widget.focus,
        orElse: () => Store.empty(),
      );
      if (store.storeID.isNotEmpty) {
        _mapController.move(LatLng(store.latitude, store.longitude), 17.0);
        _hasFocused = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialCenter = const LatLng(51.1657, 10.4515);
    double initialZoom = 6.0;

    if (widget.lat != null && widget.lng != null) {
      try {
        initialCenter = LatLng(double.parse(widget.lat!), double.parse(widget.lng!));
        initialZoom = 15.0;
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(title: const Text('نقشه فروشگاه‌ها')),
      body: BlocBuilder<MarketDataBloc, MarketDataState>(
        builder: (context, marketState) {
          if (marketState is! MarketDataLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final stores = marketState.marketData.stores;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _tryFocusStore(stores);
          });

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: initialZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              _buildStoreMarkers(context, stores),
              _buildUserLocationMarker(context),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final locationState = context.read<LocationCubit>().state;
          if (locationState is LocationLoaded) {
            _mapController.move(
              LatLng(locationState.position.latitude, locationState.position.longitude),
              15.0,
            );
          }
        },
        label: const Text('موقعیت من'),
        icon: const Icon(Icons.my_location),
      ),
    );
  }

  MarkerLayer _buildStoreMarkers(BuildContext context, List<Store> stores) {
    return MarkerLayer(
      markers: stores.map((store) {
        return Marker(
          width: 120,
          height: 80,
          point: LatLng(store.latitude, store.longitude),
          child: GestureDetector(
            onTap: () => context.go('/store/${store.storeID}'),
            child: Column(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 30),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(220),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Text(
                    store.name,
                    style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserLocationMarker(BuildContext context) {
    return BlocConsumer<LocationCubit, LocationState>(
      listener: (context, locationState) {
        if (locationState is LocationLoaded && widget.lat == null && widget.lng == null && widget.focus == null) {
          _mapController.move(
            LatLng(locationState.position.latitude, locationState.position.longitude),
            13.0,
          );
        }
      },
      builder: (context, locationState) {
        if (locationState is LocationLoaded) {
          return MarkerLayer(
            markers: [
              Marker(
                width: 80,
                height: 80,
                point: LatLng(locationState.position.latitude, locationState.position.longitude),
                child: Icon(Icons.my_location, color: Theme.of(context).primaryColor, size: 30),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
