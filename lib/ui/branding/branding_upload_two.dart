import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sgela_sponsor_app/data/organization.dart';
import 'package:sgela_sponsor_app/services/repository.dart';
import 'package:sgela_sponsor_app/ui/widgets/org_logo_widget.dart';
import 'package:sgela_sponsor_app/util/prefs.dart';

import '../../data/branding.dart';
import '../../services/firestore_service.dart';
import '../../util/functions.dart';
import '../busy_indicator.dart';

class BrandingUploadTwo extends StatefulWidget {
  const BrandingUploadTwo(
      {super.key,
      required this.organization,
      required this.logoFile,
      required this.splashFile,
      required this.onBrandingUploaded});

  final Organization organization;
  final File? logoFile;
  final File splashFile;
  final Function(Branding) onBrandingUploaded;

  @override
  State<BrandingUploadTwo> createState() => _BrandingUploadTwoState();
}

class _BrandingUploadTwoState extends State<BrandingUploadTwo> {
  final TextEditingController taglineEditingController =
      TextEditingController();
  final TextEditingController linkEditingController = TextEditingController();

  final TextEditingController splashEditingController = TextEditingController();

  static const mm = '🥦🥦🥦🥦🥦🥦 BrandingUploadTwo 🔵🔵';
  FirestoreService firestoreService = GetIt.instance<FirestoreService>();

  RepositoryService repositoryService = GetIt.instance<RepositoryService>();
  Prefs prefs = GetIt.instance<Prefs>();

  bool _busy = false;
  Branding? branding;
  List<Branding> brandings = [];
  String? logoUrl;

  void _dismissKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  void initState() {
    super.initState();
    _getLogoUrl();
  }

  _getLogoUrl() {
    logoUrl = prefs.getLogoUrl();
  }

  _onSubmitBranding() async {
    pp('$mm ... _onSubmitBranding ...');

    _dismissKeyboard(context);
    var brand = Branding(
        organizationId: widget.organization.id!,
        id: null,
        date: DateTime.now().toIso8601String(),
        logoUrl: null,
        splashUrl: null,
        tagLine: taglineEditingController.text,
        organizationName: widget.organization.name!,
        organizationUrl: linkEditingController.text,
        splashTimeInSeconds: int.parse(splashEditingController.text),
        activeFlag: true);

    pp('$mm ... _onSubmitBranding ... submitting ${brand.toJson()}');

    setState(() {
      _busy = true;
    });
    try {
      branding = await repositoryService.uploadBranding(
          organizationId: widget.organization.id!,
          organizationName: widget.organization.name!,
          tagLine: taglineEditingController.text.isEmpty
              ? ''
              : taglineEditingController.text,
          orgUrl: linkEditingController.text.isEmpty
              ? ''
              : linkEditingController.text,
          logoFile: widget.logoFile,
          splashFile: widget.splashFile,
          splashTimeInSeconds: int.parse(splashEditingController.text));

      pp('$mm ... _onSubmitBranding completed! ${branding!.toJson()}...');

      brandings =
          await firestoreService.getBranding(widget.organization.id!, false);
      widget.onBrandingUploaded(branding!);
      if (mounted) {
        Navigator.of(context).pop(branding);
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
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Thumbnails(
                      logoFile: widget.logoFile, splashFile: widget.splashFile),
                  gapH32,
                  Text(
                    'This data is optional',
                    style: myTextStyleMediumWithColor(context, Colors.grey),
                  ),
                  gapH8,
                  TextField(
                    controller: taglineEditingController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: Text(
                          'Marketing Tagline',
                          style: myTextStyleSmall(context),
                        ),
                        hintText: 'Enter your marketing tagline'),
                  ),
                  gapH16,
                  TextField(
                    controller: linkEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: Text('Organization Information Link',
                            style: myTextStyleSmall(context)),
                        hintText: 'Enter your organization info link'),
                  ),
                  gapH16,
                  TextField(
                    controller: splashEditingController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: Text('Splash time in seconds',
                            style: myTextStyleSmall(context)),
                        hintText: 'Enter the seconds your splash image will show'),
                  ),
                  gapH32,
                  _busy
                      ? const BusyIndicator(
                          caption: 'Uploading your branding elements',
                        )
                      : ElevatedButton(
                          style: const ButtonStyle(
                            elevation: MaterialStatePropertyAll(8.0),
                          ),
                          onPressed: () {
                            _onSubmitBranding();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Upload Branding Materials'),
                          )),
                  gapH32,
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}

class Thumbnails extends StatelessWidget {
  const Thumbnails(
      {super.key,
      this.logoFile,
      required this.splashFile,
      this.logoHeight,
      this.splashHeight,
      this.logoUrl});

  final File? logoFile;
  final File splashFile;
  final String? logoUrl;

  final double? logoHeight, splashHeight;

  @override
  Widget build(BuildContext context) {
    Widget? image;
    if (logoUrl != null) {
      image = CachedNetworkImage(imageUrl: logoUrl!);
    }
    if (logoFile != null) {
      image = Image.file(logoFile!);
    }
    return Column(
      children: [
        SizedBox(
          height: logoHeight == null ? 32 : logoHeight!,
          child: image ?? gapW32,
        ),
        gapH8,
        SizedBox(
          height: splashHeight == null ? 240 : splashHeight!,
          width: 320,
          child: Image.file(
            splashFile,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
