import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:osm_project/src/palette.dart';
import 'geocontroller.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.markers, required this.mapCenter});
  final MarkerMap markers;
  final GeoPoint mapCenter;
  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  GeoTypes selectedType = GeoTypes.all;
  GeoUnits selectedUnit = GeoUnits.m;
  List<GeoResult> foundMarkers = [];
  List<Widget> resultsWidget = [];
  final rController = TextEditingController();

  void findMarkers() {
    setState(() {
      foundMarkers = [];
      resultsWidget = [];
    });
    double radius =
        (rController.text.isEmpty) ? 0 : double.parse(rController.text);
    if (selectedUnit == GeoUnits.km) radius *= 1000.0;
    for (var k in widget.markers.keys) {
      String type = widget.markers[k]!['type'] ?? "null";
      if ((type == selectedType.name || selectedType == GeoTypes.all) &&
          distance(k, widget.mapCenter) <= radius) {
        setState(() {
          foundMarkers.add(GeoResult(
              location: k,
              geodata: widget.markers[k]!,
              distance: distance(k, widget.mapCenter)));
        });
      }
    }
    setState(() {
      foundMarkers.sort((a, b) => a.distance.compareTo(b.distance));
    });
    for (var i in foundMarkers) {
      setState(() {
        resultsWidget.add(ResultObject(data: i));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Szukaj'),
        ),
        body: ListView(children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: CRoot.blue.color()))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Parametry wyszukiwania',
                      style: TextStyle(
                          color: CRoot.blue.color(brightness: 0.33),
                          fontSize: 22),
                    )
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Typ obiektu:',
                        style:
                            TextStyle(color: CRoot.blue.color(), fontSize: 16),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      DropdownButton<String>(
                          value: selectedType.name,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: CRoot.blue.color(brightness: 0.25),
                            size: 20,
                          ),
                          elevation: 16,
                          style: TextStyle(
                              color: CRoot.blue.color(brightness: 0.33),
                              fontSize: 16),
                          underline: Container(
                              height: 2,
                              color: CRoot.blue.color(brightness: 0.25)),
                          items: GeoTypes.values
                              .map<DropdownMenuItem<String>>((GeoTypes value) {
                            return DropdownMenuItem<String>(
                                value: value.name,
                                child: Text(value.displayName()));
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedType = GeoTypes.values.byName(value!);
                            });
                          })
                    ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Promień:',
                      style: TextStyle(color: CRoot.blue.color(), fontSize: 16),
                    ),
                    const SizedBox(
                      width: 43,
                    ),
                    SizedBox(
                        width: 50,
                        child: TextField(
                          controller: rController,
                          textAlignVertical: TextAlignVertical.bottom,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: CRoot.blue.color(brightness: 0.25),
                                      width: 4)),
                              hintText: '0',
                              hintStyle: TextStyle(color: CRoot.gray.color()),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 8.5)),
                          style: TextStyle(
                              fontSize: 16,
                              color: CRoot.blue.color(brightness: 0.33)),
                        )),
                    const SizedBox(
                      width: 14,
                    ),
                    DropdownButton<String>(
                        value: selectedUnit.name,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: CRoot.blue.color(brightness: 0.25),
                          size: 20,
                        ),
                        elevation: 16,
                        style: TextStyle(
                            color: CRoot.blue.color(brightness: 0.33),
                            fontSize: 16),
                        underline: Container(
                            height: 2,
                            color: CRoot.blue.color(brightness: 0.25)),
                        items: GeoUnits.values
                            .map<DropdownMenuItem<String>>((GeoUnits value) {
                          return DropdownMenuItem<String>(
                              value: value.name, child: Text(value.name));
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedUnit = GeoUnits.values.byName(value!);
                          });
                        })
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    findMarkers();
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(CRoot.blue.color()),
                      padding: const MaterialStatePropertyAll<EdgeInsets>(
                          EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 12.0))),
                  child: Text(
                    'Szukaj',
                    style: TextStyle(
                        color: CRoot.blue.color(brightness: 0.95),
                        fontSize: 16),
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Wyniki wyszukiwania',
                style: TextStyle(
                    fontSize: 22, color: CRoot.aqua.color(brightness: 0.25)),
              )
            ],
          ),
          Column(
              children:
                  resultsWidget.isEmpty ? [emptyResultWidget()] : resultsWidget)
        ]));
  }

  @override
  void dispose() {
    rController.dispose();
    super.dispose();
  }
}
