import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/widgets/error_view.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_event.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';
import 'package:persia_markt/features/home/presentation/widgets/affordable_products_section.dart';
import 'package:persia_markt/features/home/presentation/widgets/banner_carousel_view.dart';
import 'package:persia_markt/features/home/presentation/widgets/category_list_view.dart';
import 'package:persia_markt/features/home/presentation/widgets/home_header.dart';
import 'package:persia_markt/features/home/presentation/widgets/home_loading_shimmer.dart';
import 'package:persia_markt/features/home/presentation/widgets/section_divider.dart';
import 'package:persia_markt/features/home/presentation/widgets/stores_by_city_section.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BlocBuilder<MarketDataBloc, MarketDataState>(
          builder: (context, state) {
            // --- FIXED: Improved loading and error states ---
            if (state is MarketDataInitial) {
              // Show a specific message for the very first load
              return const _InitialLoadingView();
            }
            if (state is MarketDataLoading) {
              return const HomeLoadingShimmer();
            }
            if (state is MarketDataError) {
              return AppErrorView(
                message: state.message,
                onRetry: () => context.read<MarketDataBloc>().add(FetchMarketDataEvent()),
              );
            }
            if (state is MarketDataLoaded) {
              final marketData = state.marketData;
              // Handle case where data is loaded but lists are empty
              if (marketData.stores.isEmpty && marketData.categories.isEmpty) {
                return AppErrorView(
                  message: 'متاسفانه در حال حاضر فروشگاه یا محصولی برای نمایش وجود ندارد.',
                  onRetry: () => context.read<MarketDataBloc>().add(FetchMarketDataEvent()),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<MarketDataBloc>().add(FetchMarketDataEvent());
                },
                child: CustomScrollView(
                  slivers: [
                    HomeHeader(onSearchTapped: () => context.go('/search')),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 24),
                        CategoryListView(categories: marketData.categories),
                        const SectionDivider(title: 'پیشنهادهای ویژه'),
                        const BannerCarouselView(
                          bannerImageUrls: [
                            'assets/images/banner1.png',
                            'assets/images/banner2.png',
                            'assets/images/banner3.png',
                          ],
                        ),
                        const SectionDivider(title: 'محصولات مقرون به صرفه'),
                        AffordableProductsSection(
                          products: marketData.products,
                          stores: marketData.stores,
                        ),
                        const SectionDivider(title: 'فروشگاه‌ها'),
                        StoresByCitySection(stores: marketData.stores),
                        const SizedBox(height: 50),
                      ]),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

/// A dedicated widget for the initial loading screen.
class _InitialLoadingView extends StatelessWidget {
  const _InitialLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'در حال اتصال به سرور...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'بارگذاری اولیه ممکن است کمی طول بکشد. لطفاً صبور باشید.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
