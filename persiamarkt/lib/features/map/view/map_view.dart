import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:persia_markt/core/config/app_routes.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_cubit.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_state.dart';
import 'package:persia_markt/l10n/app_localizations.dart';

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
  // ۷. رفع مشکل عدم فوکوس مجدد
  // این متغیر برای جلوگیری از زوم ناخواسته هنگام بازگشت به نقشه استفاده می‌شود
  String? _lastFocusedStoreId;

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
    // اگر فروشگاهی برای فوکوس وجود دارد و قبلاً روی آن فوکوس نکرده‌ایم
    if (widget.focus != null &&
        widget.focus!.isNotEmpty &&
        widget.focus != _lastFocusedStoreId) {
      final store = stores.firstWhere(
        (s) => s.storeID == widget.focus,
        orElse: () => Store.empty(),
      );
      if (store.storeID.isNotEmpty) {
        // انیمیشن плавный برای حرکت به سمت فروشگاه
        _mapController.move(LatLng(store.latitude, store.longitude), 17.0);
        _lastFocusedStoreId = widget.focus;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    LatLng initialCenter = const LatLng(51.1657, 10.4515); // مرکز آلمان
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
        title: Text(l10n.map),
      ),
      body: BlocBuilder<MarketDataBloc, MarketDataState>(
        builder: (context, marketState) {
          if (marketState is! MarketDataLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final stores = marketState.marketData.stores;

          // این تابع بعد از ساخت ویجت‌ها، فوکوس را انجام می‌دهد
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
              _buildStoreMarkers(stores, context), // context به متد پاس داده شد
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
              LatLng(locationState.position.latitude,
                  locationState.position.longitude),
              15.0,
            );
          }
        },
        label: Text(l10n.myLocation),
        icon: const Icon(Icons.my_location),
      ),
    );
  }

  // ۵. بهبود پین‌های نقشه
  Widget _buildStoreMarkers(List<Store> stores, BuildContext context) {
    return MarkerLayer(
      markers: stores.map((s) {
        return Marker(
          point: LatLng(s.latitude, s.longitude),
          width: 150, // عرض بیشتر برای نمایش نام
          height: 80,
          child: GestureDetector(
            onTap: () => context.go(AppRoutes.storeDetailPath(s.storeID)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // آیکون پین
                const Icon(Icons.location_on, size: 40, color: Colors.orange),
                // کادر نام فروشگاه
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    s.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
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
