import 'package:sgela_sponsor_app/data/country.dart';
import 'package:json_annotation/json_annotation.dart';
part 'pricing.g.dart';
@JsonSerializable()

class Pricing {
  double? monthlyPrice, annualPrice;
  String? currency;
  String? date;
  int? countryId;
  int? id;


  Pricing(this.monthlyPrice, this.annualPrice, this.currency, this.date,
      this.countryId, this.id);

  factory Pricing.fromJson(Map<String, dynamic> json) =>
      _$PricingFromJson(json);

  Map<String, dynamic> toJson() => _$PricingToJson(this);
}
