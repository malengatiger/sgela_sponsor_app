import 'dart:collection';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sgela_services/data/country.dart';
import 'functions.dart';

class LocationUtil {
  static const mm = '😎😎😎😎LocationUtil: 😎😎';

  static Future<String?> getCountryName() async {
    ppx('$mm getCountryName .... ');
    var ps = await Permission.location.request();
    if (ps.isDenied) {
      ppx('$mm getCountryName .... location permission denied');
      return '';
    }
    if (ps.isGranted) {
      ppx('$mm getCountryName .... location permission granted');
      Position position = await getCurrentLocation();

    }
    return '';
  }

  static Future<Placemark?> findNearestPlace() async {

    Position position = await getCurrentLocation();
    List<Placemark> placeMarks = await placemarkFromCoordinates(
        position.latitude, position.longitude);
    for (var value in placeMarks) {
      ppx('$mm placeMark: .... 🔵street: ${value.street}, '
          '🔵area: ${value.administrativeArea}, 🔵country: ${value.country}');

    }
    if (placeMarks.isEmpty) {
      return null;
    }
    return placeMarks.first;

  }
  static Future<Country> findNearestCountry(List<Country> countries) async {
    Position position = await getCurrentLocation();

    HashMap<double, Country> hash = HashMap();
     for (var value in countries) {
       double dist = Geolocator.distanceBetween(position.latitude, position.longitude!,
           value.latitude!, value.longitude!);
       hash[dist] = value;
     }
     var keys = hash.keys.toList();
     keys.sort();
     for (var key in keys) {
       var country = hash[key];
       ppx('$mm country: .... found: ${country!.name}');
     }
     Country country = hash[keys.first]!;
    ppx('$mm findNearestCountry: .... found: ${country.name}');
    return country;

  }
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    // Request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    // Get the current position
    return await Geolocator.getCurrentPosition();
  }
}
