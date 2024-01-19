import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgela_sponsor_app/data/branding.dart';
import 'package:sgela_sponsor_app/data/organization.dart';

import '../data/city.dart';
import '../data/country.dart';
import '../data/gemini_response_rating.dart';
import '../util/functions.dart';
import '../util/location_util.dart';
class FirestoreService {
  final FirebaseFirestore firebaseFirestore;
  static const mm = '🌀🌀🌀🌀🌀FirestoreService 🌀';
  FirestoreService(this.firebaseFirestore) {
    firebaseFirestore.settings = const Settings(
      persistenceEnabled: true,
    );
    getCountries();
  }
  List<Country> countries = [];
  Country? localCountry;
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
    if (countries.isNotEmpty) {
      return countries;
    }
    var qs = await firebaseFirestore
        .collection('Country').get();
    for (var snap in qs.docs) {
      countries.add(Country.fromJson(snap.data()));
    }
    pp('$mm ... countries found in Firestore: ${countries.length}');
    getLocalCountry();
    return countries;
  }
  Future<Country?> getLocalCountry() async {
    if (localCountry != null) {
      return localCountry!;
    }
    if (countries.isEmpty) {
      await getCountries();
    }
    var place = await LocationUtil.findNearestPlace();
    if (place != null) {
      for (var value in countries) {
        if (value.name!.contains(place.country!)) {
          localCountry = value;
          pp('$mm ... local country found: ${localCountry!.name}');
          break;
        }
      }
    }
    return localCountry;
  }
  Future<Organization?> getOrganization(int organizationId) async {
    pp('$mm ... getOrganization from Firestore ... organizationId: $organizationId');
    List<Organization> list = [];
    var qs = await firebaseFirestore
        .collection('Organization').where('id', isEqualTo: organizationId).get();
    for (var snap in qs.docs) {
      list.add(Organization.fromJson(snap.data()));
    }
    pp('$mm ... orgs found: ${list.length}');

    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
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
  Future<List<Branding>> getBranding(int organizationId) async {
    pp('$mm ... get branding from Firestore ... organizationId: $organizationId');
    if (brandings.isNotEmpty) {
      return brandings;
    }
    var qs = await firebaseFirestore
        .collection('Branding').where('organizationId', isEqualTo: organizationId).get();
    for (var snap in qs.docs) {
      brandings.add(Branding.fromJson(snap.data()));
    }

    pp('$mm ... branding found: ${brandings.length}');
    brandings.sort((a,b) => b.date!.compareTo(a.date!));
    return brandings;
  }
  final List<Branding> brandings = [];
}
