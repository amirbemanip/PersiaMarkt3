// lib/features/checkout/presentation/cubit/checkout_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:persia_markt/features/checkout/data/services/checkout_service.dart';
import 'package:persia_markt/features/order_history/presentation/cubit/order_history_cubit.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CheckoutService _checkoutService;
  final CartCubit _cartCubit;
  final OrderHistoryCubit _orderHistoryCubit;

  CheckoutCubit({
    required CheckoutService checkoutService,
    required CartCubit cartCubit,
    required OrderHistoryCubit orderHistoryCubit,
  })  : _checkoutService = checkoutService,
        _cartCubit = cartCubit,
        _orderHistoryCubit = orderHistoryCubit,
        super(CheckoutInitial());

  Future<void> submitOrder({
    required Map<String, String> address,
    required List<Map<String, dynamic>> items,
  }) async {
    emit(CheckoutLoading());
    try {
      final newOrders = await _checkoutService.placeOrder(
        address: address,
        items: items,
      );

      // <<< اصلاح اصلی ۱: پس از موفقیت، متد clearCart را فراخوانی می‌کنیم
      await _cartCubit.clearCart();

      // <<< اصلاح اصلی ۲: سفارشات جدید را به ابتدای لیست تاریخچه اضافه می‌کنیم
      _orderHistoryCubit.addOrdersToState(newOrders);

      emit(CheckoutSuccess());
    } catch (e) {
      emit(CheckoutError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}