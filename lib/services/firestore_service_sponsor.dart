import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgela_services/data/branding.dart';
import 'package:sgela_services/data/city.dart';
import 'package:sgela_services/data/country.dart';
import 'package:sgela_services/data/gemini_response_rating.dart';
import 'package:sgela_services/data/org_user.dart';
import 'package:sgela_services/data/organization.dart';
import 'package:sgela_services/data/pricing.dart';
import 'package:sgela_services/data/sponsor_product.dart';
import 'package:sgela_services/data/sponsoree.dart';
import 'package:sgela_services/data/subscription.dart';
import 'package:get_it/get_it.dart';

import '../util/functions.dart';
import '../util/location_util.dart';
import '../util/sponsor_prefs.dart';

class FirestoreService {
  final FirebaseFirestore firebaseFirestore;
  static const mm = '🌀🌀🌀🌀🌀FirestoreService 🌀';


  FirestoreService(this.firebaseFirestore) {
    firebaseFirestore.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  List<Country> countries = [];
  Country? localCountry;

  Future<OrgUser> addUser(OrgUser user) async {
    var ref = await firebaseFirestore.collection('User').add(user.toJson());
    var m = ref.path;
    ppx('$mm user added to database: ${user.toJson()}');
    return user;
  }

  Future<List<AIResponseRating>> getRatings(int examLinkId) async {
    List<AIResponseRating> ratings = [];
    var querySnapshot = await firebaseFirestore
        .collection('GeminiResponseRating')
        .where('examLinkId', isEqualTo: examLinkId)
        .get();
    for (var s in querySnapshot.docs) {
      var rating = AIResponseRating.fromJson(s.data());
      ratings.add(rating);
    }
    return ratings;
  }

  Future<Subscription?> addSubscription(Subscription subscription) async {
    ppx('$mm addSubscription to be added to database: ${subscription.toJson()}');

    subscription.id = DateTime.now().millisecondsSinceEpoch;
    var colRef = firebaseFirestore.collection('Subscription');
    var docRef = await colRef.add(subscription.toJson());
    var v = await docRef.get();
    var doc = v.data();
    if (doc != null) {
      ppx('$mm subscription added to database: $doc');
      return Subscription.fromJson(doc);
    }
    return null;
  }

  List<SponsorProduct> sponsorProducts = [];

  Future<List<SponsorProduct>> getSponsorProducts(bool refresh) async {
    var sponsorPrefs = GetIt.instance<SponsorPrefs>();

    var country = await getLocalCountry();
    if (refresh) {
      if (country != null) {
        ppx('$mm ... get getSponsorProducts from Firestore ...');
        var qs = await firebaseFirestore
            .collection('SponsorPaymentType')
            .where('countryName', isEqualTo: country.name!)
            .get();
        sponsorProducts.clear();
        for (var snap in qs.docs) {
          sponsorProducts.add(SponsorProduct.fromJson(snap.data()));
        }
        ppx('$mm ... sponsorProducts found in Firestore: ${sponsorProducts.length}');
        for (var t in sponsorProducts) {
          ppx('$mm SponsorProduct: 🔵🔵🔵🔵 ${t.toJson()} 🔵🔵🔵🔵');
        }
        sponsorPrefs.saveSponsorProducts(sponsorProducts);
        return sponsorProducts;
      }
      ppx('$mm ... SponsorProducts found in Firestore: ${sponsorProducts.length}');
    }
    sponsorProducts = sponsorPrefs.getSponsorProducts();
    if (sponsorProducts.isNotEmpty) {
      return sponsorProducts;
    } else {
      getSponsorProducts(true);
    }

    return sponsorProducts;
  }

  Future<List<Country>> getCountries() async {
    var sponsorPrefs = GetIt.instance<SponsorPrefs>();

    countries.clear();
    ppx('$mm ... get countries from Firestore ...');

    var qs = await firebaseFirestore.collection('Country').get();
    for (var snap in qs.docs) {
      countries.add(Country.fromJson(snap.data()));
    }
    ppx('$mm ... countries found in Firestore: ${countries.length}');
    sponsorPrefs.saveCountries(countries);
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
          ppx('$mm ... local country found: ${localCountry!.name}');
          break;
        }
      }
    }
    return localCountry;
  }

  Future<Organization?> getOrganization(int organizationId) async {
    ppx('$mm ... getOrganization from Firestore ... organizationId: $organizationId');
    List<Organization> list = [];
    var qs = await firebaseFirestore
        .collection('Organization')
        .where('id', isEqualTo: organizationId)
        .get();
    for (var snap in qs.docs) {
      list.add(Organization.fromJson(snap.data()));
    }
    ppx('$mm ... orgs found: ${list.length}');

    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  Future<Pricing?> getPricing(int countryId) async {
    ppx('$mm ... getPricing from Firestore ... countryId: $countryId');
    List<Pricing> list = [];
    var qs = await firebaseFirestore
        .collection('Pricing')
        .where('countryId', isEqualTo: countryId)
        .get();
    for (var snap in qs.docs) {
      list.add(Pricing.fromJson(snap.data()));
    }
    ppx('$mm ... pricings found: ${list.length}');

    if (list.isNotEmpty) {
      list.sort((a, b) => b.date!.compareTo(a.date!));
      return list.first;
    }
    return null;
  }

  Future<List<City>> getCities(int countryId) async {
    ppx('$mm ... get cities from Firestore ... countryId: $countryId');
    List<City> cities = [];
    var qs = await firebaseFirestore
        .collection('City')
        .where('countryId', isEqualTo: countryId)
        .get();
    ppx('$mm ... qs found: ${qs.size} cities');

    for (var snap in qs.docs) {
      cities.add(City.fromJson(snap.data()));
    }

    ppx('$mm ... cities found: ${cities.length}');
    return cities;
  }

  Future<List<Branding>> getBranding(int organizationId, bool refresh) async {
    var sponsorPrefs = GetIt.instance<SponsorPrefs>();

    if (refresh) {
      ppx('$mm ... get branding from Firestore ... organizationId: $organizationId');
      var qs = await firebaseFirestore
          .collection('Branding')
          .where('organizationId', isEqualTo: organizationId)
          .get();
      brandings.clear();
      for (var snap in qs.docs) {
        brandings.add(Branding.fromJson(snap.data()));
      }
      ppx('$mm ... getBranding: brandings found: ${brandings.length}');
      brandings.sort((a, b) => b.date!.compareTo(a.date!));
      sponsorPrefs.saveBrandings(brandings);
      return brandings;
    }

    // brandings = prefs.getBrandings();
    return brandings;
  }

  List<Sponsoree> orgSponsorees = [];

  Future<List<Sponsoree>> getOrgSponsorees(
      int organizationId, bool refresh) async {
    if (refresh) {
      ppx('$mm ... get branding from Firestore ... organizationId: $organizationId');
      var qs = await firebaseFirestore
          .collection('OrgSponsoree')
          .where('organizationId', isEqualTo: organizationId)
          .get();
      orgSponsorees.clear();
      for (var snap in qs.docs) {
        orgSponsorees.add(Sponsoree.fromJson(snap.data()));
      }
      ppx('$mm ... OrgSponsorees found: ${orgSponsorees.length}');
      return orgSponsorees;
    }
    return orgSponsorees;
  }

  Future<int?> countOrgSponsorees(int organizationId) async {
    ppx('$mm ... get branding from Firestore ... organizationId: $organizationId');
    var qs = await firebaseFirestore
        .collection('OrgSponsoree')
        .where('organizationId', isEqualTo: organizationId)
        .count()
        .get();

    return qs.count;
  }

  Future<List<Subscription>> getSubscriptions(int organizationId) async {
    ppx('$mm ... getSubscriptions from Firestore ... organizationId: $organizationId');

    var qs = await firebaseFirestore
        .collection('Subscription')
        .where('organizationId', isEqualTo: organizationId)
        .get();
    List<Subscription> subs = [];
    for (var snap in qs.docs) {
      subs.add(Subscription.fromJson(snap.data()));
    }

    ppx('$mm ... subs found: ${subs.length}');
    subs.sort((a, b) => b.date!.compareTo(a.date!));
    return subs;
  }

  Future<List<OrgUser>> getUsers(int organizationId, bool refresh) async {
    var sponsorPrefs = GetIt.instance<SponsorPrefs>();
    if (refresh) {
      // ppx('$mm ... get users from Firestore ... organizationId: $organizationId');
      var qs = await firebaseFirestore
          .collection('User')
          .where('organizationId', isEqualTo: organizationId)
          .get();
      users.clear();
      for (var snap in qs.docs) {
        users.add(OrgUser.fromJson(snap.data()));
      }
      ppx('$mm ... users found: ${users.length}');
      users.sort((a, b) => b.lastName!.compareTo(a.lastName!));
      sponsorPrefs.saveUsers(users);
      return users;
    }
    users = sponsorPrefs.getUsers();
    return users;
  }

  Future<OrgUser?> getUser(String firebaseUserId) async {
    ppx('$mm ... get user from Firestore ... firebaseUserId: $firebaseUserId');

    var qs = await firebaseFirestore
        .collection('User')
        .where('firebaseUserId', isEqualTo: firebaseUserId)
        .get();
    users.clear();
    for (var snap in qs.docs) {
      users.add(OrgUser.fromJson(snap.data()));
    }

    ppx('$mm ... users found: ${users.length}');
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  List<Branding> brandings = [];
  List<OrgUser> users = [];

// Future<List<SponsorProduct>> getSponsorProducts(bool refresh) async {
//   var country = await getLocalCountry();
//   if (refresh) {
//     if (country != null) {
//       ppx('$mm ... get getSponsorProducts from Firestore ...');
//
//       var qs = await firebaseFirestore.collection('SponsorPaymentType')
//           .where('countryName', isEqualTo: country.name!)
//           .get();
//       sponsorProducts.clear();
//       for (var snap in qs.docs) {
//         sponsorProducts.add(SponsorProduct.fromJson(snap.data()));
//       }
//       ppx('$mm ... sponsorProducts found in Firestore: ${sponsorProducts.length}');
//       for (var t in sponsorProducts) {
//         ppx('$mm SponsorProduct: 🔵🔵🔵🔵 ${t.toJson()} 🔵🔵🔵🔵');
//       }
//       // prefs.saveSponsorProducts(sponsorProducts);
//       return sponsorProducts;
//     }
//     ppx('$mm ... SponsorProducts found in Firestore: ${sponsorProducts.length}');
//   }
//   sponsorProducts = sponsorPrefs.getSponsorProducts();
//   if (sponsorProducts.isNotEmpty) {
//     return sponsorProducts;
//   } else {
//     getSponsorProducts(true);
//   }
//
//
//   return sponsorProducts;
// }
}
