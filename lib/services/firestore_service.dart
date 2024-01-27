import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgela_sponsor_app/data/branding.dart';
import 'package:sgela_sponsor_app/data/organization.dart';
import 'package:sgela_sponsor_app/data/sponsor_product.dart';
import 'package:sgela_sponsor_app/data/subscription.dart';
import 'package:sgela_sponsor_app/data/user.dart';
import 'package:sgela_sponsor_app/util/prefs.dart';

import '../data/city.dart';
import '../data/country.dart';
import '../data/gemini_response_rating.dart';
import '../data/pricing.dart';
import '../util/functions.dart';
import '../util/location_util.dart';

class FirestoreService {
  final FirebaseFirestore firebaseFirestore;
  static const mm = '🌀🌀🌀🌀🌀FirestoreService 🌀';

  final Prefs prefs;
  FirestoreService(this.firebaseFirestore, this.prefs) {
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

  List<SponsorProduct> sponsorProducts = [];

  Future<List<SponsorProduct>> getSponsorProducts(bool refresh) async {
    var country = await getLocalCountry();
    if (refresh) {
      if (country != null) {
        pp('$mm ... get getSponsorProducts from Firestore ...');

        var qs = await firebaseFirestore.collection('SponsorPaymentType')
            .where('countryName', isEqualTo: country.name!)
            .get();
        sponsorProducts.clear();
        for (var snap in qs.docs) {
          sponsorProducts.add(SponsorProduct.fromJson(snap.data()));
        }
        pp('$mm ... sponsorProducts found in Firestore: ${sponsorProducts.length}');
        for (var t in sponsorProducts) {
          pp('$mm SponsorProduct: 🔵🔵🔵🔵 ${t.toJson()} 🔵🔵🔵🔵');
        }
        prefs.saveSponsorProducts(sponsorProducts);
        return sponsorProducts;
      }
      pp('$mm ... SponsorProducts found in Firestore: ${sponsorProducts.length}');
    }
    sponsorProducts = prefs.getSponsorProducts();
    if (sponsorProducts.isNotEmpty) {
      return sponsorProducts;
    } else {
      getSponsorProducts(true);
    }


    return sponsorProducts;
  }


  Future<List<Country>> getCountries() async {
    countries = prefs.getCountries();
    if (countries.isNotEmpty) {
      return countries;
    }
    countries.clear();
    pp('$mm ... get countries from Firestore ...');

    var qs = await firebaseFirestore.collection('Country').get();
    for (var snap in qs.docs) {
      countries.add(Country.fromJson(snap.data()));
    }
    pp('$mm ... countries found in Firestore: ${countries.length}');
    prefs.saveCountries(countries);
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

  Future<List<Branding>> getBranding(int organizationId, bool refresh) async {
    if (refresh) {
      pp('$mm ... get branding from Firestore ... organizationId: $organizationId');
      var qs = await firebaseFirestore
          .collection('Branding')
          .where('organizationId', isEqualTo: organizationId)
          .get();
      brandings.clear();
      for (var snap in qs.docs) {
        brandings.add(Branding.fromJson(snap.data()));
      }
      pp('$mm ... brandings found: ${brandings.length}');
      brandings.sort((a, b) => b.date!.compareTo(a.date!));
      prefs.saveBranding(brandings);
      return brandings;
    }

    brandings = prefs.getBrandings();
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

  Future<List<User>> getUsers(int organizationId, bool refresh) async {
    if (refresh) {
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
      prefs.saveUsers(users);
      return users;
    }
    users = prefs.getUsers();
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

   List<Branding> brandings = [];
  List<User> users = [];
}
