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

// ۱. تبدیل به StatefulWidget برای مدیریت بهتر حالت
class MapView extends StatefulWidget {
  final String? lat;
  final String? lng;
  const MapView({super.key, this.lat, this.lng});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // ۲. کنترلر نقشه به عنوان یک متغیر در State تعریف می‌شود
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    // ۳. کنترلر فقط یک بار در اینجا ساخته می‌شود و در طول عمر ویجت باقی می‌ماند
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose(); // ۴. کنترلر در زمان خروج از صفحه از بین می‌رود
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialCenter = const LatLng(51.1657, 10.4515); // مرکز آلمان
    double initialZoom = 6.0;

    if (widget.lat != null && widget.lng != null) {
      try {
        initialCenter = LatLng(double.parse(widget.lat!), double.parse(widget.lng!));
        initialZoom = 15.0;
      } catch (e) {
        // Handle parsing error if any
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('نقشه فروشگاه‌ها')),
      body: BlocBuilder<MarketDataBloc, MarketDataState>(
        builder: (context, marketState) {
          if (marketState is! MarketDataLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final stores = marketState.marketData.stores;
          
          return FlutterMap(
            mapController: _mapController, // ۵. استفاده از کنترلر تعریف شده در State
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: initialZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{y}.png",
              ),
              // لایه‌های مارکرها
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
            // انیمیشن плавی برای حرکت به موقعیت کاربر
            _mapController.moveAndRotate(
              LatLng(locationState.position.latitude, locationState.position.longitude),
              15.0,
              0.0
            );
          }
        },
        label: const Text('موقعیت من'),
        icon: const Icon(Icons.my_location),
      ),
    );
  }

  /// متد کمکی برای ساخت مارکرهای فروشگاه
  MarkerLayer _buildStoreMarkers(BuildContext context, List<Store> stores) {
    return MarkerLayer(
      markers: stores.map((store) {
        return Marker(
          width: 120,
          height: 80,
          point: LatLng(store.location.lat, store.location.lng),
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

  /// متد کمکی برای ساخت مارکر موقعیت کاربر
  Widget _buildUserLocationMarker(BuildContext context) {
    return BlocConsumer<LocationCubit, LocationState>(
      // Listener برای حرکت اولیه به موقعیت کاربر
      listener: (context, locationState) {
        if (locationState is LocationLoaded && widget.lat == null) {
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