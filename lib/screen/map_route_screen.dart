import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controller/map_route_controller.dart';

class MapRouteScreen extends StatelessWidget {
  const MapRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MapRouteController controller = Get.put(MapRouteController());

    return Scaffold(
      appBar: AppBar(title: const Text("Google Route Visualization")),
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
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                child: Obx(
                  () => controller.isLoadingInfo.value
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // time
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  controller.duration.value ?? "--",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Text(
                                  "Duration",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),

                            // vertical bar
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),

                            // distance
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.directions_car,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  controller.distance.value ?? "--",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Text(
                                  "Distance",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
