// lib/features/cart/presentation/cubit/cart_state.dart
import 'package:equatable/equatable.dart';

class CartState extends Equatable {
  // Map<productId, quantity>
  final Map<String, int> items;
  // ID فروشگاه‌هایی که برای پرداخت انتخاب شده‌اند را نگه می‌دارد
  final List<String> selectedStoreIds;

  const CartState({required this.items, required this.selectedStoreIds});

  @override
  List<Object> get props => [items, selectedStoreIds];
}