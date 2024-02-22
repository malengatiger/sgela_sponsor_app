import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_sponsor_app/services/firestore_service_sponsor.dart';
import 'package:sgela_sponsor_app/services/rapyd_payment_service.dart';

import '../util/dio_util.dart';
import '../util/environment.dart';
import '../util/functions.dart';
import 'package:sgela_services/data/organization.dart';
import 'package:sgela_services/data/branding.dart';

class RepositoryService {
  final DioUtil dioUtil;
  final FirestoreService firestoreService;

  // final LocalDataService localDataService;

  static const mm = '💦💦💦💦 RepositoryService 💦';

  RepositoryService(
    this.dioUtil,
    this.prefs,
    this.paymentService,
    this.firestoreService,
  );

  final SponsorPrefs prefs;
  final RapydPaymentService paymentService;

  Future<Organization?> getSgelaOrganization() async {
    String prefix = SponsorsEnvironment.getSkunkUrl();
    String url = '${prefix}organizations/getSgelaOrganization';
    var result = await dioUtil.sendGetRequest(url, {});
    ppx('$mm ... response from call: $result');
    Organization org = Organization.fromJson(result);
    return org;
  }

  Future<Organization?> registerOrganization(Organization organization) async {
    String prefix = SponsorsEnvironment.getSkunkUrl();
    String url = '${prefix}organizations/addOrganization';
    ppx('$mm ...registerOrganization: calling: $url');

    var result = await dioUtil.sendPostRequest(url, organization.toJson());
    ppx('$mm ... response from call: $result');
    Organization org = Organization.fromJson(result);
    prefs.saveOrganization(org);
    prefs.saveCountry(org.country!);

    return org;
  }

  Future<Branding> uploadBrandingWithNoFiles(Branding branding) async {
    ppx('$mm ... uploadBrandingWithNoFiles ....');

    try {
      var prefix = SponsorsEnvironment.getSkunkUrl();
      var url = '${prefix}organizations/uploadBrandingWithNoFiles';
      ppx('$mm ... uploadBrandingWithNoFiles calling: $url');

      var res = await dioUtil.sendPostRequest(url, branding.toJson());
      ppx('$mm res; $res');

      var uploadedBranding = Branding.fromJson(res);
      if (uploadedBranding.logoUrl != null) {
        SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();
        prefs.saveLogoUrl(uploadedBranding.logoUrl!);
      }
      var mList =
          await firestoreService.getBranding(branding.organizationId!, true);

      ppx('$mm branding added, now we have ${mList.length}');
      return uploadedBranding;
      // }
    } catch (error, s) {
      ppx('$mm Error uploading branding: $error');
      ppx(s);
      throw Exception(
          'Sorry, Branding upload failed. Please try again in a minute');
    }
  }

  Future<Branding> uploadBranding(
      {required int organizationId,
      required String organizationName,
      required String tagLine,
      required String orgUrl,
      required int splashTimeInSeconds,
      required int colorIndex,
      required File? logoFile,
      required File? splashFile}) async {
    ppx('$mm Logo File: ${((await logoFile?.length())!/1024/1024).toStringAsFixed(2)} MB bytes');
    ppx('$mm Splash File: ${((await splashFile?.length())!/1024/1024).toStringAsFixed(2)} MB bytes');
    try {
      var prefix = SponsorsEnvironment.getSkunkUrl();
      var url = '';
      if (logoFile != null) {
        url = '${prefix}organizations/uploadBrandingWithLogo';
      } else {
        url = '${prefix}organizations/uploadBrandingWithoutLogo';
      }
      ppx('$mm ... uploadBranding calling: $url');
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['organizationId'] = '$organizationId';
      request.fields['organizationName'] = organizationName;
      request.fields['tagLine'] = tagLine;
      request.fields['orgUrl'] = orgUrl;
      request.fields['colorIndex'] = "$colorIndex";
      request.fields['splashTimeInSeconds'] = '$splashTimeInSeconds';

      if (logoFile != null) {
        request.files
            .add(await http.MultipartFile.fromPath('logoFile', logoFile.path));
      }

      if (splashFile != null) {
        request.files.add(
            await http.MultipartFile.fromPath('splashFile', splashFile!.path));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var uploadedBranding = Branding.fromJson(jsonDecode(responseData));
        if (uploadedBranding.logoUrl != null) {
          SponsorPrefs prefs = GetIt.instance<SponsorPrefs>();
          prefs.saveLogoUrl(uploadedBranding.logoUrl!);
        }
        var mList = await firestoreService.getBranding(organizationId, true);
        return uploadedBranding;
      } else {
        var responseData = await response.stream.bytesToString();
        ppx('$mm ERROR: $responseData');
      }
    } catch (error) {
      ppx('Error uploading branding: $error');
    }
    throw Exception(
        'Sorry, Branding upload failed. Please try again in a minute');
  }

  final StreamController<int> _streamController = StreamController.broadcast();

  Stream<int> get pageStream => _streamController.stream;
}
