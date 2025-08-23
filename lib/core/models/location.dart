// lib/core/models/location.dart
import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final double lat;
  final double lng;

  const Location({required this.lat, required this.lng});

  @override
  List<Object> get props => [lat, lng];

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}