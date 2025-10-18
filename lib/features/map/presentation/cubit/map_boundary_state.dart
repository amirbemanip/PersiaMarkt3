import 'package:equatable/equatable.dart';
import 'package:persia_markt/features/map/data/services/map_boundary_service.dart';

abstract class MapBoundaryState extends Equatable {
  const MapBoundaryState();

  @override
  List<Object> get props => [];
}

class MapBoundaryInitial extends MapBoundaryState {}

class MapBoundaryLoading extends MapBoundaryState {}

class MapBoundaryLoaded extends MapBoundaryState {
  final List<CityBoundary> boundaries;

  const MapBoundaryLoaded(this.boundaries);

  @override
  List<Object> get props => [boundaries];
}

class MapBoundaryError extends MapBoundaryState {
  final String message;

  const MapBoundaryError(this.message);

  @override
  List<Object> get props => [message];
}