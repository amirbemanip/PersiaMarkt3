import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_cubit.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_state.dart';
import 'package:persia_markt/l10n/app_localizations.dart'; // ۱. Import برای ترجمه

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
    final l10n = AppLocalizations.of(context)!; // ۲. نمونه l10n
    LatLng initialCenter = const LatLng(51.1657, 10.4515);
    double initialZoom = 6.0;

    if (widget.lat != null && widget.lng != null) {
      final lat = double.tryParse(widget.lat!);
      final lng = double.tryParse(widget.lng!);
      if (lat != null && lng != null) {
        initialCenter = LatLng(lat, lng);
        initialZoom = 15.0;
      }
    }

    return Scaffold(
      appBar: AppBar(
        // ۳. عنوان AppBar ترجمه شد
        title: Text(l10n.map),
      ),
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
              onMapReady: () => _tryFocusStore(stores),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              _buildStoreMarkers(stores),
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
        // ۴. لیبل دکمه ترجمه شد
        label: Text(l10n.myLocation),
        icon: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildStoreMarkers(List<Store> stores) {
    return MarkerLayer(
      markers: stores.map((s) {
        return Marker(
          point: LatLng(s.latitude, s.longitude),
          width: 40,
          height: 40,
          child: Tooltip(
            message: s.name,
            child: GestureDetector(
              onTap: () {
                _mapController.move(LatLng(s.latitude, s.longitude), 17.0);
              },
              child: const Icon(Icons.location_on, size: 36, color: Colors.orange),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserLocationMarker(BuildContext context) {
    final loc = context.watch<LocationCubit>().state;
    if (loc is! LocationLoaded) return const SizedBox.shrink();

    return MarkerLayer(
      markers: [
        Marker(
          point: LatLng(loc.position.latitude, loc.position.longitude),
          width: 36,
          height: 36,
          child: const Icon(Icons.my_location, size: 28, color: Colors.blue),
        ),
      ],
    );
  }
}