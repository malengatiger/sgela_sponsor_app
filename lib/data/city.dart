import 'package:json_annotation/json_annotation.dart';
import 'package:sgela_sponsor_app/data/state.dart';

import 'country.dart';

part 'city.g.dart';

@JsonSerializable()
class City {
  int? id;
  String? name;
  int? stateId;
  int? countryId;
  double latitude, longitude;

  City(this.id, this.name, this.stateId, this.countryId, this.latitude,
      this.longitude);

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);

  Map<String, dynamic> toJson() => _$CityToJson(this);
}
