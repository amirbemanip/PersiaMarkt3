import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/core/services/api_service.dart';
import 'market_data_state.dart';

class MarketDataCubit extends Cubit<MarketDataState> {
  final ApiService _apiService;

  MarketDataCubit({required ApiService apiService})
      : _apiService = apiService,
        super(MarketDataLoading());

  Future<void> fetchMarketData() async {
    try {
      emit(MarketDataLoading());
      final data = await _apiService.fetchMarketData();
      emit(MarketDataLoaded(marketData: data));
    } catch (e) {
      emit(MarketDataError(message: 'خطا در دریافت اطلاعات: ${e.toString()}'));
    }
  }
}