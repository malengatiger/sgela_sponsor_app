import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/data/organization.dart';
import 'package:sgela_sponsor_app/services/firestore_service.dart';
import 'package:sgela_sponsor_app/ui/branding_upload_two.dart';
import 'package:sgela_sponsor_app/ui/widgets/image_picker_widget.dart';
import 'package:sgela_sponsor_app/ui/widgets/org_logo_widget.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';

import '../data/branding.dart';

class BrandingUploadOne extends StatefulWidget {
  const BrandingUploadOne({super.key,
    required this.organization, required this.onBrandingUploaded});

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
  static const mm = '❤️🧡💛💚💙💜 BrandUpload';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getBranding();
  }

  _getBranding() async {
    brandings = await firestoreService.getBranding(widget.organization.id!);
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

  void _checkFiles() {
    if (brandings.isNotEmpty) {
      if (splashFile != null) {
        setState(() {
          _showNextButton = true;
        });
        return;
      }
    }
    if (logoFile != null && splashFile != null) {
      setState(() {
        _showNextButton = true;
      });
    }
  }

  _onSplashPicked() async {
    pp('$mm ... _onSplashPicked: ${splashFile!.path}');
    _checkFiles();
  }

  _navigateToBrandText() async {
    pp('$mm ...... _navigateToBrandText ...');

    if (logoFile == null) {
      showToast(message: 'Please pick a logo image file', context: context);
      return;
    }
    if (logoFile == null) {
      showToast(message: 'Please pick a splash image file', context: context);
      return;
    }
    NavigationUtils.navigateToPage(
        context: context,
        widget: BrandingUploadTwo(
          onBrandingUploaded: (br){
            widget.onBrandingUploaded(br);
            Navigator.of(context).pop(br);
          },
          organization: widget.organization,
          logoFile: logoFile!,
          splashFile: splashFile!,
        ));
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
                  _showNextButton
                      ? ElevatedButton(
                          style: const ButtonStyle(
                            elevation: MaterialStatePropertyAll(8.0),
                          ),
                          onPressed: () {
                            _navigateToBrandText();
                          },
                          child: const Text('Next'))
                      : gapW32,
                  gapH16,
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
