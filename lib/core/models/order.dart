// lib/core/models/order.dart
import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final int id;
  final String status;
  final DateTime createdAt;
  final double totalAmount;
  final Map<String, dynamic> seller;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.totalAmount,
    required this.seller,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      totalAmount: double.parse(json['total_amount'].toString()),
      seller: json['seller'] as Map<String, dynamic>,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, status];
}

class OrderItem extends Equatable {
  final String productName;
  final String productImageUrl;
  final int quantity;

  const OrderItem({
    required this.productName,
    required this.productImageUrl,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final productInfo = json['storeProduct']['product'];
    return OrderItem(
      productName: productInfo['name'],
      productImageUrl: (productInfo['images'] as List).isNotEmpty
          ? productInfo['images'][0]
          : '',
      quantity: json['quantity'],
    );
  }

  @override
  List<Object?> get props => [productName, quantity];
}