import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import '../../models/classes/place.dart';
import '../../models/classes/post.dart';
import 'package:http/http.dart' as http;
import '../../services/internal_services/marker_service.dart';

import '../../models/classes/user.dart';
import '../../models/constants/base_url.dart';
import '../../screens/frame.dart';


class MapService {

  static Future? markerHandler( MapPosition pos, {required Function userOverlayCallback, required Function geoPostOverlayCallback, required Function placeOverlayCallback, required double zoom, LatLngBounds? bounds}) async {



    var res = await http.get(
        Uri.http(baseUrl, '/mapQuery'),
        headers: {
          'userid' : user.id.toString(),
          'boundN' : (bounds?.north ?? pos.bounds!.north).toString(),
          'boundS' : (bounds?.south ?? pos.bounds!.south).toString(),
          'boundE' : (bounds?.east ?? pos.bounds!.east).toString(),
          'boundW' : (bounds?.west ?? pos.bounds!.west).toString(),
          'userLatitude' : user.currentPosition.latitude.toString(),
          'userLongitude' : user.currentPosition.longitude.toString(),
          'userId' : user.id.toString(),
          'zoom' : zoom.toString()
        }
    );
    dynamic json = (jsonDecode(res.body));

    List<Post> posts = (json['posts'] as List).map((e) =>  Post.fromDoc(e['post'], count: e['count'])).toList();
    List<User> users = (json['users'] as List).map((e) =>  User.parse(e)).toList();
    List<Place> places = (json['places'] as List).map((e) => Place.parse(e)).toList();


    int myUserCount = (jsonDecode(res.body)['myStack']['userCount']) ?? 0;
    int myPostCount = (jsonDecode(res.body)['myStack']['postCount']) ?? 0;

    Marker? myUserMarker =  MarkerService.createMyUserMarker(user.currentPosition, bounds ?? pos.bounds!, userOverlayCallback, userStackCount: myUserCount, postStackCount: myPostCount, zoom: pos.zoom ?? 0);
    List<Marker> userMarks = users.map((e) => MarkerService.createUserMarker(e, bounds ?? pos.bounds!, userOverlayCallback)).toList();
    List<Marker> geoPostmarks = posts.map((e) => MarkerService.createGeoPostMarkers(e, zoom, geoPostOverlayCallback)).toList();
    List<Marker> placemarks = places.map((e) => MarkerService.createPlaceMarkers(e, bounds ?? pos.bounds!, placeOverlayCallback)).toList();

    List<Marker> markerList = [];

    markerList.addAll(geoPostmarks);
    markerList.addAll(userMarks);
    markerList.addAll(placemarks);
    if(myUserMarker != null) markerList.add(myUserMarker);
    return markerList;
  }



  static double boundScaler(String boundKey, double zoom, double bound) {
    double diff;
    double newBound;

    if(zoom > 17){ diff = 0.0007; }
    else if(zoom <= 17 && zoom > 16) { diff = 0.001; }
    else if (zoom <= 16 && zoom > 15) { diff = 0.0026;}
    else if(zoom <= 15 && zoom > 14) { diff = 0.006;  }
    else if(zoom <= 14 && zoom > 13) { diff = 0.01; }
    else if(zoom <= 13 && zoom > 12) { diff = 0.02; }
    else if(zoom <= 12 && zoom > 11) { diff = 0.05; }
    else if(zoom <= 11 && zoom > 10) { diff = 0.1; }
    else if(zoom <= 10 && zoom > 9) { diff = 0.14; }
    else if(zoom <= 9 && zoom > 8) { diff = 0.3; }
    else if(zoom <= 8 && zoom > 7) { diff = 1;  }
    else if(zoom <= 7 && zoom > 6) { diff = 3; }
    else if(zoom <= 6 && zoom > 5) { diff = 5; }
    else if(zoom <= 5 && zoom > 4) { diff = 7; }
    else if(zoom <= 4) { diff = 10; }
    else {diff = 0;}

    if(boundKey == 'west' || boundKey == 'south') {
      diff = (diff * -1);
    }

    newBound = bound + diff;


    return newBound;
  }
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}