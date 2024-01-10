import 'package:geolocator/geolocator.dart';

import '../../models/constants/base_url.dart';
import '../../screens/frame.dart';
import 'package:http/http.dart' as http;

class GeoLocationService {

  static Future<Position?> getLocationPermission({bool update = false}) async {
    bool serviceEnabled;
    LocationPermission permission;

    /// Run once
    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) { return Future.error('Location services are disabled.'); }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    if(update) {
     await updateServerLocation(position);
    }

    return position;

  }

  static Future updateServerLocation(Position position) async {
    var res = await http.post(
        Uri.http(baseUrl, '/updateUserLocation'),
        body: {
          'userId': user.id.toString(),
          'longitude': position.longitude.toString(),
          'latitude': position.latitude.toString(),
        }
    );
    return res;
  }


}