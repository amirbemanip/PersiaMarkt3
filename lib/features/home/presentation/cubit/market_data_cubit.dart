// lib/features/home/presentation/cubit/market_data_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/core/services/api_service.dart';
import 'package:persia_markt/core/models/market_data.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';

class MarketDataCubit extends Cubit<MarketDataState> {
  final ApiService _apiService;

  MarketDataCubit({required ApiService apiService})
      : _apiService = apiService,
        super(MarketDataLoading()); // ← const حذف شد

  /// دریافت داده‌ی بازار و انتشار State مناسب
  Future<void> fetchMarketData() async {
    try {
      emit(MarketDataLoading()); // ← const حذف شد

      final Map<String, dynamic> json = await _apiService.fetchMarketDataAsJson();
      final MarketData data = MarketData.fromJson(json);

      emit(MarketDataLoaded(marketData: data));
    } catch (e) {
      emit(MarketDataError(message: 'خطا در دریافت اطلاعات: ${e.toString()}'));
    }
  }
}
