import 'package:flutter/material.dart';
import 'package:osm_project/src/home.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/home",
      routes: {
        "/home": (ctx) => MainExample(
              focusedLocation: GeoPoint(
                latitude: 51.2408822,
                longitude: 22.5449109,
              ),
              focusedMarkerHighlight: false,
            )
      },
    );
  }
}
