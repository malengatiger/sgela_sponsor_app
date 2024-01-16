import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'functions.dart';

class LocationUtil {
  static const mm = '🔵🔵🔵🔵LocationUtil: 🔵🔵';

  static Future<String?> getCountryName() async {
    pp('$mm getCountryName .... ');
    var ps = await Permission.location.request();
    if (ps.isDenied) {
      pp('$mm getCountryName .... location permission denied');
      return '';
    }
    if (ps.isGranted) {
      pp('$mm getCountryName .... location permission granted');
      Position position = await Geolocator.getCurrentPosition();
      GeoCode geoCode = GeoCode();

      try {
        Address address = await geoCode.reverseGeocoding(
            latitude: position.latitude, longitude: position.longitude);
        pp('$mm geocoded location: ${address.toString()}');

        return address.countryName;
      } catch (e) {
        pp(e);
      }
    }


    return '';
  }
}
