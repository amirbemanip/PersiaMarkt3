// lib/core/models/product.dart
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String productID;
  final String name;
  final String categoryID;
  final double price;
  final String description;
  final String imageURL;
  final String storeID;
  final bool isPostalAvailable;
  final int stock;
  final double discount;
  final String unit;
  final List<String> tags;
  final String nameEn;
  final String variant;

  const Product({
    required this.productID,
    required this.name,
    required this.categoryID,
    required this.price,
    required this.description,
    required this.imageURL,
    required this.storeID,
    required this.isPostalAvailable,
    required this.stock,
    required this.discount,
    required this.unit,
    required this.tags,
    required this.nameEn,
    required this.variant,
  });

  /// ساخت یک Product خالی برای استفاده در orElse
  factory Product.empty() {
    return Product(
      productID: '',
      name: '',
      categoryID: '',
      price: 0.0,
      description: '',
      imageURL: '',
      storeID: '',
      isPostalAvailable: false,
      stock: 0,
      discount: 0.0,
      unit: '',
      tags: const [],
      nameEn: '',
      variant: '',
    );
  }

  @override
  List<Object?> get props => [productID, name, categoryID, price, storeID];
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productID: json['productID'] as String,
      name: json['name'] as String,
      categoryID: json['categoryID'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      imageURL: json['imageURL'] as String,
      storeID: json['storeID'] as String,
      isPostalAvailable: json['isPostalAvailable'] as bool,
      stock: json['stock'] as int,
      discount: (json['discount'] as num).toDouble(),
      unit: json['unit'] as String,
      tags: List<String>.from(json['tags']),
      nameEn: json['name_en'] as String,
      variant: json['variant'] as String,
    );
  }
}
