import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_time/screen/widgets/travel_mode_selector.dart';
import 'package:travel_time/screen/widgets/travel_stats_card.dart';

import '../controller/map_route_controller.dart';

class MapRouteScreen extends StatelessWidget {
  const MapRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MapRouteController controller = Get.put(MapRouteController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Route Visualization"),
        actions: [TravelModeSelector(controller: controller)],
      ),
      body: Stack(
        children: [
          // map
          Obx(
            () => GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: MapRouteController.startLocation,
                zoom: 7,
              ),
              markers: controller.markers.toSet(),
              polylines: controller.polylines.toSet(),
              onMapCreated: controller.onMapCreated,
            ),
          ),

          // time & distance
          TravelStatsCard(controller: controller),
        ],
      ),
    );
  }
}
