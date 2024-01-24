import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:osm_project/src/search.dart';
import 'geofinder.dart';
import 'geocontroller.dart';

class MainExample extends StatefulWidget {
  //MainExample({Key? key}) : super(key: key);
  MainExample(
      {super.key,
      required this.focusedLocation,
      required this.focusedMarkerHighlight});
  late bool gpsTracking = false;
  late Icon gpsIcon = gpsIconSwitcher(false);
  final GeoPoint focusedLocation;
  final bool focusedMarkerHighlight;

  @override
  State<MainExample> createState() => _MainExampleState();
}

class _MainExampleState extends State<MainExample> with OSMMixinObserver {
  late MapController controller;
  late GlobalKey<ScaffoldState> scaffoldKey;
  Key mapGlobalkey = UniqueKey();
  ValueNotifier<GeoPoint?> centerMap = ValueNotifier(null);
  Timer? timer;
  late MarkerMap allMarkers = {};
  late MarkerMap visibleMarkers = {};
  /*ValueNotifier<bool> zoomNotifierActivation = ValueNotifier(false);
  ValueNotifier<bool> visibilityZoomNotifierActivation = ValueNotifier(false);
  ValueNotifier<bool> advPickerNotifierActivation = ValueNotifier(false);
  ValueNotifier<bool> visibilityOSMLayers = ValueNotifier(false);
  ValueNotifier<double> positionOSMLayers = ValueNotifier(-200);
  ValueNotifier<bool> trackingNotifier = ValueNotifier(false);
  ValueNotifier<bool> showFab = ValueNotifier(true);
  ValueNotifier<GeoPoint?> lastGeoPoint = ValueNotifier(null);
  ValueNotifier<bool> beginDrawRoad = ValueNotifier(false);
  List<GeoPoint> pointsRoad = [];
  int x = 0;*/

  Future<void> initAllMarkers() async {
    List<String> types = ['pharmacy', 'clinic', 'hospital'];
    for (var t in types) {
      GeoFinder gf = GeoFinder(t);
      List<Location> l = await gf.getLocations();
      for (var i in l) {
        var metadata = <String, String>{};
        metadata['name'] = i.name;
        if (i.data.containsKey('addr')) {
          metadata['addr'] = i.data['addr']!;
        }
        if (i.data.containsKey('phone')) {
          metadata['phone'] = i.data['phone']!;
        }
        if (i.data.containsKey('email')) {
          metadata['email'] = i.data['email']!;
        }
        if (i.data.containsKey('website')) {
          metadata['website'] = i.data['website']!;
        }
        metadata['type'] = t;
        allMarkers[GeoPoint(latitude: i.latitude, longitude: i.longitude)] =
            metadata;
      }
    }
  }

  Future<void> showVisibleMarkers() async {
    for (var k in visibleMarkers.keys) {
      GeoTypes type =
          GeoTypes.values.byName(visibleMarkers[k]?['type'] ?? "hospital");
      await controller.addMarker(k, markerIcon: type.mapIcon());
    }
  }

  Future<MarkerMap> getNewVisibleMarkers() async {
    BoundingBox bounds = await controller.bounds;
    MarkerMap newVisible = {};
    for (var k in allMarkers.keys) {
      if (isInside(k.latitude, k.longitude, bounds)) {
        newVisible[k] = allMarkers[k]!;
      }
    }
    return newVisible;
  }

  Future<MarkerMap> markersToAdd(MarkerMap prev, MarkerMap curr) async {
    MarkerMap addToVisible = {};
    for (var k in curr.keys) {
      if (!prev.containsKey(k)) addToVisible[k] = curr[k]!;
    }
    return addToVisible;
  }

  Future<MarkerMap> markersToDelete(MarkerMap prev, MarkerMap curr) async {
    MarkerMap deleteFromVisible = {};
    for (var k in prev.keys) {
      if (!curr.containsKey(k)) deleteFromVisible[k] = prev[k]!;
    }
    return deleteFromVisible;
  }

  Future<void> deleteMarkers(MarkerMap markers) async {
    await controller.removeMarkers(markers.keys.toList());
  }

  Future<void> addMarkers(MarkerMap markers) async {
    var z = await controller.getZoom();
    for (var k in markers.keys) {
      String type = markers[k]!['type'] ?? "null";
      GeoTypes gtype =
          GeoTypes.values.byName(markers[k]?['type'] ?? "hospital");
      if (randomMarkerPicker(z, type)) {
        await controller.addMarker(k, markerIcon: gtype.mapIcon());
      }
    }
  }

