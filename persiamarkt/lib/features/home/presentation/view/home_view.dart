// lib/features/home/presentation/view/home_view.dart
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
            if (state is MarketDataLoading || state is MarketDataInitial) {
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