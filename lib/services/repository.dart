import 'dart:async';

import 'package:dio/dio.dart';


import '../data/organization.dart';
import '../util/dio_util.dart';
import '../util/environment.dart';
import '../util/functions.dart';

class Repository {
  final DioUtil dioUtil;

  final Dio dio;
  // final LocalDataService localDataService;

  static const mm = '💦💦💦💦 Repository 💦';

  Repository(this.dioUtil, this.dio);

  Future<Organization?> getSgelaOrganization() async {

    String prefix = ChatbotEnvironment.getSkunkUrl();
    String url = '${prefix}organizations/getSgelaOrganization';
    var result = await dioUtil.sendGetRequest(url, {});
    pp('$mm ... response from call: $result');
    Organization org = Organization.fromJson(result);
    return org;

  }


  final StreamController<int> _streamController = StreamController.broadcast();

  Stream<int> get pageStream => _streamController.stream;


}
