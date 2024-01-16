import 'package:json_annotation/json_annotation.dart';
import 'package:sgela_sponsor_app/data/user.dart';

import 'city.dart';
import 'country.dart';

part 'organization.g.dart';

@JsonSerializable()
class Organization {
  String? name, email, cellphone;
  int? id;
  Country? country;
  City? city;

  int? coverageRadiusInKM;
  String? date;
  bool? exclusiveCoverage;
  String? logoUrl, splashUrl, tagLine;

  User? adminUser;


  Organization(
      {required this.name, required this.email, required this.cellphone, this.id, required this.country,
        required this.city, this.logoUrl, this.splashUrl, this.adminUser, this.coverageRadiusInKM, required this.date,
        this.exclusiveCoverage, this.tagLine});

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = _$OrganizationToJson(this);

    if (country != null) {
      data['country'] = country!.toJson();
    }
    if (city != null) {
      data['city'] = city!.toJson();
    }
    if (adminUser != null) {
      data['adminUser'] = adminUser!.toJson();
    }

    return data;
  }}

// Map<String, dynamic> toJson() {
//   var mCity = {};
//   var mCountry = {};
//   var mUser = {};
//
//
//   if (city != null) {
//     mCity = city!.toJson();
//   }
//   if (country != null) {
//     mCountry = country!.toJson();
//   }
//   if (adminUser != null) {
//     mUser = adminUser!.toJson();
//   }
//   Map<String, dynamic> data = {};
//   data['id'] = id;
//   data['logoUrl'] = logoUrl;
//   data['date'] = date;
//   data['coverageRadiusInKM'] = coverageRadiusInKM;
//   data['exclusiveCoverage'] = exclusiveCoverage;
//   data['splashUrl'] = splashUrl;
//   data['tagLine'] = tagLine;
//   data['city'] = mCity;
//   data['country'] = mCountry;
//   data['adminUser'] = mUser;
//
//   return data;
// }
//
// Organization.fromJson(Map<String, dynamic> data) {
//   id = data['id'];
//   logoUrl = data['logoUrl'];
//   splashUrl = data['splashUrl'];
//   date = data['date'];
//   coverageRadiusInKM = data['coverageRadiusInKM'];
//   exclusiveCoverage = data['exclusiveCoverage'];
//   tagLine = data['tagLine'];
//   splashUrl = data['splashUrl'];
//   city = city == null ? null : City.fromJson(data['city']);
//   country = country == null ? null : Country.fromJson(data['country']);
//   adminUser = adminUser == null ? null : User.fromJson(data['adminUser']);
//
// }
// }
