import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/data/organization.dart';
import 'package:sgela_sponsor_app/services/firestore_service.dart';
import 'package:sgela_sponsor_app/ui/branding/branding_images_picker.dart';
import 'package:sgela_sponsor_app/ui/branding/branding_upload_two.dart';
import 'package:sgela_sponsor_app/ui/widgets/org_logo_widget.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';

import '../../data/branding.dart';
import '../../util/prefs.dart';

class BrandingUploadOne extends StatefulWidget {
  const BrandingUploadOne(
      {super.key,
      required this.organization,
      required this.onBrandingUploaded});

  final Organization organization;
  final Function(Branding) onBrandingUploaded;

  @override
  BrandingUploadOneState createState() => BrandingUploadOneState();
}

class BrandingUploadOneState extends State<BrandingUploadOne>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Branding> brandings = [];
  FirestoreService firestoreService = GetIt.instance<FirestoreService>();
  Prefs prefs = GetIt.instance<Prefs>();

  static const mm = '❤️🧡💛💚💙💜 BrandUpload';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getBranding();
  }

  _getBranding() async {
    logoUrl = prefs.getLogoUrl();
    brandings =
        await firestoreService.getBranding(widget.organization.id!, false);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  File? logoFile, splashFile;
  String? logoUrl, splashUrl, tagLine, orgUrl;
  bool _showNextButton = false;

  var taglineEditingController = TextEditingController();
  var linkEditingController = TextEditingController();

  _onLogoPicked() async {
    pp('$mm ... _onLogoPicked: ${logoFile!.path}');
    _checkFiles();
  }

  bool _checkFiles() {
    if (logoFile == null) {
      showToast(
          message: 'Pick the logo file',
          backgroundColor: Colors.black,
          padding: 20,
          context: context);
      return false;
    }
    if (splashFile == null) {
      showToast(
          message: 'Pick the splash file',
          backgroundColor: Colors.black,
          padding: 20,
          context: context);
      return false;
    }

    return false;
  }

  _onSplashPicked() async {
    pp('$mm ... _onSplashPicked: ${splashFile!.path}');
    _checkFiles();
  }

  _navigateToBrandingUploadTwo() async {
    pp('$mm ...... _navigateToBrandingUploadTwo ...');
    if (logoFile != null && splashFile != null) {
      NavigationUtils.navigateToPage(
          context: context,
          widget: BrandingUploadTwo(
            onBrandingUploaded: (br) {
              widget.onBrandingUploaded(br);
              Navigator.of(context).pop(br);
            },
            organization: widget.organization,
            logoFile: logoFile,
            splashFile: splashFile!,
          ));
      return;
    }

    var msg = 'No new files picked, no problem!';
    if (brandings.isEmpty) {
      msg = 'Please pick your logo and splash files';
    }
    showToast(
        message: msg,
        backgroundColor: Colors.black,
        padding: 24,
        textStyle: const TextStyle(color: Colors.amber),
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    Branding? branding;
    if (brandings.isNotEmpty) {
      branding = brandings.first;
    }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: OrgLogoWidget(
          branding: branding,
          logoUrl: logoUrl,
          height: 32,
        ),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: BrandingImagesPicker(
                          onLogoPicked: (f) {
                            logoFile = f;
                            setState(() {});
                            _onLogoPicked();
                          },
                          onSplashPicked: (f) {
                            splashFile = f;
                            setState(() {});
                            _onSplashPicked();
                          },
                          organization: widget.organization),
                    ),
                  ),
                  gapH8,
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                        style: const ButtonStyle(
                          elevation: MaterialStatePropertyAll(8.0),
                        ),
                        onPressed: () {
                          _navigateToBrandingUploadTwo();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('Next'),
                        )),
                  ),
                  gapH32,
                ],
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
