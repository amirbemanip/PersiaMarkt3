import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/core/constants/app_constants.dart';
import 'package:persia_markt/features/map/data/services/map_boundary_service.dart';
import 'package:persia_markt/features/map/presentation/cubit/map_boundary_state.dart';

class MapBoundaryCubit extends Cubit<MapBoundaryState> {
  final MapBoundaryService _boundaryService;

  MapBoundaryCubit(this._boundaryService) : super(MapBoundaryInitial());

  Future<void> fetchBoundaries() async {
    emit(MapBoundaryLoading());
    try {
      final boundaries =
          await _boundaryService.getBoundariesForCities(AppConstants.germanCitiesForUI);
      emit(MapBoundaryLoaded(boundaries));
    } catch (e) {
      emit(MapBoundaryError(e.toString()));
    }
  }
}