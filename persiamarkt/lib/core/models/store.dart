// lib/core/models/store.dart
import 'package:equatable/equatable.dart';
import 'location.dart';

class Store extends Equatable {
  final String storeID;
  final String name;
  final String address;
  final String city;
  final String phone;
  final Location location;
  final double rating;
  final List<String> deliveryOptions;
  final double deliveryFeePerKm;
  final String storeImage;
  final String nameEn;
  final String cityEn;
  final String storeType;
  final Map<String, String> operatingHours;
  final String currency;

  const Store({
    required this.storeID,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.location,
    required this.rating,
    required this.deliveryOptions,
    required this.deliveryFeePerKm,
    required this.storeImage,
    required this.nameEn,
    required this.cityEn,
    required this.storeType,
    required this.operatingHours,
    required this.currency,
  });

  @override
  List<Object> get props => [storeID, name, city];

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeID: json['storeID'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      phone: json['phone'] as String,
      location: Location.fromJson(json['location']),
      rating: (json['rating'] as num).toDouble(),
      deliveryOptions: List<String>.from(json['deliveryOptions']),
      deliveryFeePerKm: (json['deliveryFeePerKm'] as num).toDouble(),
      storeImage: json['storeImage'] as String,
      nameEn: json['name_en'] as String,
      cityEn: json['city_en'] as String,
      storeType: json['storeType'] as String,
      operatingHours: Map<String, String>.from(json['operatingHours']),
      currency: json['currency'] as String,
    );
  }

  factory Store.empty() {
    return Store(
      storeID: '',
      name: '',
      address: '',
      city: '',
      phone: '',
      location: const Location(lat: 0.0, lng: 0.0),
      rating: 0.0,
      deliveryOptions: const [],
      deliveryFeePerKm: 0.0,
      storeImage: '',
      nameEn: '',
      cityEn: '',
      storeType: '',
      operatingHours: const {},
      currency: '',
    );
  }
}
