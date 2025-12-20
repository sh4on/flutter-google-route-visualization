import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';

class MapRouteController extends GetxController {
  final String apiKey = "AIzaSyDuK0UE4AL3t2CUHDSqyQ8HqX6cqysHFeI";
  final Dio _dio = Dio();

  static const LatLng startLocation = LatLng(40.7128, -74.0060);
  static const LatLng endLocation = LatLng(39.9526, -75.1652);

  GoogleMapController? mapController;

  RxSet<Marker> markers = <Marker>{}.obs;
  RxSet<Polyline> polylines = <Polyline>{}.obs;
  Rxn<String> distance = Rxn<String>();
  Rxn<String> duration = Rxn<String>();
  RxBool isLoadingInfo = true.obs;

  @override
  void onInit() {
    super.onInit();
    _addInitialMarkers();
    fetchRoutePolylines();
    fetchTravelStats();
  }

  void _addInitialMarkers() {
    markers.add(
      const Marker(markerId: MarkerId('start'), position: startLocation),
    );
    markers.add(const Marker(markerId: MarkerId('end'), position: endLocation));
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (polylines.isNotEmpty) {
      fitBounds();
    }
  }

  void fitBounds() {
    if (mapController == null) return;

    LatLngBounds bounds;
    if (startLocation.latitude > endLocation.latitude) {
      bounds = LatLngBounds(southwest: endLocation, northeast: startLocation);
    } else {
      bounds = LatLngBounds(southwest: startLocation, northeast: endLocation);
    }

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  Future<void> fetchTravelStats() async {
    final String url =
        "https://maps.googleapis.com/maps/api/distancematrix/json"
        "?origins=${startLocation.latitude},${startLocation.longitude}"
        "&destinations=${endLocation.latitude},${endLocation.longitude}"
        "&mode=driving"
        "&key=$apiKey";

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final element = response.data['rows'][0]['elements'][0];

        if (element['status'] == 'OK') {
          distance.value = element['distance']['text'];
          duration.value = element['duration']['text'];
          isLoadingInfo.value = false;
        }
      }
    } catch (e) {
      debugPrint("Network Error: $e");
      isLoadingInfo.value = false;
    }
  }

  Future<void> fetchRoutePolylines() async {
    PolylinePoints polylinePoints = PolylinePoints(apiKey: apiKey);

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(startLocation.latitude, startLocation.longitude),
          destination: PointLatLng(endLocation.latitude, endLocation.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        List<LatLng> coordinates = result.points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();

        polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue,
            points: coordinates,
            width: 5,
          ),
        );

        fitBounds();
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}
