// مسیر: lib/core/data/models/market_data_model.dart

import 'package:persia_markt/core/models/category_item.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';

class MarketData {
  final List<CategoryItem> categories;
  final List<Store> stores;
  final List<Product> products;
  final List<Product> specialOfferProducts;
  final List<Product> affordableProducts;
  final List<dynamic> banners; // Assuming banners can be of any type for now

  MarketData({
    required this.categories,
    required this.stores,
    required this.products,
    required this.specialOfferProducts,
    required this.affordableProducts,
    required this.banners,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      categories: (json['categories'] as List)
          .map((i) => CategoryItem.fromJson(i))
          .toList(),
      stores: (json['stores'] as List).map((i) => Store.fromJson(i)).toList(),
      products: (json['products'] as List).map((i) => Product.fromJson(i)).toList(),
      specialOfferProducts: (json['specialOfferProducts'] as List)
          .map((i) => Product.fromJson(i))
          .toList(),
      affordableProducts: (json['affordableProducts'] as List)
          .map((i) => Product.fromJson(i))
          .toList(),
      banners: json['banners'] as List,
    );
  }
}