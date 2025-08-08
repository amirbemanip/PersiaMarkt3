// lib/features/home/presentation/cubit/location_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/core/services/location_service.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationService _locationService;

  LocationCubit({required LocationService locationService})
      : _locationService = locationService,
        super(LocationInitial());

  Future<void> fetchLocation() async {
    emit(LocationLoading());
    try {
      final position = await _locationService.getCurrentPosition();
      final address = await _locationService.getAddressFromPosition(position);
      emit(LocationLoaded(position: position, address: address));
    } catch (e) {
      emit(LocationError(message: e.toString()));
    }
  }
}