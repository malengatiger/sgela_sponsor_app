import 'package:firebase_core/firebase_core.dart';
import 'package:sgela_sponsor_app/util/prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';
import '../services/firestore_service.dart';
import '../services/repository.dart';
import 'dark_light_control.dart';
import 'dio_util.dart';
import 'environment.dart';
import 'functions.dart';

import 'package:firebase_core/firebase_core.dart';

Future<void> registerServices(FirebaseFirestore firebaseFirestore) async {
  pp('🍎🍎🍎🍎🍎🍎 registerServices: initialize service singletons with GetIt .... 🍎🍎🍎');

  Dio dio = Dio();
  var dioUtil = DioUtil(dio);
  var repository = Repository(dioUtil, dio);
  var prefs = Prefs(await SharedPreferences.getInstance());
  var dlc = DarkLightControl(prefs);
  var cWatcher = ColorWatcher(dlc, prefs);
  var firestoreService = FirestoreService(firebaseFirestore);
  GetIt.instance.registerLazySingleton<Prefs>(() => prefs);
  GetIt.instance.registerLazySingleton<ColorWatcher>(() => cWatcher);
  GetIt.instance.registerLazySingleton<DarkLightControl>(() => dlc);
  GetIt.instance.registerLazySingleton<Gemini>(() => Gemini.instance);
  GetIt.instance.registerLazySingleton<FirestoreService>(() => firestoreService);

  pp('🍎🍎🍎🍎🍎🍎 registerServices: GetIt has registered 14 services. 🍎 Cool!! 🍎🍎🍎');
}