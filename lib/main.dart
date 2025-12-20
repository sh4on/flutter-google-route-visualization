// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
//
// void main() {
//   runApp(
//     const MaterialApp(
//       home: TravelTimeTest(),
//       debugShowCheckedModeBanner: false,
//     ),
//   );
// }
//
// class MapService {
//   // Using the API key you provided
//   final String apiKey = "AIzaSyDuK0UE4AL3t2CUHDSqyQ8HqX6cqysHFeI";
//   final Dio _dio = Dio();
//
//   Future<Map<String, dynamic>?> getTravelInfo(
//     double startLat,
//     double startLng,
//     double endLat,
//     double endLng,
//   ) async {
//     final String url =
//         "https://maps.googleapis.com/maps/api/distancematrix/json"
//         "?origins=$startLat,$startLng"
//         "&destinations=$endLat,$endLng"
//         "&mode=driving"
//         "&key=$apiKey";
//
//     try {
//       final response = await _dio.get(url);
//
//       if (response.statusCode == 200 && response.data['status'] == 'OK') {
//         final element = response.data['rows'][0]['elements'][0];
//
//         if (element['status'] == 'OK') {
//           return {
//             "time": element['duration']['text'],
//             "distance": element['distance']['text'],
//             "seconds": element['duration']['value'],
//           };
//         } else {
//           debugPrint("Route error: ${element['status']}");
//         }
//       }
//     } catch (e) {
//       debugPrint("Network Error: $e");
//     }
//     return null;
//   }
// }
//
// class TravelTimeTest extends StatefulWidget {
//   const TravelTimeTest({super.key});
//
//   @override
//   State<TravelTimeTest> createState() => _TravelTimeTestState();
// }
//
// class _TravelTimeTestState extends State<TravelTimeTest> {
//   final MapService _mapService = MapService();
//   String _result = "Tap the button to calculate";
//   bool _isLoading = false;
//
//   // Example Coordinates: New York City to Philadelphia
//   final double startLat = 40.7128;
//   final double startLng = -74.0060;
//   final double endLat = 39.9526;
//   final double endLng = -75.1652;
//
//   void _calculateTime() async {
//     setState(() => _isLoading = true);
//
//     final data = await _mapService.getTravelInfo(
//       startLat,
//       startLng,
//       endLat,
//       endLng,
//     );
//
//     setState(() {
//       if (data != null) {
//         _result = "Distance: ${data['distance']}\nDuration: ${data['time']}";
//       } else {
//         _result = "Failed to get data. Check API key or connection.";
//       }
//       _isLoading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Google Travel Time Test")),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.directions_car, size: 80, color: Colors.blue),
//               const SizedBox(height: 20),
//               Text(
//                 "NYC to Philadelphia",
//                 style: Theme.of(context).textTheme.headlineSmall,
//               ),
//               const SizedBox(height: 10),
//               _isLoading
//                   ? const CircularProgressIndicator()
//                   : Text(
//                       _result,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(fontSize: 18),
//                     ),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _calculateTime,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 40,
//                     vertical: 15,
//                   ),
//                 ),
//                 child: const Text("Get Travel Info"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() => runApp(const MaterialApp(home: MapRouteScreen()));

class MapRouteScreen extends StatefulWidget {
  const MapRouteScreen({super.key});

  @override
  State<MapRouteScreen> createState() => _MapRouteScreenState();
}

class _MapRouteScreenState extends State<MapRouteScreen> {
  final String apiKey = "AIzaSyDuK0UE4AL3t2CUHDSqyQ8HqX6cqysHFeI";

  static const LatLng _startLocation = LatLng(40.7128, -74.0060);
  static const LatLng _endLocation = LatLng(39.9526, -75.1652);

  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      const Marker(markerId: MarkerId('start'), position: _startLocation),
    );
    _markers.add(
      const Marker(markerId: MarkerId('end'), position: _endLocation),
    );
    _getRoutePolylines();
  }

  Future<void> _getRoutePolylines() async {
    PolylinePoints polylinePoints = PolylinePoints(apiKey: apiKey);

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(
            _startLocation.latitude,
            _startLocation.longitude,
          ),
          destination: PointLatLng(
            _endLocation.latitude,
            _endLocation.longitude,
          ),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        setState(() {
          List<LatLng> coordinates = result.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();

          _polylines.add(
            Polyline(
              polylineId: const PolylineId("route"),
              color: Colors.yellow,
              points: coordinates,
              width: 5,
            ),
          );
        });

        _fitBounds();
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _fitBounds() {
    if (mapController == null) return;

    LatLngBounds bounds;
    if (_startLocation.latitude > _endLocation.latitude) {
      bounds = LatLngBounds(southwest: _endLocation, northeast: _startLocation);
    } else {
      bounds = LatLngBounds(southwest: _startLocation, northeast: _endLocation);
    }

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Route Visualization")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _startLocation,
          zoom: 7,
        ),
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (controller) {
          mapController = controller;
          if (_polylines.isNotEmpty) _fitBounds();
        },
      ),
    );
  }
}
