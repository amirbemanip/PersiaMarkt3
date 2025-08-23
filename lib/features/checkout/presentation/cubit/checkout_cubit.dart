// lib/features/checkout/presentation/cubit/checkout_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:persia_markt/features/checkout/data/services/checkout_service.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CheckoutService _checkoutService;
  final CartCubit _cartCubit;

  CheckoutCubit({
    required CheckoutService checkoutService,
    required CartCubit cartCubit,
  })  : _checkoutService = checkoutService,
        _cartCubit = cartCubit,
        super(CheckoutInitial());

  Future<void> submitOrder({
    required Map<String, String> address,
  }) async {
    emit(CheckoutLoading());
    try {
      // فقط آیتم‌های فروشگاه‌های انتخاب شده را برای ارسال آماده می‌کنیم
      final cartState = _cartCubit.state;
      final itemsToCheckout = cartState.items.entries
          .where((entry) {
            // این بخش نیاز به دسترسی به اطلاعات محصول دارد تا storeID را پیدا کند
            // ما این منطق را به View منتقل می‌کنیم تا ساده‌تر باشد
            return true; // Placeholder
          })
          .map((entry) =>
              {'storeProductId': int.parse(entry.key), 'quantity': entry.value})
          .toList();

      await _checkoutService.placeOrder(
        address: address,
        items: itemsToCheckout,
      );

      // پس از موفقیت، سبد خرید را خالی می‌کنیم
      // این کار را با بازسازی Cubit انجام می‌دهیم
      _cartCubit.loadCartProducts(); // This will clear the cart in a real scenario

      emit(CheckoutSuccess());
    } catch (e) {
      emit(CheckoutError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}