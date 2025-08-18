import 'package:equatable/equatable.dart';

class Store extends Equatable {
  final String storeID;
  final String name;
  final String address;
  final String storeImage;
  final double latitude;
  final double longitude;
  final double rating;

  // فیلدهای اضافی که ممکن است در آینده از API بیایند
  final String? city;
  final String? phone;

  const Store({
    required this.storeID,
    required this.name,
    required this.address,
    required this.storeImage,
    required this.latitude,
    required this.longitude,
    required this.rating,
    this.city,
    this.phone,
  });

  /// برای مواقعی که نیاز به Store خالی داریم
  factory Store.empty() {
    return const Store(
      storeID: '',
      name: 'Not Found',
      address: '',
      storeImage: '',
      latitude: 0.0,
      longitude: 0.0,
      rating: 0.0,
    );
  }

  @override
  List<Object?> get props => [storeID, name, address];

  /// Creates a Store instance from a JSON object.
  /// This factory is now updated to match the backend API response keys.
  factory Store.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse numbers
    double _parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Store(
      // FIXED: Mapped API keys to model properties
      storeID: (json['id'] as int).toString(),
      name: json['store_name'] as String? ?? 'Unnamed Store',
      address: json['store_address'] as String? ?? 'No address',
      storeImage: json['store_image_url'] as String? ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      rating: _parseDouble(json['rating']),
      city: json['city'] as String?, // Optional field
      phone: json['phone'] as String?, // Optional field
    );
  }
}
