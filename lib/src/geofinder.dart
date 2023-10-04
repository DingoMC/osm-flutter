import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class GeoFinder {
  String searchType = 'hospital';
  GeoFinder(this.searchType);
  late List<Location> _cachedList;

  String getFileName() {
    switch (searchType) {
      case "hospital":
        return "hospitals";
      case "clinic":
        return "clinics";
      case "pharmacy":
        return "pharmacies";
      default:
        return "hospitals";
    }
  }

  Future<List<Location>> getLocations() async {
    Map<dynamic, dynamic> json = await _getJsonFromFile(getFileName());
    _cachedList = _jsonToLocations(json);
    return _cachedList;
  }

  Future<Map<dynamic, dynamic>> _getJsonFromFile(String fileName) async {
    String jsonString =
        await rootBundle.loadString('assets/locations/$fileName.json');
    return jsonDecode(jsonString);
  }

  List<Location> _jsonToLocations(Map<dynamic, dynamic> json) {
    List<Location> locations = [];
    for (var element in json["elements"]) {
      Location l = Location.fromJson(element, searchType);
      if (l.latitude != -1 && l.longitude != -1 && l.name != "null") {
        locations.add(l);
      }
    }
    return locations;
  }
}

Map<String, String> locationData(Map<dynamic, dynamic> json) {
  Map<String, String> data = {};
  if (json.containsKey('tags')) {
    if (json['tags'].containsKey('addr:city')) {
      if (json['tags'].containsKey('addr:street')) {
        data['addr'] = json['tags']['addr:city'] +
                ', ' +
                json['tags']['addr:street'] +
                ' ' +
                (json['tags'].containsKey('addr:housenumber')
            ? json['tags']['addr:housenumber']
            : '');
      } else {
        data['addr'] = json['tags']['addr:city'] +
                ' ' +
                (json['tags'].containsKey('addr:housenumber')
            ? json['tags']['addr:housenumber']
            : '');
      }
    }
    if (json['tags'].containsKey('phone')) {
      data['phone'] = json['tags']['phone'];
    }
    if (json['tags'].containsKey('contact:phone')) {
      data['phone'] = json['tags']['contact:phone'];
    }
    if (json['tags'].containsKey('email')) {
      data['email'] = json['tags']['email'];
    }
    if (json['tags'].containsKey('contact:email')) {
      data['email'] = json['tags']['contact:email'];
    }
    if (json['tags'].containsKey('website')) {
      data['website'] = json['tags']['website'];
    }
    if (json['tags'].containsKey('contact:website')) {
      data['website'] = json['tags']['contact:website'];
    }
  }
  return data;
}

class Location {
  final double longitude;
  final double latitude;
  final String name;
  final String type;
  final Map<String, String> data;
  Location(
      {required this.longitude,
      required this.latitude,
      required this.name,
      required this.type,
      required this.data});
  Location.fromJson(Map<dynamic, dynamic> json, String searchType)
      : longitude = (json.containsKey('lon') ? json['lon'] : -1),
        latitude = (json.containsKey('lat') ? json['lat'] : -1),
        name = (json.containsKey('tags')
            ? (json['tags'].containsKey('name') ? json['tags']['name'] : "null")
            : "null"),
        type = searchType,
        data = locationData(json);
}
