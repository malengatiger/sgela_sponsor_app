import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart' as dx;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get_it/get_it.dart';
import 'package:googleapis/androidpublisher/v3.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

//We are going to use the google client for this example...
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sgela_services/sgela_util/functions.dart';
import 'package:sgela_services/sgela_util/register_services.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_shared_widgets/util/widget_prefs.dart';
import 'package:sgela_sponsor_app/services/firestore_service_sponsor.dart';
import 'package:sgela_sponsor_app/services/rapyd_payment_service.dart';
import 'package:sgela_sponsor_app/services/repository.dart';
import 'package:sgela_sponsor_app/services/revenue_cat/constants.dart';
import 'package:sgela_sponsor_app/util/registration_stream_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/dio_util.dart';
import '../util/environment.dart';
import '../util/functions.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';


final GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: InAppPurchaseConstants.oauthClientId,
  scopes: <String>[AndroidPublisherApi.androidpublisherScope],
);
class ServiceRegistrar {
  static const mm = '🍎🍎🍎🍎🍎🍎 ServiceRegistrar 🍎🍎🍎🍎🍎🍎';

  static Future<GoogleSignInAccount> _handleSignIn() async {
    pp('$mm ... _handleSignIn ...');

    try {
      var acct = await _googleSignIn.signIn();
      if (acct != null) {
        return acct;
      }
    } catch (error) {
      pp(error);
    }
    throw Exception('Sign in failed');
  }

  static Future startGoogleSignIn() async {

    String? accessToken;

    try {
      _googleSignIn.onCurrentUserChanged.listen((account) {
        pp('$mm ... onCurrentUserChanged: ${account.toString()}');
      });
      GoogleSignInAccount? currentUser = await _handleSignIn();
      pp('$mm ... email signed in:  ${currentUser.email}');
      var ok = await _googleSignIn.signInSilently();
      pp('$mm ... _googleSignIn.signInSilently in:  ${ok?.email}');
      return ok;
    } catch (e, s) {
      pp('$mm $e - $s');
    }
    var x = 'Access token retrieval failed';
    pp('$mm 👿👿👿👿 $x');
    throw Exception(x);
  }
  static void _onPurchaseDetailsReceived(List<PurchaseDetails> purchaseDetailsList) {
    pp('$mm _onPurchaseDetailsReceived: ${purchaseDetailsList.length}');
  }

  static Future<void> registerGoogleInAppPurchase() async {
    ppx('$mm registerGoogleInAppPurchase: 🔵🔵🔵🔵initialize InAppPurchase ....');

    try {
      // 1. listen to events from the store

      InAppPurchase.instance.purchaseStream.listen((purchaseDetailsList) {
        _onPurchaseDetailsReceived(purchaseDetailsList);
      });
      _getProducts();
    } catch (e, s) {
      pp('$mm fucking ERROR: 👿👿👿$e 👿👿👿 $s');
    }
  }
  static Future<List<ProductDetails>> _getProducts() async {
    pp('$mm get products from store');
    bool available = await InAppPurchase.instance.isAvailable();
    pp('$mm ... InAppPurchase.instance: ${InAppPurchase.instance.isAvailable()}');
    if (!available) {
      return [];
    }

    Set<String> ids = {"product_id1",
      'product_id3', 'subscription_monthly_1',
      "product_id5", 'product_id9', 'one_time_gold'};
    var response =
    await InAppPurchase.instance.queryProductDetails(ids);
    if (response.notFoundIDs.isNotEmpty) {
      pp("Warning: Some ids where not found: ${response.notFoundIDs}");
    }
    pp('$mm ... response, productDetails: ${response.productDetails.length}');
    for (var value in response.productDetails) {
  pp('$mm ... product, 🔵id: ${value.id} 🔵title: ${value.title} 🔵description: ${value.description} '
      '🔵currencySymbol: ${value.currencySymbol} 🔵currencyCode: ${value.currencyCode}');
}

    return response.productDetails;
  }

