// lib/features/home/presentation/widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_cubit.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_state.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onSearchTapped;
  const HomeHeader({Key? key, required this.onSearchTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                        'PersiaMarkt',
                        style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const Spacer(),
                      BlocBuilder<LocationCubit, LocationState>(
                        builder: (context, state) {
                          String locationText = 'در حال دریافت موقعیت...';
                          if (state is LocationLoaded) {
                            locationText = state.address;
                          } else if (state is LocationError) {
                            locationText = 'موقعیت نامعلوم';
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('موقعیت شما', style: TextStyle(color: Colors.white70, fontSize: 10)),
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
                          Text('جستجوی نان، شیر، فروشگاه...', style: TextStyle(color: Colors.grey.shade500)),
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