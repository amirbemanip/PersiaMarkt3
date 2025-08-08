// test/features/home/presentation/bloc/market_data_bloc_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:persia_markt/core/error/failures.dart';
import 'package:persia_markt/core/models/market_data.dart';
import 'package:persia_markt/features/home/domain/repositories/market_repository.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_event.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';

// ۱. یک کلاس Mock (شبیه‌سازی شده) از Repository می‌سازیم
// این به ما اجازه می‌دهد رفتار Repository را در تست کنترل کنیم
class MockMarketRepository extends Mock implements MarketRepository {}

void main() {
  // ۲. متغیرهای لازم برای تست را تعریف می‌کنیم
  late MarketDataBloc marketDataBloc;
  late MockMarketRepository mockMarketRepository;

  // این تابع قبل از اجرای هر تست فراخوانی می‌شود
  setUp(() {
    mockMarketRepository = MockMarketRepository();
    marketDataBloc = MarketDataBloc(marketRepository: mockMarketRepository);
  });

  // این تابع بعد از اجرای هر تست فراخوانی می‌شود تا منابع آزاد شوند
  tearDown(() {
    marketDataBloc.close();
  });

  // یک نمونه داده برای استفاده در تست موفقیت‌آمیز
  final tMarketData = const MarketData(stores: [], categories: [], products: []);

  test('حالت اولیه باید MarketDataInitial باشد', () {
    expect(marketDataBloc.state, isA<MarketDataInitial>());
  });

  group('FetchMarketDataEvent', () {
    // سناریوی تست برای زمانی که داده‌ها با موفقیت دریافت می‌شوند
    blocTest<MarketDataBloc, MarketDataState>(
      'باید حالت‌های [Loading, Loaded] را منتشر کند وقتی داده موفقیت‌آمیز است',
      build: () {
        // ۳. رفتار Mock را تعریف می‌کنیم: اگر getMarketData فراخوانی شد، یک نتیجه موفق برگردان
        when(() => mockMarketRepository.getMarketData())
            .thenAnswer((_) async => Right(tMarketData));
        return marketDataBloc;
      },
      act: (bloc) => bloc.add(FetchMarketDataEvent()), // ۴. رویداد (Event) را به BLoC ارسال می‌کنیم
      expect: () => [ // ۵. انتظار داریم که BLoC این حالت‌ها را به ترتیب منتشر کند
        isA<MarketDataLoading>(),
        isA<MarketDataLoaded>(),
      ],
      verify: (_) {
        // ۶. اطمینان حاصل می‌کنیم که متد getMarketData دقیقاً یک بار فراخوانی شده است
        verify(() => mockMarketRepository.getMarketData()).called(1);
      },
    );

    // سناریوی تست برای زمانی که خطا رخ می‌دهد
    blocTest<MarketDataBloc, MarketDataState>(
      'باید حالت‌های [Loading, Error] را منتشر کند وقتی خطا رخ می‌دهد',
      build: () {
        // رفتار Mock را برای حالت خطا تعریف می‌کنیم
        when(() => mockMarketRepository.getMarketData())
            .thenAnswer((_) async => const Left(ServerFailure('API Failure')));
        return marketDataBloc;
      },
      act: (bloc) => bloc.add(FetchMarketDataEvent()),
      expect: () => [
        isA<MarketDataLoading>(),
        isA<MarketDataError>(),
      ],
      verify: (_) {
        verify(() => mockMarketRepository.getMarketData()).called(1);
      },
    );
  });
}