import 'package:flutter/material.dart'; // <<<--- مشکل اصلی اینجا بود و برطرف شد
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_cubit.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_state.dart';
import 'package:persia_markt/l10n/app_localizations.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onSearchTapped;
  const HomeHeader({super.key, required this.onSearchTapped});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SliverAppBar(
      pinned: true,
      floating: true,
      expandedHeight: 180,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.orange.shade400, Colors.orange.shade100],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/appLogo.png', height: 40),
                      const SizedBox(width: 8),
                      Text(
                        l10n.persiaMarkt,
                        style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const Spacer(),
                      BlocBuilder<LocationCubit, LocationState>(
                        builder: (context, state) {
                          String locationText = l10n.gettingLocation;
                          if (state is LocationLoaded) {
                            locationText = state.address;
                          } else if (state is LocationError) {
                            locationText = l10n.locationUnknown;
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(l10n.yourLocation, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                              Text(locationText, style: const TextStyle(color: Colors.white, fontSize: 14)),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: onSearchTapped,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey.shade500),
                          const SizedBox(width: 8),
                          Text(l10n.searchHint, style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}