  static Future<void> registerSponsorServices(
      FirebaseFirestore firebaseFirestore, FirebaseAuth firebaseAuth) async {
    ppx('$mm registerSponsorServices: initialize service singletons with GetIt ....');

    dx.Dio dio = dx.Dio();
    var dioUtil = DioUtil(dio);
    var sh = await SharedPreferences.getInstance();
    var sponsorPrefs = SponsorPrefs(sh);
    var widgetPrefs = WidgetPrefs(sh);

    var rapydService = RapydPaymentService(dioUtil, sponsorPrefs);
    var firestoreService = FirestoreService(firebaseFirestore);

    GetIt.instance.registerLazySingleton<SponsorPrefs>(() => sponsorPrefs);
    GetIt.instance.registerLazySingleton<WidgetPrefs>(() => widgetPrefs);

    GetIt.instance
        .registerLazySingleton<FirestoreService>(() => firestoreService);
    GetIt.instance.registerLazySingleton<RegistrationStreamHandler>(
        () => RegistrationStreamHandler());
    GetIt.instance.registerLazySingleton<RepositoryService>(() =>
        RepositoryService(
            dioUtil, sponsorPrefs, rapydService, firestoreService));
    try {
      await firestoreService.getCountries();
      Gemini.init(apiKey: SponsorsEnvironment.getGeminiAPIKey());
      await registerServices(firebaseFirestore, firebaseAuth, Gemini.instance);
      ppx('$mm ... shared services registered!');
      // await initializeLinkFive();
      // await initializeRevenueCat();
      // initializeAdapty();
    } catch (e, s) {
      ppx('`$e $s`');
    }

    ppx('$mm registerServices: GetIt has registered 9 services. 🍎 Cool!! 🍎🍎🍎');
  }

  static Future<void> initializeRevenueCat() async {
    pp('$mm ........ initializeRevenueCat ...  '
        '🍎productId: iOS: SgelaAIPurchase,  🍎REST ApiKey: sk_bFkOAWVZBVEmbcRLLmMvnqIqoZwVf');
    String googleKey = Constants.googleApiKey;
    String appleKey = Constants.appleApiKey;

    await Purchases.setLogLevel(LogLevel.info).catchError((err) {
      ppx('$mm RevenueCat: ERROR, what the fuck? - $err');
    }).timeout(const Duration(seconds: 60));

    late PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(googleKey);
      ppx('$mm RevenueCat subscriptions: Platform.isAndroid');
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(appleKey);
      ppx('$mm RevenueCat subscriptions: Platform.isIOS');
    }
    pp('$mm ........ initializeRevenueCat: calling configure() ...');
    await Purchases.configure(configuration);
    ppx('$mm RevenueCat  🍎 🍎 🍎subscriptions initialized: ${configuration.store.toString()} '
        '-  🍎appUserID: ${configuration.appUserID}');
    // await Purchases.getProducts(productIdentifiers)
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        // Display current offering with offerings.current
        for (var pkg in offerings.current!.availablePackages) {
          pp('$mm RevenueCat package: 🥬🥬 ${pkg.storeProduct.toJson()} 🥬🥬');
        }
      }
    } on PlatformException catch (e, s) {
      pp("$mm  🍎 🍎 🍎 🍎 🍎 🍎 🍎 ERROR: $e - $s");
    }
  }

  static const linkFiveAPIKey =
      '72db55e95a0a677257ea155e0e206b3fe1b4456e57d22725208266d501a1ba17';


//   static Future initializeLinkFive() async {
//     pp('$mm ........ initializeLinkFive ...  🍎');
//     try {
//       LinkFiveActiveProducts products = await LinkFivePurchases.init(
//           linkFiveAPIKey);
//       pp('$mm found products planList: ${products.planList.length}');
// // Subscriptions to offer to the user
//       LinkFivePurchases.products;
//
// // Active subscriptions the user purchased
//       LinkFivePurchases.activeProducts;
//       LinkFiveProducts? prods = await LinkFivePurchases.fetchProducts();
//       if (prods != null) {
//         pp('$mm found prods: ${prods.productDetailList.length}');
//       }
//
//     } catch (e, s) {
//       pp('$mm ERROR initializing LinkFive: $e - stackTrace: $s');
//     }
//   }
//   static Future initializeAdapty() async {
//     pp('$mm ........ initializeAdapty ...  🍎');
//
//     try {
//       Adapty().activate();
//     } on AdaptyError catch (adaptyError) {
//       pp('$mm ........ ERROR: $adaptyError ...  🍎');
//
//     }
//   }
}
