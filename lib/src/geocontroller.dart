import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:osm_project/src/home.dart';
import 'dart:math';
import 'palette.dart';

enum GeoTypes { all, hospital, clinic, pharmacy }

extension GeoTypeExtension on GeoTypes {
  String get name => describeEnum(this);
  String displayName() {
    switch (this) {
      case GeoTypes.hospital:
        return 'Szpital';
      case GeoTypes.clinic:
        return 'Przychodnia';
      case GeoTypes.pharmacy:
        return 'Apteka';
      default:
        return 'Wszystkie';
    }
  }

  Color color() {
    switch (this) {
      case GeoTypes.hospital:
        return CRoot.red.color(brightness: 0.33);
      case GeoTypes.clinic:
        return CRoot.blue.color();
      case GeoTypes.pharmacy:
        return CRoot.green.color(brightness: 0.33);
      default:
        return CRoot.gray.color(brightness: 0.67);
    }
  }

  MarkerIcon mapIcon() {
    switch (this) {
      case GeoTypes.hospital:
        return MarkerIcon(
            icon: Icon(Icons.local_hospital,
                color: color(), size: 48, opticalSize: 24));
      case GeoTypes.clinic:
        return MarkerIcon(
            icon: Icon(
          Icons.local_hospital_outlined,
          color: color(),
          size: 48,
          opticalSize: 24,
        ));
      case GeoTypes.pharmacy:
        return MarkerIcon(
            icon: Icon(Icons.local_pharmacy_outlined,
                color: color(), size: 44, opticalSize: 22));
      default:
        return MarkerIcon(
            icon: Icon(Icons.help_outline,
                color: color(), size: 40, opticalSize: 20));
    }
  }

  Icon icon() {
    switch (this) {
      case GeoTypes.hospital:
        return Icon(Icons.local_hospital,
            color: CRoot.red.color(brightness: 0.33),
            size: 44,
            opticalSize: 24);
      case GeoTypes.clinic:
        return Icon(
          Icons.local_hospital_outlined,
          color: CRoot.blue.color(),
          size: 44,
          opticalSize: 24,
        );
      case GeoTypes.pharmacy:
        return Icon(Icons.local_pharmacy_outlined,
            color: CRoot.green.color(brightness: 0.33),
            size: 44,
            opticalSize: 22);
      default:
        return Icon(Icons.help_outline,
            color: CRoot.gray.color(brightness: 0.67),
            size: 40,
            opticalSize: 20);
    }
  }
}

enum GeoUnits { m, km }

typedef MarkerMap = Map<GeoPoint, Map<String, String>>;

double distance(GeoPoint p1, GeoPoint p2) {
  const R = 6378137.0;
  double f1 = p1.latitude * pi / 180.0;
  double f2 = p2.latitude * pi / 180.0;
  double df = (p2.latitude - p1.latitude) * pi / 180.0;
  double dl = (p2.longitude - p1.longitude) * pi / 180.0;
  double a = sin(df / 2.0) * sin(df / 2.0) +
      cos(f1) * cos(f2) * sin(dl / 2.0) * sin(dl / 2.0);
  double c = 2 * atan2(sqrt(a), sqrt(1.0 - a));
  return R * c;
}

String distanceStr(double dist) {
  if (dist < 1000.0) return '${dist.toStringAsFixed(0)}m';
  if (dist < 10000.0) return '${(dist / 1000.0).toStringAsFixed(2)}km';
  if (dist < 100000.0) return '${(dist / 1000.0).toStringAsFixed(1)}km';
  return '${(dist / 1000.0).toStringAsFixed(0)}km';
}

class GeoResult {
  final GeoPoint location;
  final Map<String, String> geodata;
  final double distance;
  GeoResult(
      {required this.location, required this.geodata, required this.distance});
}

Widget emptyResultWidget() {
  return const Column(
    children: [Text('Brak wyników')],
  );
}

class ResultObject extends StatelessWidget {
  final GeoResult data;
  const ResultObject({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border:
              Border.all(color: CRoot.gray.color(brightness: 0.75), width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              GeoTypes.values.byName(data.geodata['type']!).icon(),
              Text(
                GeoTypes.values.byName(data.geodata['type']!).displayName(),
                style: TextStyle(
                    fontSize: 12,
                    color:
                        GeoTypes.values.byName(data.geodata['type']!).color()),
              )
            ],
          ),
        ),
        Expanded(
            flex: 8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  data.geodata['name']!,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CRoot.aqua.color(brightness: 0.1)),
                ),
                Text(
                  'Odległość: ${distanceStr(data.distance)}',
                  style: TextStyle(
                      fontSize: 14, color: CRoot.aqua.color(brightness: 0.2)),
                  textAlign: TextAlign.left,
                )
              ],
            )),
        Expanded(
            flex: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.map_sharp, color: Colors.blue, size: 26),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainExample(
                                  focusedLocation: data.location,
                                  focusedMarkerHighlight: true,
                                )));
                  },
                ),
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Szczegołowe informacje'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Nazwa: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Expanded(
                                        flex: 3,
                                        child: Text('${data.geodata["name"]}'))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Adres: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    (data.geodata.containsKey('addr')
                                        ? Expanded(
                                            flex: 3,
                                            child:
                                                Text('${data.geodata["addr"]}'))
                                        : const Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Brak danych',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey),
                                            )))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Telefon: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    (data.geodata.containsKey('phone')
                                        ? Expanded(
                                            flex: 3,
                                            child: Text(
                                                '${data.geodata["phone"]}'))
                                        : const Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Nie podano',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey),
                                            )))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Expanded(
                                        flex: 1,
                                        child: Text(
                                          'E-mail: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    (data.geodata.containsKey('email')
                                        ? Expanded(
                                            flex: 3,
                                            child: Text(
                                                '${data.geodata["email"]}'))
                                        : const Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Nie podano',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey),
                                            )))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Strona: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    (data.geodata.containsKey('website')
                                        ? Expanded(
                                            flex: 3,
                                            child: Text(
                                                '${data.geodata["website"]}'))
                                        : const Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Nie podano',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey),
                                            )))
                                  ],
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'))
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.info_outlined,
                        color: Colors.blue, size: 26))
              ],
            ))
      ]),
    );
    /*return Column(
      children: [Text(data.geodata['name']!), Text(distanceStr(data.distance))],
    );*/
  }
}

Icon gpsIconSwitcher(bool gpsState) {
  if (!gpsState) {
    return const Icon(
      Icons.gps_off,
      color: Color.fromRGBO(32, 0, 0, 1.0),
      size: 26,
    );
  } else {
    return const Icon(
      Icons.gps_fixed,
      color: Color.fromRGBO(55, 255, 55, 1.0),
      size: 26,
    );
  }
}

bool randomMarkerPicker(double zoom, String type) {
  if (zoom >= 15.0) return true; // For zoom > 15 it is ok to display everything
  // Otherwise it should be restricted
  int perZoom = 0;
  if (type == 'hospital') {
    perZoom = (1.0 + 99.0 * exp(zoom - 15.0)).toInt();
  } else {
    perZoom = ((8.0 - (1492.0 / 99.0)) ~/ (zoom - (1492.0 / 99.0)));
  }
  int sel = Random().nextInt(100);
  return (sel <= perZoom);
}

bool isInside(double lat, double lon, BoundingBox bounds) {
  return (lat >= bounds.south &&
      lat <= bounds.north &&
      lon >= bounds.west &&
      lon <= bounds.east);
}
