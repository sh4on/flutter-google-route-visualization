import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../../controller/map_route_controller.dart';

class TravelModeSelector extends StatelessWidget {
  final MapRouteController controller;

  const TravelModeSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TravelMode>(
      icon: const Icon(Icons.directions, color: Colors.teal),
      onSelected: (TravelMode result) {
        controller.updateTravelMode(result);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<TravelMode>>[
        const PopupMenuItem<TravelMode>(
          value: TravelMode.driving,
          child: Row(
            children: [
              Icon(Icons.directions_car, color: Colors.teal),
              SizedBox(width: 8),
              Text('Driving'),
            ],
          ),
        ),
        const PopupMenuItem<TravelMode>(
          value: TravelMode.walking,
          child: Row(
            children: [
              Icon(Icons.directions_walk, color: Colors.teal),
              SizedBox(width: 8),
              Text('Walking'),
            ],
          ),
        ),
        const PopupMenuItem<TravelMode>(
          value: TravelMode.bicycling,
          child: Row(
            children: [
              Icon(Icons.directions_bike, color: Colors.teal),
              SizedBox(width: 8),
              Text('Bicycling'),
            ],
          ),
        ),
        const PopupMenuItem<TravelMode>(
          value: TravelMode.transit,
          child: Row(
            children: [
              Icon(Icons.directions_bus, color: Colors.teal),
              SizedBox(width: 8),
              Text('Transit'),
            ],
          ),
        ),
      ],
    );
  }
}
