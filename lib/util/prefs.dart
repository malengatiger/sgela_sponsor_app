import 'dart:convert';

import 'package:sgela_sponsor_app/data/rapyd/holder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/country.dart';
import '../data/organization.dart';
import '../data/user.dart';

class Prefs {
  final SharedPreferences sharedPreferences;

  Prefs(this.sharedPreferences);

  void saveUser(User user) {
    Map mJson = user.toJson();
    var jx = json.encode(mJson);
    sharedPreferences.setString('user', jx);
  }

  User? getUser() {
    var string = sharedPreferences.getString('user');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var user = User.fromJson(jx);
    return user;
  }

  void saveCountry(Country country) {
    Map mJson = country.toJson();
    var jx = json.encode(mJson);
    sharedPreferences.setString('country', jx);
  }

  Country? getCountry() {
    var string = sharedPreferences.getString('country');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var country = Country.fromJson(jx);
    return country;
  }
  void saveCustomer(Customer customer) {
    Map mJson = customer.toJson();
    var jx = json.encode(mJson);
    sharedPreferences.setString('customer', jx);
  }

  Customer? getCustomer() {
    var string = sharedPreferences.getString('customer');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var c = Customer.fromJson(jx);
    return c;
  }
  void saveOrganization(Organization organization) {
    Map mJson = organization.toJson();
    var jx = json.encode(mJson);
    sharedPreferences.setString('Organization', jx);
  }

  Organization? getOrganization() {
    var string = sharedPreferences.getString('Organization');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var org = Organization.fromJson(jx);
    return org;
  }

  void saveMode(int mode) {
    sharedPreferences.setInt('mode', mode);
  }

  int getMode() {
    var mode = sharedPreferences.getInt('mode');
    if (mode == null) {
      return -1;
    }
    return mode;
  }

  void saveColorIndex(int index)  {
    sharedPreferences.setInt('color', index);
    return null;
  }

  int getColorIndex() {
    var color = sharedPreferences.getInt('color');
    if (color == null) {
      return 0;
    }
    return color;
  }

  void saveLogoUrl(String logoUrl)  {
    sharedPreferences.setString('logoUrl', logoUrl);
  }

  String? getLogoUrl() {
    var url = sharedPreferences.getString('logoUrl');
    return url;
  }
}
