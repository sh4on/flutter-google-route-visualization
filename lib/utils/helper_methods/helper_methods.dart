import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

IconData getIconForMode(TravelMode mode) {
  switch (mode) {
    case TravelMode.driving:
      return Icons.directions_car;
    case TravelMode.walking:
      return Icons.directions_walk;
    case TravelMode.bicycling:
      return Icons.directions_bike;
    case TravelMode.transit:
      return Icons.directions_bus;
    default:
      return Icons.directions_car;
  }
}
