import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart' as dx;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get_it/get_it.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sgela_services/sgela_util/functions.dart';
import 'package:sgela_services/sgela_util/prefs.dart';
import 'package:sgela_services/sgela_util/register_services.dart';
import 'package:sgela_shared_widgets/util/widget_prefs.dart';
import 'package:sgela_sponsor_app/services/firestore_service_sponsor.dart';
import 'package:sgela_sponsor_app/services/rapyd_payment_service.dart';
import 'package:sgela_sponsor_app/services/repository.dart';
import 'package:sgela_sponsor_app/util/sponsor_prefs.dart';
import 'package:sgela_sponsor_app/util/registration_stream_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/dio_util.dart';
import '../util/environment.dart';
import '../util/functions.dart';

class ServiceRegistrar {
  static const mm = '🍎🍎🍎🍎🍎🍎 ServiceRegistrar 🍎🍎🍎🍎🍎🍎';

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

    GetIt.instance.registerLazySingleton<FirestoreService>(
        () => firestoreService);
    GetIt.instance.registerLazySingleton<RegistrationStreamHandler>(
        () => RegistrationStreamHandler());
    GetIt.instance.registerLazySingleton<RepositoryService>(() =>
        RepositoryService(dioUtil, sponsorPrefs, rapydService, firestoreService));
    try {
      await firestoreService.getCountries();
      Gemini.init(apiKey: SponsorsEnvironment.getGeminiAPIKey());
      await registerServices(firebaseFirestore, firebaseAuth, Gemini.instance);
      ppx('$mm ... shared services registered!');
      await initializeRevenueCat();
    } catch (e, s) {
      ppx('`$e $s`');
    }

    ppx('$mm registerServices: GetIt has registered 9 services. 🍎 Cool!! 🍎🍎🍎');
  }

  static Future<void> initializeRevenueCat() async {
    String googleKey = SponsorsEnvironment.getRevenueGoogleKey();
    String appleKey = SponsorsEnvironment.getRevenueAppleKey();

    await Purchases.setLogLevel(LogLevel.info).catchError((err) {
      ppx('$mm RevenueCat: ERROR $err');
    }).timeout(const Duration(seconds: 60));

    late PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(googleKey);
      ppx('$mm RevenueCat subscriptions: Platform.isAndroid');
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(appleKey);
      ppx('$mm RevenueCat subscriptions: Platform.isIOS');
    }
    await Purchases.configure(configuration);
    ppx('$mm RevenueCat subscriptions initialized: ${configuration.store.toString()} '
        '- appUserID: ${configuration.appUserID}');
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
      pp("$mm ERROR: $e - $s");
    }
  }
}
