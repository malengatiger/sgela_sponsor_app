import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/city.dart';
import '../data/country.dart';
import '../data/gemini_response_rating.dart';
import '../util/functions.dart';
class FirestoreService {
  final FirebaseFirestore firebaseFirestore;
  static const mm = '🌀🌀🌀🌀🌀FirestoreService 🌀';
  FirestoreService(this.firebaseFirestore) {
    firebaseFirestore.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  Future<List<GeminiResponseRating>> getRatings(int examLinkId) async {
    List<GeminiResponseRating> ratings = [];
    var querySnapshot =
    await firebaseFirestore.collection('GeminiResponseRating')
        .where('examLinkId', isEqualTo: examLinkId)
        .get();
    for (var s in querySnapshot.docs) {
      var rating = GeminiResponseRating.fromJson(s.data());
      ratings.add(rating);
    }
    return ratings;
  }
  Future addRating(GeminiResponseRating rating) async {
    var colRef = firebaseFirestore.collection('GeminiResponseRating');
    await colRef.add(rating.toJson());
  }

  Future<List<Country>> getCountries() async {
    pp('$mm ... get countries from Firestore ...');

    List<Country> countries = [];
    var qs = await firebaseFirestore
        .collection('Country').get();
    pp('$mm ... qs found: ${qs.size}');

    for (var snap in qs.docs) {
      countries.add(Country.fromJson(snap.data()));
    }
    pp('$mm ... countries found: ${countries.length}');
    return countries;

  }
  Future<List<City>> getCities(int countryId) async {
    pp('$mm ... get cities from Firestore ... countryId: $countryId');

    List<City> cities = [];
    var qs = await firebaseFirestore
        .collection('City').where('countryId', isEqualTo: countryId).get();
    pp('$mm ... qs found: ${qs.size} cities');

    for (var snap in qs.docs) {
        cities.add(City.fromJson(snap.data()));
    }

    pp('$mm ... cities found: ${cities.length}');
    return cities;

  }
}
