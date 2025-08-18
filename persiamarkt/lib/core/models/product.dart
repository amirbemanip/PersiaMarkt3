import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String storeID;
  final String name;
  final String description;
  final String brand;
  final List<String> images;
  final double price;
  final double? discountPrice;
  final int stock;
  final bool isPerishable;
  final String categoryID;

  const Product({
    required this.id,
    required this.storeID,
    required this.name,
    required this.description,
    required this.brand,
    required this.images,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.isPerishable,
    required this.categoryID,
  });

  /// A helper getter to return the primary image URL.
  String get primaryImageUrl => images.isNotEmpty ? images.first : '';

  /// A helper getter to determine the effective price (discounted or original).
  double get effectivePrice => discountPrice ?? price;

  /// A helper getter to check if the product is on sale.
  bool get isOnSale => discountPrice != null && discountPrice! < price;

  @override
  List<Object?> get props => [id, storeID, name, effectivePrice];

  /// Creates a Product instance from a JSON object received from the API.
  /// This factory is designed to parse the new nested API structure safely.
  factory Product.fromJson(Map<String, dynamic> json) {
    // Safely access the nested 'product' object.
    final productData = json['product'] as Map<String, dynamic>? ?? {};

    // Helper function to safely parse string prices to double.
    double? _parseDouble(dynamic value) {
      if (value == null) return null;
      return double.tryParse(value.toString());
    }

    return Product(
      id: json['id']?.toString() ?? 'unknown_id',
      storeID: json['storeID']?.toString() ?? 'unknown_store',
      price: _parseDouble(json['price']) ?? 0.0,
      discountPrice: _parseDouble(json['discount_price']),
      stock: json['stock'] as int? ?? 0,
      name: productData['name'] as String? ?? 'Unnamed Product',
      images: (productData['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      brand: productData['brand'] as String? ?? 'Unknown Brand',
      description: productData['description'] as String? ?? '',
      isPerishable: productData['is_perishable'] as bool? ?? false,
      // Safely parse category_id which comes as an integer from the backend.
      categoryID: productData['category_id']?.toString() ?? 'uncategorized',
    );
  }
}
