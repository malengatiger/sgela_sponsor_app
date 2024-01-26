import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sgela_sponsor_app/services/register_services.dart';
import 'package:sgela_sponsor_app/ui/landing_page.dart';
import 'package:sgela_sponsor_app/util/dark_light_control.dart';
import 'package:sgela_sponsor_app/util/functions.dart';

import 'firebase_options.dart';

const String mx = '🍎 🍎 🍎 main: ';
ModeAndColor? modeAndColor;

void dismissKeyboard(BuildContext context) {
  final currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

void main() async {
  pp('$mx SgelaAI Sponsor App starting .... $mx');
  WidgetsFlutterBinding.ensureInitialized();
  try {
    pp('$mx SgelaAI Sponsor App Firebase.initializeApp ... ');

    await Firebase.initializeApp(
      // name: ChatbotEnvironment.getFirebaseName(),
      options: DefaultFirebaseOptions.currentPlatform,
    );
    pp('$mx Firebase has been initialized!! 🍀🍀name: ${Firebase.app().name}');
    pp('$mx Firebase has been initialized!! 🍀🍀options: ${Firebase.app().options.asMap}');

    await registerServices(
        FirebaseFirestore.instance); // Pass the firestore instance
    runApp(const MyApp());
  } catch (e) {
    pp('👿👿👿Error initializing Firebase: 👿$e 👿');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    DarkLightControl dlc = GetIt.instance<DarkLightControl>();
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
            theme: _getTheme(context),
            home: const LandingPage(),
          ),
        );
      },
    );
  }

  ThemeData _getTheme(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    if (modeAndColor == null) {
      return ThemeData.dark().copyWith(
        primaryColor: getColors().elementAt(0), // Set the primary color
      );
    }
    if (modeAndColor!.mode > -1) {
      if (modeAndColor?.mode == 0) {
        return ThemeData.light().copyWith(
          primaryColor: getColors()
              .elementAt(modeAndColor!.colorIndex), // Set the primary color
        );
      } else {
        return ThemeData.dark().copyWith(
          primaryColor: getColors()
              .elementAt(modeAndColor!.colorIndex), // Set the primary color
        );
      }
    }
    //
    var rand = Random(DateTime.now().millisecondsSinceEpoch);
    int index = rand.nextInt(getColors().length - 1);
    if (brightness == Brightness.dark) {
      return ThemeData.dark().copyWith(
        primaryColor: getColors().elementAt(index), // Set the primary color
      );
    } else {
      return ThemeData.light().copyWith(
        primaryColor: getColors().elementAt(index), // Set the primary color
      );
    }
  }
}
