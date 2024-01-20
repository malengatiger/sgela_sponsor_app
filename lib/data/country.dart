
import 'package:json_annotation/json_annotation.dart';
part 'country.g.dart';

@JsonSerializable()
class Country {
  int? id;
  String? name, capital, currencyName, currencySymbol,
      emoji, iso2, iso3, phoneCode, region, subregion, numericCode;
  double? latitude, longitude;


  Country(
      this.id,
      this.name,
      this.capital,
      this.currencyName,
      this.currencySymbol,
      this.emoji,
      this.iso2,
      this.iso3,
      this.phoneCode,
      this.region,
      this.subregion,
      this.numericCode,
      this.latitude,
      this.longitude);

  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);

  Map<String, dynamic> toJson() => _$CountryToJson(this);
}
