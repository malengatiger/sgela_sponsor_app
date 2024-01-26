import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/services/auth_service.dart';
import 'package:sgela_sponsor_app/services/firestore_service.dart';
import 'package:sgela_sponsor_app/ui/busy_indicator.dart';
import 'package:sgela_sponsor_app/ui/dashboard.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';

import '../util/functions.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🧡🧡🧡🧡🧡🧡 SignIn: 🧡';

  AuthService authService = GetIt.instance<AuthService>();
  FirestoreService firestoreService = GetIt.instance<FirestoreService>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool _busy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _signIn() async {
    if ((emailController.text.isEmpty)) {
      showToast(message: 'Please enter your email', context: context);
      return;
    }
    if ((passwordController.text.isEmpty)) {
      showToast(message: 'Please enter your password', context: context);
      return;
    }
    pp('$mm ... start user sign in ...');
    setState(() {
      _busy = true;
    });
    try {
      var mUser = await authService.signIn(
          emailController.text, passwordController.text);
      if (mUser != null) {
        pp('$mm user signed in OK, user : ${mUser.toJson()}');
        if (mounted) {
          showToast(
              message: 'Signed in OK',
              padding: 24,
              backgroundColor: Colors.green,
              textStyle: myTextStyleMediumWithColor(context, Colors.white),
              context: context);
          var org =
              await firestoreService.getOrganization(mUser.organizationId!);

          if (mounted) {
            if (org != null) {
              Navigator.of(context).pop();
              NavigationUtils.navigateToPage(
                  context: context, widget: Dashboard(organization: org!));
            } else {
              throw Exception('User sign in failed');
            }
          }
        }
      }
    } catch (e) {
      pp(e);
      if (mounted) {
        showErrorDialog(context, '$e');
      }
    }
    setState(() {
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Card(
                elevation: 8,
                child: _busy
                    ? const BusyIndicator(
                        caption: 'Signing you in ...',
                        showClock: true,
                      )
                    : SignInForm(
                        passwordController: passwordController,
                        emailController: emailController,
                        onDone: () {
                          _signIn();
                        }),
              )
            ],
          );
        },
        tablet: (_) {
          return const Stack();
        },
        desktop: (_) {
          return const Stack();
        },
      ),
    ));
  }
}

class SignInForm extends StatelessWidget {
  const SignInForm(
      {super.key,
      required this.passwordController,
      required this.emailController,
      required this.onDone});

  final TextEditingController passwordController;
  final TextEditingController emailController;

  final Function onDone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 460,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'SignIn Form',
              style: myTextStyle(
                  context, Theme.of(context).primaryColor, 24, FontWeight.w900),
            ),
            gapH32,
            gapH16,
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Email Address'),
                  hintText: 'Please enter user email address'),
            ),
            gapH16,
            TextField(
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Password'),
                  hintText: 'Please enter your password'),
            ),
            gapH32,
            SizedBox(
              width: 300,
              child: ElevatedButton(
                  style: const ButtonStyle(
                    elevation: MaterialStatePropertyAll(8.0),
                  ),
                  onPressed: () {
                    onDone();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Sign In',
                      style: myTextStyle(
                          context,
                          Theme.of(context).primaryColor,
                          20,
                          FontWeight.normal),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
