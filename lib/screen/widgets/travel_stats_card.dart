import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/map_route_controller.dart';
import '../../utils/helper_methods/helper_methods.dart';

class TravelStatsCard extends StatelessWidget {
  final MapRouteController controller;

  const TravelStatsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: kBottomNavigationBarHeight,
      left: MediaQuery.of(context).size.width * 0.05,
      right: MediaQuery.of(context).size.width * 0.05,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Obx(
            () => controller.status.value.isLoading
                ? const SizedBox(
                    height: 50,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // duration
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, color: Colors.teal),
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
                          Icon(
                            getIconForMode(controller.currentTravelMode.value),
                            color: Colors.teal,
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
    );
  }
}
