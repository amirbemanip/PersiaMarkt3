// lib/core/models/market_data.dart
import 'package:equatable/equatable.dart';
import 'category_item.dart';
import 'product.dart';
import 'store.dart';

class MarketData extends Equatable {
  final List<Store> stores;
  final List<CategoryItem> categories;
  final List<Product> products;

  const MarketData({
    required this.stores,
    required this.categories,
    required this.products,
  });

  @override
  List<Object> get props => [stores, categories, products];

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      stores: (json['stores'] as List).map((item) => Store.fromJson(item)).toList(),
      categories: (json['categories'] as List).map((item) => CategoryItem.fromJson(item)).toList(),
      products: (json['products'] as List).map((item) => Product.fromJson(item)).toList(),
    );
  }
}