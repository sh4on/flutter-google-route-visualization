import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travel_time/screen/map_route_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapRouteScreen(),
    ),
  );
}
