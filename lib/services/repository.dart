import 'dart:async';

import 'package:dio/dio.dart';


import '../data/organization.dart';
import '../util/dio_util.dart';
import '../util/environment.dart';
import '../util/functions.dart';

class RepositoryService {
  final DioUtil dioUtil;

  // final LocalDataService localDataService;

  static const mm = '💦💦💦💦 RepositoryService 💦';

  RepositoryService(this.dioUtil);

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
    return org;

  }


  final StreamController<int> _streamController = StreamController.broadcast();

  Stream<int> get pageStream => _streamController.stream;


}
