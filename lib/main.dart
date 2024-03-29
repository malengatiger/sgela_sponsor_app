//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:sgela_services/sgela_util/dark_light_control.dart';
// import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
// import 'package:sgela_shared_widgets/util/styles.dart';
// import 'package:sgela_sponsor_app/in_app/In_app_driver.dart';
// import 'package:sgela_sponsor_app/services/register_services.dart';
// import 'package:sgela_sponsor_app/ui/landing_page.dart';
// import 'package:sgela_sponsor_app/util/functions.dart';
//
// import 'firebase_options.dart';
//
// //applIssuer ID: 4dc844a3-50e1-467d-b0d7-3f4a2404d2be sec:kkTiger3Khaya1#
// //apple server notif : https://api.revenuecat.com/v1/incoming-webhooks/apple-server-to-server-notification/tAktvwoyrFCHxaFiRulKIIzJpxXskFgl
//
// const String mx = '🍎🍎🍎 SgelaSponsorApp: ';
// ModeAndColor? modeAndColor;
//
// // Gives the option to override in tests.
// class IAPConnection {
//   static InAppPurchase? _instance;
//   static set instance(InAppPurchase value) {
//     _instance = value;
//   }
//
//   static InAppPurchase get instance {
//     _instance ??= InAppPurchase.instance;
//     return _instance!;
//   }
// }
// void dismissKeyboard(BuildContext context) {
//   final currentFocus = FocusScope.of(context);
//   if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
//     FocusManager.instance.primaryFocus?.unfocus();
//   }
// }
//
// void main() async {
//   ppx('$mx starting ..............................');
//
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     ppx('$mx SgelaAI Sponsor App Firebase.initializeApp ... ');
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     ppx('$mx Firebase has been initialized!! 🍀🍀name: ${Firebase.app().name}');
//     ppx('$mx Firebase has been initialized!! 🍀🍀options: ${Firebase.app().options.asMap}');
//
//     await ServiceRegistrar.registerSponsorServices(
//         FirebaseFirestore.instance, FirebaseAuth.instance);
//   } catch (e) {
//     ppx('\n\n👿👿👿Error initializing either Firebase '
//         'OR the bleeding services!! OR RevenueCat : 👿$e 👿\n\n');
//   }
//   //
//   runApp(const SgelaSponsorApp());
//
// }
//
// class SgelaSponsorApp extends StatelessWidget {
//   const SgelaSponsorApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     DarkLightControl dlc = GetIt.instance<DarkLightControl>();
//     SponsorPrefs mPrefs = GetIt.instance<SponsorPrefs>();
//     return StreamBuilder<ModeAndColor>(
//       stream: dlc.darkLightStream,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           modeAndColor = snapshot.data!;
//         }
//         return GestureDetector(
//           onTap: () {
//             dismissKeyboard(context);
//           },
//           child: MaterialApp(
//             title: 'SgelaSponsor',
//             debugShowCheckedModeBanner: false,
//             theme: _getTheme(context, mPrefs),
//             home: const LandingPage(),
//             // home: const InAppDriver() ,
//           ),
//         );
//       },
//     );
//   }
//
//   ThemeData _getTheme(BuildContext context, SponsorPrefs mPrefs )  {
//     var colorIndex = mPrefs.getColorIndex();
//     var mode = mPrefs.getMode();
//     if (mode == -1) {
//       mode = DARK;
//     }
//     if (mode == DARK) {
//       return ThemeData.dark().copyWith(
//         primaryColor:
//         getColors().elementAt(colorIndex), // Set the primary color
//       );
//     } else {
//       return ThemeData.light().copyWith(
//         primaryColor:
//         getColors().elementAt(colorIndex), // Set the primary color
//       );
//     }
//   }
//
// }

// Gives the option to override in tests.
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:sgela_services/sgela_util/dark_light_control.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_shared_widgets/util/styles.dart';
import 'package:sgela_sponsor_app/services/register_services.dart';
import 'package:sgela_sponsor_app/ui/landing_page.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:get_it/get_it.dart';

import 'firebase_options.dart';

const String mx = '🍎🍎🍎 SgelaSponsorApp: ';
ModeAndColor? modeAndColor;

// Gives the option to override in tests.
class IAPConnection {
  static InAppPurchase? _instance;
  static set instance(InAppPurchase value) {
    _instance = value;
  }

  static InAppPurchase get instance {
    _instance ??= InAppPurchase.instance;
    return _instance!;
  }
}
void dismissKeyboard(BuildContext context) {
  final currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
void main() async {
  ppx('$mx starting ..............................');

  WidgetsFlutterBinding.ensureInitialized();
  try {
    ppx('$mx SgelaAI Sponsor App Firebase.initializeApp ... ');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    ppx('$mx Firebase has been initialized!! 🍀🍀name: ${Firebase.app().name}');
    ppx('$mx Firebase has been initialized!! 🍀🍀options: ${Firebase.app().options.asMap}');

    final iapConnection = IAPConnection.instance;
    var connections = await iapConnection.isAvailable();
    ppx('$mx IAPConnection: 🍀isAvailable: 🍀$connections');

    await ServiceRegistrar.registerGoogleInAppPurchase();
    await ServiceRegistrar.registerSponsorServices(
        FirebaseFirestore.instance, FirebaseAuth.instance);
  } catch (e) {
    ppx('\n\n👿👿👿Error initializing either Firebase '
        'OR the bleeding services!! OR RevenueCat : 👿$e 👿\n\n');
  }
  runApp(const SgelaSponsorApp());
}

class SgelaSponsorApp extends StatelessWidget {
  const SgelaSponsorApp({super.key});

  @override
  Widget build(BuildContext context) {
    DarkLightControl dlc = GetIt.instance<DarkLightControl>();
    SponsorPrefs mPrefs = GetIt.instance<SponsorPrefs>();
    return StreamBuilder<ModeAndColor>(
      stream: dlc.darkLightStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          modeAndColor = snapshot.data!;
        }
        return GestureDetector(
          onTap: () {
            dismissKeyboard(context);
          },
          child: MaterialApp(
            title: 'SgelaSponsor',
            debugShowCheckedModeBanner: false,
            theme: _getTheme(context, mPrefs),
            home: const LandingPage(),
            // home: const InAppDriver() ,
          ),
        );
      },
    );
  }
}

  ThemeData _getTheme(BuildContext context, SponsorPrefs mPrefs )  {
    var colorIndex = mPrefs.getColorIndex();
    var mode = mPrefs.getMode();
    if (mode == -1) {
      mode = DARK;
    }
    if (mode == DARK) {
      return ThemeData.dark().copyWith(
        primaryColor:
        getColors().elementAt(colorIndex), // Set the primary color
      );
    } else {
      return ThemeData.light().copyWith(
        primaryColor:
        getColors().elementAt(colorIndex), // Set the primary color
      );
    }
  }
