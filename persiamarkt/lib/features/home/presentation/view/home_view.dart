import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/config/app_routes.dart';
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
import 'package:persia_markt/l10n/app_localizations.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: l10n.localeName == 'fa' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: BlocBuilder<MarketDataBloc, MarketDataState>(
          builder: (context, state) {
            if (state is MarketDataInitial) {
              return _InitialLoadingView();
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

              if (marketData.stores.isEmpty && marketData.categories.isEmpty) {
                return AppErrorView(
                  message: l10n.noDataAvailable,
                  onRetry: () => context.read<MarketDataBloc>().add(FetchMarketDataEvent()),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<MarketDataBloc>().add(FetchMarketDataEvent());
                },
                child: CustomScrollView(
                  slivers: [
                    // ==================== اصلاح اصلی اینجاست ====================
                    // برای رفتن به صفحه جستجو از push استفاده می‌کنیم تا دکمه بازگشت کار کند
                    HomeHeader(onSearchTapped: () => context.push(AppRoutes.search)),
                    // ==========================================================
                    SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 24),
                        CategoryListView(categories: marketData.categories),
                        SectionDivider(title: l10n.specialOffers),
                        const BannerCarouselView(
                          bannerImageUrls: [
                            'assets/images/banner1.png',
                            'assets/images/banner2.png',
                            'assets/images/banner3.png',
                          ],
                        ),
                        SectionDivider(title: l10n.affordableProducts),
                        AffordableProductsSection(
                          products: marketData.products,
                          stores: marketData.stores,
                        ),
                        SectionDivider(title: l10n.stores),
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

class _InitialLoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            l10n.connectingToServer,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              l10n.initialLoadingMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
