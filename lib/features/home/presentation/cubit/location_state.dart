// lib/features/home/presentation/cubit/location_state.dart
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

/// Base class for all location-related states.
abstract class LocationState extends Equatable {
  const LocationState();
  @override
  List<Object?> get props => [];
}

/// The initial state before any location fetching has started.
class LocationInitial extends LocationState {}

/// The state while the location is being fetched.
class LocationLoading extends LocationState {}

/// The state when the location has been successfully fetched.
class LocationLoaded extends LocationState {
  final Position position;
  final String address;

  const LocationLoaded({required this.position, required this.address});

  @override
  List<Object?> get props => [position, address];
}

/// The state when an error occurs during location fetching.
class LocationError extends LocationState {
  final String message;

  const LocationError({required this.message});

  @override
  List<Object?> get props => [message];
}