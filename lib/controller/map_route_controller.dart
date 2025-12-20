import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapRouteController extends GetxController {
  final String apiKey = dotenv.get('API_KEY');
  final Dio _dio = Dio();

  static const LatLng startLocation = LatLng(40.7128, -74.0060);
  static const LatLng endLocation = LatLng(39.9526, -75.1652);

  GoogleMapController? mapController;

  RxSet<Marker> markers = <Marker>{}.obs;
  RxSet<Polyline> polylines = <Polyline>{}.obs;
  Rxn<String> distance = Rxn<String>();
  Rxn<String> duration = Rxn<String>();
  Rx<RxStatus> status = Rx<RxStatus>(RxStatus.loading());
  Rx<TravelMode> currentTravelMode = TravelMode.driving.obs;

  @override
  void onInit() {
    super.onInit();
    _addInitialMarkers();
    _fetchData();
  }

  // add start and end markers
  void _addInitialMarkers() {
    markers.add(
      const Marker(markerId: MarkerId('start'), position: startLocation),
    );
    markers.add(const Marker(markerId: MarkerId('end'), position: endLocation));
  }

  // update selected travel mode
  void updateTravelMode(TravelMode mode) {
    currentTravelMode.value = mode;
    status.value = RxStatus.loading();
    polylines.clear();
    _fetchData();
  }

  // fetch both visual route, time & distance
  void _fetchData() async {
    await Future.wait([fetchRoutePolylines(), fetchTravelStats()]);
  }

  // callback when map ready
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (polylines.isNotEmpty) {
      fitBounds();
    }
  }

  // adjusts camera zoom to ensure start and end points visible
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

  // fetch distance & duration
  Future<void> fetchTravelStats() async {
    String modeStr = currentTravelMode.value.toString().split('.').last;

    final String url =
        "https://maps.googleapis.com/maps/api/distancematrix/json"
        "?origins=${startLocation.latitude},${startLocation.longitude}"
        "&destinations=${endLocation.latitude},${endLocation.longitude}"
        "&mode=$modeStr"
        "&key=$apiKey";

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final element = response.data['rows'][0]['elements'][0];

        if (element['status'] == 'OK') {
          distance.value = element['distance']['text'];
          duration.value = element['duration']['text'];
          status.value = RxStatus.success();
        } else {
          distance.value = null;
          duration.value = "No Route";
          status.value = RxStatus.success();
        }
      }
    } catch (e) {
      debugPrint("Network Error: $e");
      status.value = RxStatus.error(e.toString());
    }
  }

  // fetches coordinate points to draw the route line
  Future<void> fetchRoutePolylines() async {
    PolylinePoints polylinePoints = PolylinePoints(apiKey: apiKey);

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(startLocation.latitude, startLocation.longitude),
          destination: PointLatLng(endLocation.latitude, endLocation.longitude),
          mode: currentTravelMode.value,
        ),
      );

      if (result.points.isNotEmpty) {
        List<LatLng> coordinates = result.points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();

        polylines.clear();
        polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.teal,
            points: coordinates,
            width: 5,
          ),
        );
        fitBounds();
      } else {
        debugPrint("No polyline points found");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}
