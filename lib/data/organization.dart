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
      {required this.name,
      required this.email,
      required this.cellphone,
      this.id,
      required this.country,
      required this.city,
      this.logoUrl,
      this.splashUrl,
      this.adminUser,
      this.coverageRadiusInKM,
      required this.date,
      this.exclusiveCoverage,
      this.tagLine});

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
  }
}

