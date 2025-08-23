import 'package:fpdart/fpdart.dart';
import 'package:persia_markt/core/error/failures.dart';
import 'package:persia_markt/core/models/market_data.dart';
import 'package:persia_markt/core/services/api_service.dart';
import 'package:persia_markt/features/home/domain/repositories/market_repository.dart';

class MarketRepositoryImpl implements MarketRepository {
  final ApiService _apiService;

  const MarketRepositoryImpl({required ApiService apiService})
      : _apiService = apiService;

  @override
  Future<Either<Failure, MarketData>> getMarketData() async {
    try {
      // 1. Fetch the raw JSON data from the optimized ApiService.
      final Map<String, dynamic> marketDataJson =
          await _apiService.fetchMarketDataAsJson();

      // 2. Parse the JSON into a strongly-typed MarketData model.
      final marketData = MarketData.fromJson(marketDataJson);

      // 3. Return the successful result wrapped in a Right.
      return Right(marketData);
    } on Exception catch (e) {
      // 4. On any exception from the service layer, catch it and return
      //    a standardized ServerFailure with a user-friendly message.
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
