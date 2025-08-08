// lib/features/home/presentation/cubit/location_state.dart
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationState extends Equatable {
  const LocationState();
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final Position position;
  final String address;

  const LocationLoaded({required this.position, required this.address});

  @override
  List<Object?> get props => [position, address];
}

class LocationError extends LocationState {
  final String message;

  const LocationError({required this.message});

  @override
  List<Object?> get props => [message];
}