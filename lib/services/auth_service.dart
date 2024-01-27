
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get_it/get_it.dart';
import 'package:sgela_sponsor_app/services/firestore_service.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/prefs.dart';

import '../data/user.dart';
class AuthService {

  static const mm = '💚💚💚💚AuthService 💚';
  FirestoreService firestoreService = GetIt.instance<FirestoreService>();
  Prefs prefs = GetIt.instance<Prefs>();


   bool isSignedIn()  {
    if (auth.FirebaseAuth.instance.currentUser == null) {
      return false;
    }
    auth.FirebaseAuth.instance.authStateChanges().listen((user) async {
      if ((user != null)) {
        pp('authStateChanges, token: ${await user.getIdToken()}');
      }
    });
    return true;
  }
   Future<User?> signIn(String email, String password) async {
    var mAuth = auth.FirebaseAuth.instance;
    var creds = await mAuth.signInWithEmailAndPassword(email: email, password: password);
    if (creds.user != null) {
      pp('$mm ... device user signed in: ${creds.user?.email} 🥬🥬 ${creds.user?.displayName}');
      var user = await firestoreService.getUser(creds.user!.uid);
      if (user != null) {
        pp('$mm ... getting all the basic data needed ..... user: ${user.toJson()}');
        prefs.saveUser(user);
        await firestoreService.getCountries();
        var org = await firestoreService.getOrganization(user.organizationId!);
        if (org != null) {
          pp('$mm ... getting all the basic data needed ..... organization: ${user.toJson()}');
          prefs.saveOrganization(org);
          await firestoreService.getSponsorProducts(true);
          await firestoreService.getUsers(org.id!,true);
          var brandings = await firestoreService.getBranding(org.id!, true);
          String? logoUrl;
          for (var b in brandings) {
            if (b.logoUrl != null) {
              logoUrl = b.logoUrl!;
            }
          }
          if (logoUrl != null) {
            prefs.saveLogoUrl(logoUrl);
          }
        }
        pp('$mm ... user signed in and org data cached!');
        return user;
      }
    }
    return null;
  }
  Future authenticateUser(User user) async {
     pp('$mm ... createUserWithEmailAndPassword for new user ...');
    user.id = generateUniqueKey();
    var creds = await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email!, password: "pass123");
    if (creds.user != null) {
      user.firebaseUserId = creds.user!.uid;
      user.date = DateTime.now().toIso8601String();
      user.activeFlag = true;
      user.password = null;

      firestoreService.addUser(user);
    }
    pp('$mm ... new user created, sending sign in email link ...user email: ${user.toJson()}');
     try {
       await auth.FirebaseAuth.instance.sendSignInLinkToEmail(email: user.email!, actionCodeSettings:
           _getActionCodeSettings(user.id!));
       pp('$mm ... authenticated and email sign in link sent: ${user.toJson()}');

     } catch (e) {
       pp(e);
     }
  }
  auth.ActionCodeSettings _getActionCodeSettings(int userId) {
     //todo - Sort the ActionCodeSettings url parameter
    var acs = auth.ActionCodeSettings(
      // URL you want to redirect back to. The domain (www.example.com) for this
      // URL must be whitelisted in the Firebase Console.
        url: 'https://sgela-ai-33.firebaseapp.com/organizations/finishSignUp?userId=$userId',
        // This must be true
        handleCodeInApp: true,
        iOSBundleId: 'com.boha.sgelaSponsorApp',
        androidPackageName: 'com.boha.sgela_sponsor_app',
        // installIfNotAvailable
        androidInstallApp: true,
        // minimumVersion
        androidMinimumVersion: '21');
    return acs;
  }
}
