import 'package:fpdart/fpdart.dart';
import 'package:persia_markt/core/error/exceptions.dart';
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
      final Map<String, dynamic> marketDataJson =
          await _apiService.fetchMarketDataAsJson();
      final marketData = MarketData.fromJson(marketDataJson);
      return Right(marketData);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    } on ParsingException {
      return const Left(UnexpectedFailure()); // Parsing errors are unexpected
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}