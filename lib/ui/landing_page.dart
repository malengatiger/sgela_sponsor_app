import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/data/organization.dart';
import 'package:sgela_sponsor_app/services/firestore_service.dart';
import 'package:sgela_sponsor_app/ui/dashboard.dart';
import 'package:sgela_sponsor_app/ui/registration_form.dart';
import 'package:sgela_sponsor_app/ui/sign_in.dart';
import 'package:sgela_sponsor_app/ui/widgets/org_logo_widget.dart';
import 'package:sgela_sponsor_app/util/environment.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';
import 'package:sgela_sponsor_app/util/prefs.dart';

import '../data/branding.dart';
import '../util/functions.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = ' 🍐🍐🍐🍐 LandingPage  🍐🍐';
  Organization? organization;
  Prefs prefs = GetIt.instance<Prefs>();
  List<Branding> brandings = [];
  FirestoreService firestoreService = GetIt.instance<FirestoreService>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getOrg();
  }

  _getOrg() async {
    organization = prefs.getOrganization();
    if (organization != null) {
      _navigateToDashboard();
      brandings = await firestoreService.getBranding(organization!.id!);
    }
  }

  _navigateToRegistration() async {
    NavigationUtils.navigateToPage(
        context: context,
        widget: RegistrationForm(
          onRegistered: (org) {
            setState(() {
              organization = org;
            });
            Future.delayed(const Duration(milliseconds: 1000),(){
              _navigateToDashboard();
            });
          },
        ));
  }

  _navigateToSignIn() async {
    await NavigationUtils.navigateToPage(
        context: context, widget: const SignIn());
  }

  _navigateToDashboard() {
    Future.delayed(const Duration(milliseconds: 100), (){
      NavigationUtils.navigateToPage(context: context, widget: Dashboard(organization: organization!));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var logoUrl = ChatbotEnvironment.sgelaLogoUrl;
    var splashUrl = ChatbotEnvironment.sgelaSplashUrl;
    if (organization != null) {
      if (organization!.logoUrl != null) {
        logoUrl = organization!.logoUrl!;
      }
      if (organization!.splashUrl != null) {
        splashUrl = organization!.splashUrl!;
      }
    }
    var width = MediaQuery.of(context).size.width;
    Branding? branding;
    if (brandings.isNotEmpty) {
      branding = brandings.first;
    }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            OrgLogoWidget(
              branding: branding,
            )
          ],
        ),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Card(
                elevation: 8,
                child: Column(
                  children: [
                    Expanded(
                        child: CachedNetworkImage(
                      imageUrl: splashUrl,
                      fit: BoxFit.cover,
                      width: width,
                    )),
                    SizedBox(
                      height: 80,
                      child: Card(
                        elevation: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                                style: const ButtonStyle(
                                  elevation: MaterialStatePropertyAll(8),
                                ),
                                onPressed: () {
                                  _navigateToSignIn();
                                },
                                child: const Text('Sponsor Sign In')),
                            ElevatedButton(
                                style: const ButtonStyle(
                                  elevation: MaterialStatePropertyAll(8),
                                ),
                                onPressed: () {
                                  _navigateToRegistration();
                                },
                                child: const Text('Sponsor Registration')),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                  left: 16,
                  right: 16,
                  top: 100,
                  bottom: 100,
                  child: Card(
                    color: Colors.black54,
                    elevation: 16,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          text,
                          style: myTextStyle(
                              context, Colors.white60, 18, FontWeight.normal),
                        ),
                      ),
                    ),
                  ))
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

  static const text =
      'Explore a diverse collection of examinations covering a wide spectrum of subjects. SgelaAI empowers students with targeted practice materials, ensuring a thorough understanding of each topic. \n\nFrom mathematics to literature, science to languages, '
      'SgelaAI provides the resources you need to excel.';
}
