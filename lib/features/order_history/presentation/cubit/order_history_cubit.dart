// lib/features/order_history/presentation/cubit/order_history_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/core/models/order.dart';
import 'package:persia_markt/features/order_history/data/services/order_history_service.dart';
import 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  final OrderHistoryService _orderHistoryService;

  OrderHistoryCubit({required OrderHistoryService orderHistoryService})
      : _orderHistoryService = orderHistoryService,
        super(OrderHistoryInitial());

  Future<void> fetchOrders() async {
    // اگر لیست از قبل پر بود، دوباره از سرور نگیر مگر اینکه مجبور باشیم
    if (state is OrderHistoryLoaded) return;
    
    emit(OrderHistoryLoading());
    try {
      final orders = await _orderHistoryService.fetchOrders();
      emit(OrderHistoryLoaded(orders));
    } catch (e) {
      emit(OrderHistoryError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // <<< متد کاملاً جدید برای افزودن سفارشات جدید به ابتدای لیست
  void addOrdersToState(List<Order> newOrders) {
    if (state is OrderHistoryLoaded) {
      final currentState = state as OrderHistoryLoaded;
      // سفارشات جدید را به ابتدای لیست فعلی اضافه می‌کنیم
      final updatedOrders = [...newOrders, ...currentState.orders];
      emit(OrderHistoryLoaded(updatedOrders));
    } else {
      // اگر هنوز لیستی لود نشده بود، فقط سفارشات جدید را نمایش می‌دهیم
      emit(OrderHistoryLoaded(newOrders));
    }
  }

  void reset() {
    emit(OrderHistoryInitial());
  }
}