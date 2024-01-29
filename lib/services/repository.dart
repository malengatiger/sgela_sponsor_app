import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sgela_sponsor_app/data/branding.dart';
import 'package:sgela_sponsor_app/services/firestore_service.dart';
import 'package:sgela_sponsor_app/services/rapyd_payment_service.dart';
import 'package:sgela_sponsor_app/util/prefs.dart';

import '../data/organization.dart';
import '../util/dio_util.dart';
import '../util/environment.dart';
import '../util/functions.dart';

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

  final Prefs prefs;
  final RapydPaymentService paymentService;

  Future<Organization?> getSgelaOrganization() async {
    String prefix = ChatbotEnvironment.getSkunkUrl();
    String url = '${prefix}organizations/getSgelaOrganization';
    var result = await dioUtil.sendGetRequest(url, {});
    pp('$mm ... response from call: $result');
    Organization org = Organization.fromJson(result);
    return org;
  }

  Future<Organization?> registerOrganization(Organization organization) async {
    String prefix = ChatbotEnvironment.getSkunkUrl();
    String url = '${prefix}organizations/addOrganization';
    pp('$mm ... calling: $url');

    var result = await dioUtil.sendPostRequest(url, organization.toJson());
    pp('$mm ... response from call: $result');
    Organization org = Organization.fromJson(result);
    prefs.saveOrganization(org);
    prefs.saveCountry(org.country!);

    return org;
  }

  Future<Branding> uploadBranding(
      {required int organizationId,
      required String organizationName,
      required String tagLine,
      required String orgUrl,
      required int splashTimeInSeconds,
      required File? logoFile,
      required File splashFile}) async {
    try {
      var prefix = ChatbotEnvironment.getSkunkUrl();
      var url = '';
      if (logoFile != null) {
        url = '${prefix}organizations/uploadBrandingWithLogo';
      } else {
        url = '${prefix}organizations/uploadBrandingWithoutLogo';
      }
      pp('$mm ... uploadBranding calling: $url');
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['organizationId'] = '$organizationId';
      request.fields['organizationName'] = organizationName;
      request.fields['tagLine'] = tagLine;
      request.fields['orgUrl'] = orgUrl;
      request.fields['splashTimeInSeconds'] = '$splashTimeInSeconds';

      if (logoFile != null) {
        request.files
            .add(await http.MultipartFile.fromPath('logoFile', logoFile.path));
      }

      request.files.add(
          await http.MultipartFile.fromPath('splashFile', splashFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var uploadedBranding = Branding.fromJson(jsonDecode(responseData));
        if (uploadedBranding.logoUrl != null) {
          Prefs prefs = GetIt.instance<Prefs>();
          prefs.saveLogoUrl(uploadedBranding.logoUrl!);
        }
        var mList = await firestoreService.getBranding(organizationId, true);
        return uploadedBranding;
      } else {
        var responseData = await response.stream.bytesToString();
        pp('$mm ERROR: $responseData');
      }
    } catch (error) {
      pp('Error uploading branding: $error');
    }
    throw Exception(
        'Sorry, Branding upload failed. Please try again in a minute');
  }

  final StreamController<int> _streamController = StreamController.broadcast();

  Stream<int> get pageStream => _streamController.stream;
}
