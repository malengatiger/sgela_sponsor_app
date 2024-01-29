
import 'package:json_annotation/json_annotation.dart';
import 'package:sgela_sponsor_app/data/user.dart';

import 'organization.dart';
part 'org_sponsoree.g.dart';
@JsonSerializable()

class OrgSponsoree {
  int? organizationId, id;
  String? date;
  String?
      organizationName;
  bool? activeFlag;
  User? user;


  OrgSponsoree(this.organizationId, this.id, this.date, this.organizationName,
      this.activeFlag, this.user);

  factory OrgSponsoree.fromJson(Map<String, dynamic> json) =>
      _$OrgSponsoreeFromJson(json);

  Map<String, dynamic> toJson() => _$OrgSponsoreeToJson(this);
}
