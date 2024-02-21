
import 'package:sgela_services/sgela_util/environment.dart';
import 'package:sgela_services/sgela_util/prefs.dart';
import 'package:sgela_services/sgela_util/register_services.dart';
import 'package:sgela_sponsor_app/services/firestore_service_sponsor.dart';
import 'package:sgela_sponsor_app/services/rapyd_payment_service.dart';
import 'package:dio/dio.dart' as dx;
import 'package:sgela_sponsor_app/util/prefs.dart';
import 'package:sgela_sponsor_app/util/registration_stream_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '../util/dio_util.dart';
import '../util/functions.dart';

class ServiceRegistrar {
  static Future<void> registerSponsorServices(
      FirebaseFirestore firebaseFirestore, FirebaseAuth firebaseAuth) async {
    ppx('🍎🍎🍎🍎🍎🍎 registerServices: initialize service singletons with GetIt .... 🍎🍎🍎');

    dx.Dio dio = dx.Dio();
    var dioUtil = DioUtil(dio);
    var prefs = Prefs(await SharedPreferences.getInstance());
    var rapydService = RapydPaymentService(dioUtil, prefs);
    var sh = await SharedPreferences.getInstance();
    GetIt.instance.registerLazySingleton<SponsorPrefs>(
            () => SponsorPrefs(sh));
    GetIt.instance.registerLazySingleton<FirestoreService>(
            () =>FirestoreService(firebaseFirestore, prefs));
    GetIt.instance.registerLazySingleton<RegistrationStreamHandler>(
            () => RegistrationStreamHandler());
    try {
      Gemini.init(apiKey: ChatbotEnvironment.getGeminiAPIKey());
      await registerServices(firebaseFirestore, firebaseAuth,
          Gemini.instance);
    } catch (e,s) {
      ppx('`$e $s`');
    }


    ppx('🍎🍎🍎🍎🍎🍎 registerServices: GetIt has registered 9 services. 🍎 Cool!! 🍎🍎🍎');
  }

}