  List<Widget> appIcons() {
    List<Widget> icons = [
      IconButton(
        onPressed: () async {
          setState(() {
            widget.gpsTracking = !widget.gpsTracking;
            widget.gpsIcon = gpsIconSwitcher(widget.gpsTracking);
          });
          if (widget.gpsTracking) {
            await controller.enableTracking();
          } else {
            await controller.disabledTracking();
          }
        },
        icon: widget.gpsIcon,
        iconSize: 30,
      )
    ];
    if (!widget.focusedMarkerHighlight) {
      icons.add(IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SearchView(
                          markers: allMarkers,
                          mapCenter: centerMap.value!,
                        )));
          },
          icon: const Icon(
            Icons.search,
            color: Colors.white,
            size: 26,
          )));
    } else {
      icons.add(IconButton(
          onPressed: () async {
            await controller.clearAllRoads();
            await controller.drawRoad(
                await controller.centerMap, widget.focusedLocation,
                roadOption: const RoadOption(roadColor: Colors.blueAccent));
          },
          icon:
              const Icon(Icons.route_outlined, color: Colors.white, size: 26)));
    }
    return icons;
  }

  @override
  void initState() {
    super.initState();
    controller = MapController.withPosition(
        initPosition: GeoPoint(
          latitude: widget.focusedLocation.latitude,
          longitude: widget.focusedLocation.longitude,
        ),
        areaLimit: BoundingBox(
            north: 54.8515359564,
            east: 24.0299857927,
            south: 49.0273953314,
            west: 14.0745211117));
    controller.addObserver(this);
    scaffoldKey = GlobalKey<ScaffoldState>();
    controller.listenerRegionIsChanging.addListener(() async {
      if (controller.listenerRegionIsChanging.value != null) {
        //print(controller.listenerRegionIsChanging.value);
        centerMap.value = controller.listenerRegionIsChanging.value!.center;
        if (widget.focusedMarkerHighlight) {
          controller.drawCircle(CircleOSM(
              key: 'focused',
              centerPoint: widget.focusedLocation,
              radius: 50,
              color: const Color.fromRGBO(255, 0, 0, 0.5),
              strokeWidth: 3));
        }
      }
    });
  }

  Future<void> mapIsInitialized() async {
    await controller.goToLocation(widget.focusedLocation);
    await initAllMarkers();
    //print(bounds.toString());
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      await mapIsInitialized();
      visibleMarkers = await getNewVisibleMarkers();
      await showVisibleMarkers();
    }
  }

  @override
  void dispose() {
    if (timer != null && timer!.isActive) timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('GeoOSM'), actions: appIcons()),
      body: Stack(
        children: [
          OSMFlutter(
            controller: controller,
            userTrackingOption: const UserTrackingOption(enableTracking: false),
            initZoom: 15,
            minZoomLevel: 8,
            maxZoomLevel: 19,
            stepZoom: 0.1,
            userLocationMarker: UserLocationMaker(
              personMarker: const MarkerIcon(
                icon: Icon(
                  Icons.location_history_rounded,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              directionArrowMarker: const MarkerIcon(
                icon: Icon(
                  Icons.double_arrow,
                  size: 48,
                ),
              ),
            ),
            roadConfiguration: const RoadOption(
              roadColor: Colors.yellowAccent,
            ),
            markerOption: MarkerOption(
                defaultMarker: const MarkerIcon(
              icon: Icon(
                Icons.person_pin_circle,
                color: Colors.blue,
                size: 56,
              ),
            )),
          ),
          const Positioned.fill(
              child: Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.add,
                    size: 24,
                  )))
        ],
      ),
    );
  }

  /*@override
  Future<void> mapRestored() async {
    super.mapRestored();
    //print("log map restored");
  }*/

  @override
  Future<void> onRegionChanged(Region region) async {
    super.onRegionChanged(region);
    MarkerMap newVisibility = await getNewVisibleMarkers();
    MarkerMap toDel = await markersToDelete(visibleMarkers, newVisibility);
    MarkerMap toAdd = await markersToAdd(visibleMarkers, newVisibility);
    await deleteMarkers(toDel);
    await addMarkers(toAdd);
    visibleMarkers = newVisibility;
  }
}
