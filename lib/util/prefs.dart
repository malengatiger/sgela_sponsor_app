import 'dart:convert';

import 'package:sgela_sponsor_app/data/branding.dart';
import 'package:sgela_sponsor_app/data/rapyd/holder.dart';
import 'package:sgela_sponsor_app/data/sponsor_product.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/country.dart';
import '../data/organization.dart';
import '../data/user.dart';

class Prefs {
  final SharedPreferences sharedPreferences;

  Prefs(this.sharedPreferences);

  saveSponsorProducts(List<SponsorProduct> sponsorProducts) {
    List<Map<String, dynamic>> productStrings =
        sponsorProducts.map((pm) => pm.toJson()).toList();
    List<String> productJsonStrings =
        productStrings.map((pm) => json.encode(pm)).toList();
    sharedPreferences.setStringList('products', productJsonStrings);
  }

  List<SponsorProduct> getSponsorProducts() {
    List<String>? paymentMethodJsonStrings =
        sharedPreferences.getStringList('products');
    if (paymentMethodJsonStrings != null) {
      List<SponsorProduct> paymentMethods = paymentMethodJsonStrings
          .map((pmJson) => SponsorProduct.fromJson(json.decode(pmJson)))
          .toList();
      return paymentMethods;
    } else {
      return [];
    }
  }
  //
  saveCountries(List<Country> countries) {
    List<Map<String, dynamic>> countryStrings =
    countries.map((pm) => pm.toJson()).toList();
    List<String> countryJsonStrings =
    countryStrings.map((pm) => json.encode(pm)).toList();
    sharedPreferences.setStringList('countries', countryJsonStrings);
  }

  List<Country> getCountries() {
    List<String>? paymentMethodJsonStrings =
    sharedPreferences.getStringList('countries');
    if (paymentMethodJsonStrings != null) {
      List<Country> paymentMethods = paymentMethodJsonStrings
          .map((pmJson) => Country.fromJson(json.decode(pmJson)))
          .toList();
      return paymentMethods;
    } else {
      return [];
    }
  }
  //
  saveBranding(List<Branding> brandings) {
    List<Map<String, dynamic>> brandingStrings =
    brandings.map((pm) => pm.toJson()).toList();
    List<String> brandingJsonStrings =
    brandingStrings.map((pm) => json.encode(pm)).toList();
    sharedPreferences.setStringList('brandings', brandingJsonStrings);
  }

  List<Branding> getBrandings() {
    List<String>? brandingJsonStrings =
    sharedPreferences.getStringList('brandings');
    if (brandingJsonStrings != null) {
      List<Branding> brandings = brandingJsonStrings
          .map((pmJson) => Branding.fromJson(json.decode(pmJson)))
          .toList();
      return brandings;
    } else {
      return [];
    }
  }
  //
  saveUsers(List<User> users) {
    List<Map<String, dynamic>> userStrings =
    users.map((pm) => pm.toJson()).toList();
    List<String> userJsonStrings =
    userStrings.map((pm) => json.encode(pm)).toList();
    sharedPreferences.setStringList('users', userJsonStrings);
  }

  List<User> getUsers() {
    List<String>? userJsonStrings =
    sharedPreferences.getStringList('users');
    if (userJsonStrings != null) {
      List<User> users = userJsonStrings
          .map((pmJson) => User.fromJson(json.decode(pmJson)))
          .toList();
      return users;
    } else {
      return [];
    }
  }
  // Save the list of PaymentMethod to SharedPreferences
  savePaymentMethods(List<PaymentMethod> paymentMethods) {
    List<Map<String, dynamic>> paymentMethodStrings =
        paymentMethods.map((pm) => pm.toJson()).toList();
    List<String> paymentMethodJsonStrings =
        paymentMethodStrings.map((pm) => json.encode(pm)).toList();
    sharedPreferences.setStringList('paymentMethods', paymentMethodJsonStrings);
  }

// Retrieve the list of PaymentMethod from SharedPreferences
  List<PaymentMethod> getPaymentMethods() {
    List<String>? paymentMethodJsonStrings =
        sharedPreferences.getStringList('paymentMethods');
    if (paymentMethodJsonStrings != null) {
      List<PaymentMethod> paymentMethods = paymentMethodJsonStrings
          .map((pmJson) => PaymentMethod.fromJson(json.decode(pmJson)))
          .toList();
      return paymentMethods;
    } else {
      return [];
    }
  }

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

  void saveColorIndex(int index) {
    sharedPreferences.setInt('color', index);
  }

  int getColorIndex() {
    var color = sharedPreferences.getInt('color');
    if (color == null) {
      return 0;
    }
    return color;
  }

  void saveLogoUrl(String logoUrl) {
    sharedPreferences.setString('logoUrl', logoUrl);
  }

  String? getLogoUrl() {
    var url = sharedPreferences.getString('logoUrl');
    return url;
  }
}
