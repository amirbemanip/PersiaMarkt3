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

  /// Creates a MarketData instance from a JSON object.
  /// It safely handles potential errors during parsing of its child lists.
  factory MarketData.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse a list of items
    List<T> _parseList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      try {
        if (json[key] is List) {
          return (json[key] as List).map((item) => fromJson(item)).toList();
        }
      } catch (e) {
        print('Error parsing list for key "$key": $e');
      }
      return []; // Return an empty list on failure
    }

    return MarketData(
      stores: _parseList('stores', Store.fromJson),
      categories: _parseList('categories', CategoryItem.fromJson),
      products: _parseList('products', Product.fromJson),
    );
  }
}
