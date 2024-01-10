import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../models/classes/place.dart';
import '../../models/classes/post.dart';
import '../../models/classes/user.dart';
import '../../screens/frame.dart';
import '../../screens/map_screens/markers/geo_post_marker.dart';
import '../../screens/map_screens/markers/my_user_marker.dart';
import '../../screens/map_screens/markers/place_marker.dart';
import '../../screens/map_screens/markers/user_marker.dart';
import 'map_service.dart';

class MarkerService {
  static Marker createGeoPostMarkers(Post post, double zoom, Function callback) {

    return Marker(
        width: 84.0,
        height:  190.0,
        point: LatLng(post.latitude, post.longitude),
        builder: (ctx) {
          return AnimatedGeoPostContainer(post: post, zoom: zoom, callback: callback,);
        }
    );
  }

  static Marker? createMyUserMarker(Position pos, LatLngBounds bounds, Function callback, {int? postStackCount, int? userStackCount, required double zoom,}) {

    double north = MapService.boundScaler('north', zoom, bounds.north);
    double south = MapService.boundScaler('south', zoom, bounds.south);
    double east = MapService.boundScaler('east', zoom, bounds.east);
    double west = MapService.boundScaler('west', zoom, bounds.west);

    if(pos.longitude <= east && pos.longitude >= west && pos.latitude <= north && pos.latitude >= south) {

      return Marker(
          width: 100,
          height: 100,
          point: LatLng(pos.latitude, pos.longitude),
          builder: (ctx) {
            return MyUserMarkerContainer(userdata: user, callback: callback, stackCount: postStackCount, userStackCount: userStackCount, isMe: true,);
          }
      );
    }
    else {
      return null;
    }
  }

  static Marker createUserMarker(User userdata, LatLngBounds bounds, Function callback, {int? postStackCount}) {
    return Marker(
        width: 100,
        height: 100,
        point: LatLng(userdata.latitude!, userdata.longitude!),
        builder: (ctx) {
          return UserMarkerContainer(userdata: userdata, callback: callback);
        }
    );
  }

  static Marker createPlaceMarkers(Place place, LatLngBounds bounds, Function callback) {
    return Marker(
        width: 100,
        height: 100,
        point: LatLng(place.lat, place.long),
        builder: (ctx) {
          return PlaceMarkerContainer(place: place, callback: callback);
        }
    );
  }
}