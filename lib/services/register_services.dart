import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get_it/get_it.dart';
import 'package:sgela_sponsor_app/services/auth_service.dart';
import 'package:sgela_sponsor_app/services/rapyd_payment_service.dart';
import 'package:sgela_sponsor_app/util/prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/dark_light_control.dart';
import '../util/dio_util.dart';
import '../util/functions.dart';
import 'firestore_service.dart';
import 'repository.dart';

Future<void> registerServices(FirebaseFirestore firebaseFirestore) async {
  pp('🍎🍎🍎🍎🍎🍎 registerServices: initialize service singletons with GetIt .... 🍎🍎🍎');

  Dio dio = Dio();
  var dioUtil = DioUtil(dio);
  var prefs = Prefs(await SharedPreferences.getInstance());
  var rapydService = RapydPaymentService(dioUtil, prefs);
  var dlc = DarkLightControl(prefs);
  var cWatcher = ColorWatcher(dlc, prefs);
  var firestoreService = FirestoreService(firebaseFirestore, prefs);
  var repository =
      RepositoryService(dioUtil, prefs, rapydService, firestoreService);

  GetIt.instance.registerLazySingleton<Prefs>(() => prefs);
  GetIt.instance.registerLazySingleton<ColorWatcher>(() => cWatcher);
  GetIt.instance.registerLazySingleton<DarkLightControl>(() => dlc);
  GetIt.instance.registerLazySingleton<Gemini>(() => Gemini.instance);
  GetIt.instance
      .registerLazySingleton<FirestoreService>(() => firestoreService);
  GetIt.instance.registerLazySingleton<RepositoryService>(() => repository);
  GetIt.instance.registerLazySingleton<AuthService>(() => AuthService());
  GetIt.instance.registerLazySingleton<RapydPaymentService>(() => rapydService);

  initializeApp(prefs, cWatcher, firestoreService, rapydService);

  pp('🍎🍎🍎🍎🍎🍎 registerServices: GetIt has registered 8 services. 🍎 Cool!! 🍎🍎🍎');
}

void initializeApp(Prefs prefs, ColorWatcher cWatcher,
    FirestoreService firestoreService, RapydPaymentService rapydService) {
  var index = prefs.getColorIndex();
  cWatcher.setColor(index);

  var org = prefs.getOrganization();
  if (org != null) {
    firestoreService.getBranding(org.id!, false);
    rapydService.getCountryPaymentMethods(org.country!.iso2!);
    firestoreService.getSponsorProducts(false);
  }
}
