import 'package:flutter_map/flutter_map.dart';

TileLayer tileLayerOptions =
  TileLayer(
    urlTemplate: "https://api.mapbox.com/styles/v1/ryanbussert19/ckr5omtkh1mf017o79cvvdj55/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicnlhbmJ1c3NlcnQxOSIsImEiOiJja3I1b2g3NnQzN24wMm5ydWJ2MmM4cnp5In0.rPe6ih5wZdwpHn21jeGFUQ",
    additionalOptions: const {
      'accessToken' : 'pk.eyJ1IjoicnlhbmJ1c3NlcnQxOSIsImEiOiJja3I1b2g3NnQzN24wMm5ydWJ2MmM4cnp5In0.rPe6ih5wZdwpHn21jeGFUQ',
      'id' : 'mapbox.mapbox-streets-v8'
    },
    // attributionBuilder: (_) {
    //   return const Text("© OpenStreetMap contributors");
    // },
  );