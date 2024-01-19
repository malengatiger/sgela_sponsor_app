
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
class AuthService {

  static const mm = '💚💚💚💚AuthService 💚';
  static Future signIn(String email, String password) async {
    var auth = FirebaseAuth.instance;
    var creds = await auth.signInWithEmailAndPassword(email: email, password: password);
    pp('$mm ... device user signed in: ${creds.user?.email} 🥬🥬 ${creds.user?.displayName}');
  }
  static bool isSignedIn()  {
    if (FirebaseAuth.instance.currentUser == null) {
      return false;
    }
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if ((user != null)) {
        pp('authStateChanges, token: ${await user.getIdToken()}');
      }
    });
    return true;
  }
}
