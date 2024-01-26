import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgela_sponsor_app/data/branding.dart';
import 'package:sgela_sponsor_app/data/organization.dart';
import 'package:sgela_sponsor_app/data/sponsor_payment_type.dart';
import 'package:sgela_sponsor_app/data/subscription.dart';
import 'package:sgela_sponsor_app/data/user.dart';

import '../data/city.dart';
import '../data/country.dart';
import '../data/gemini_response_rating.dart';
import '../data/pricing.dart';
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

  Future<User> addUser(User user) async {
    var ref = await firebaseFirestore.collection('User').add(user.toJson());
    var m = ref.path;
    pp('$mm user added to database: ${user.toJson()}');
    return user;
  }

  Future<List<GeminiResponseRating>> getRatings(int examLinkId) async {
    List<GeminiResponseRating> ratings = [];
    var querySnapshot = await firebaseFirestore
        .collection('GeminiResponseRating')
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

  Future<Subscription?> addSubscription(Subscription subscription) async {
    pp('$mm addSubscription to be added to database: ${subscription.toJson()}');

    subscription.id = generateUniqueKey();
    var colRef = firebaseFirestore
        .collection('Subscription');
    var docRef =
    await colRef.add(subscription.toJson());
    var v = await docRef.get();
    var doc = v.data();
    if (doc != null) {
      pp('$mm subscription added to database: $doc');
      return Subscription.fromJson(doc);
    }
    return null;
  }

  final List<SponsorProduct> sponsorPaymentTypes = [];

  Future<List<SponsorProduct>> getSponsorProducts() async {
    pp('$mm ... get getSponsorPaymentTypes from Firestore ...');
    if (sponsorPaymentTypes.isNotEmpty) {
      return sponsorPaymentTypes;
    }
    var country = await getLocalCountry();
    if (country != null) {
      var qs = await firebaseFirestore.collection('SponsorPaymentType')
          .where('countryName', isEqualTo: country.name!)
          .get();
      for (var snap in qs.docs) {
        sponsorPaymentTypes.add(SponsorProduct.fromJson(snap.data()));
      }
      pp('$mm ... sponsorPaymentTypes found in Firestore: ${sponsorPaymentTypes.length}');
      for (var t in sponsorPaymentTypes) {
        pp('$mm SponsorPaymentType: 🔵🔵🔵🔵 ${t.toJson()} 🔵🔵🔵🔵');
      }
      return sponsorPaymentTypes;
    }
    pp('$mm ... sponsorPaymentTypes found in Firestore: ${sponsorPaymentTypes.length}');

    return sponsorPaymentTypes;
  }


  Future<List<Country>> getCountries() async {
    pp('$mm ... get countries from Firestore ...');
    if (countries.isNotEmpty) {
      return countries;
    }
    var qs = await firebaseFirestore.collection('Country').get();
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
        .collection('Organization')
        .where('id', isEqualTo: organizationId)
        .get();
    for (var snap in qs.docs) {
      list.add(Organization.fromJson(snap.data()));
    }
    pp('$mm ... orgs found: ${list.length}');

    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  Future<Pricing?> getPricing(int countryId) async {
    pp('$mm ... getPricing from Firestore ... countryId: $countryId');
    List<Pricing> list = [];
    var qs = await firebaseFirestore
        .collection('Pricing')
        .where('countryId', isEqualTo: countryId)
        .get();
    for (var snap in qs.docs) {
      list.add(Pricing.fromJson(snap.data()));
    }
    pp('$mm ... pricings found: ${list.length}');

    if (list.isNotEmpty) {
      list.sort((a,b) => b.date!.compareTo(a.date!));
      return list.first;
    }
    return null;
  }

  Future<List<City>> getCities(int countryId) async {
    pp('$mm ... get cities from Firestore ... countryId: $countryId');
    List<City> cities = [];
    var qs = await firebaseFirestore
        .collection('City')
        .where('countryId', isEqualTo: countryId)
        .get();
    pp('$mm ... qs found: ${qs.size} cities');

    for (var snap in qs.docs) {
      cities.add(City.fromJson(snap.data()));
    }

    pp('$mm ... cities found: ${cities.length}');
    return cities;
  }

  Future<List<Branding>> getBranding(int organizationId) async {
    pp('$mm ... get branding from Firestore ... organizationId: $organizationId');

    var qs = await firebaseFirestore
        .collection('Branding')
        .where('organizationId', isEqualTo: organizationId)
        .get();
    brandings.clear();
    for (var snap in qs.docs) {
      brandings.add(Branding.fromJson(snap.data()));
    }

    pp('$mm ... branding found: ${brandings.length}');
    brandings.sort((a, b) => b.date!.compareTo(a.date!));
    return brandings;
  }

  Future<List<Subscription>> getSubscriptions(int organizationId) async {
    pp('$mm ... getSubscriptions from Firestore ... organizationId: $organizationId');

    var qs = await firebaseFirestore
        .collection('Subscription')
        .where('organizationId', isEqualTo: organizationId)
        .get();
    List<Subscription> subs = [];
    for (var snap in qs.docs) {
      subs.add(Subscription.fromJson(snap.data()));
    }

    pp('$mm ... subs found: ${subs.length}');
    subs.sort((a, b) => b.date!.compareTo(a.date!));
    return subs;
  }

  Future<List<User>> getUsers(int organizationId) async {
    pp('$mm ... get users from Firestore ... organizationId: $organizationId');

    var qs = await firebaseFirestore
        .collection('User')
        .where('organizationId', isEqualTo: organizationId)
        .get();
    users.clear();
    for (var snap in qs.docs) {
      users.add(User.fromJson(snap.data()));
    }

    pp('$mm ... users found: ${users.length}');
    users.sort((a, b) => b.lastName!.compareTo(a.lastName!));
    return users;
  }

  Future<User?> getUser(String firebaseUserId) async {
    pp('$mm ... get user from Firestore ... firebaseUserId: $firebaseUserId');

    var qs = await firebaseFirestore
        .collection('User')
        .where('firebaseUserId', isEqualTo: firebaseUserId)
        .get();
    users.clear();
    for (var snap in qs.docs) {
      users.add(User.fromJson(snap.data()));
    }

    pp('$mm ... users found: ${users.length}');
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  final List<Branding> brandings = [];
  List<User> users = [];
}
