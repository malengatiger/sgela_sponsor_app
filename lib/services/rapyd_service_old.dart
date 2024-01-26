import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sgela_sponsor_app/util/environment.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/prefs.dart';

import '../data/organization.dart';

class RapydServiceOld {
  // Declaring variables
  String _accessKey = "YOUR-ACCESS-KEY";
  String _secretKey = "YOUR-SECRET-KEY";
  String _baseUrl = "BASE_URL";

  RapydServiceOld() {
    _init();
  }

  static const mm = '☘️☘️☘️☘️☘️RapydService: ☘️';
  Prefs prefs = GetIt.instance<Prefs>();
  Organization? organization;

  _init() async {
    _accessKey = ChatbotEnvironment.getRapydAccessKey();
    _secretKey = ChatbotEnvironment.getRapydSecretKey();
    _baseUrl = ChatbotEnvironment.getRapydUrl();
    organization = prefs.getOrganization();
  }

  Future<Map> createCheckoutPage(double amount) async {
    final responseURL = Uri.parse("$_baseUrl/v1/checkout");
    final String body = jsonEncode(_getBody(amount));

    //making post request with headers and body.
    var response = await http.post(
      responseURL,
      headers: _getHeaders("/v1/checkout", 'post', body: body),
      body: body,
    );

    Map repBody = jsonDecode(response.body) as Map;
    //return data if request was successful
    if (response.statusCode == 200) {
      return repBody["data"] as Map;
    }

    //throw error if request was unsuccessful
    throw repBody["status"] as Map;
  }

  //Generating random string for each request with specific length as salt
  String _getRandString(int len) {
    var values = List<int>.generate(len, (i) => Random.secure().nextInt(256));
    return base64Url.encode(values);
  }

  //1. Generating body
  Map<String, String> _getBody(double amount) {
    return <String, String>{
      "amount": amount.toString(),
      "currency": organization!.country!.currencyName!,
      "country": organization!.country!.iso2!,
      "complete_checkout_url": "https://www.rapyd.net/cancel",
      "cancel_checkout_url": "https://www.rapyd.net/cancel"
    };
  }

  //2. Generating Signature
  String _getSignature(String httpMethod, String urlPath, String salt,
      String timestamp, String bodyString) {
    //concatenating string values together before hashing string according to Rapyd documentation
    String sigString = httpMethod +
        urlPath +
        salt +
        timestamp +
        _accessKey +
        _secretKey +
        bodyString;

    //passing the concatenated string through HMAC with the SHA256 algorithm
    Hmac hmac = Hmac(sha256, utf8.encode(_secretKey));
    Digest digest = hmac.convert(utf8.encode(sigString));
    var ss = hex.encode(digest.bytes);

    //base64 encoding the results and returning it.
    return base64UrlEncode(ss.codeUnits);
  }

  //3. Generating Headers
  Map<String, String> _getHeaders(String urlEndpoint, String method,
      {String body = ""}) {
    //generate a random string of length 16
    String salt = _getRandString(16);

    //calculating the unix timestamp in seconds
    String timestamp = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000)
        .round()
        .toString();

    //generating the signature for the request according to the docs
    String signature =
        _getSignature(method, urlEndpoint, salt, timestamp, body);
    var sig = calculateSignature(method, urlEndpoint,
        salt, timestamp, _accessKey, _secretKey, body);

    pp('$mm old signature: $signature');
    pp('$mm new signature: $sig');

    //Returning a map containing the headers and generated values
    return <String, String>{
      "access_key": _accessKey,
      "signature": sig,
      "salt": salt,
      "timestamp": timestamp,
      "Content-Type": "application/json",
    };
  }

  Future getCountryPaymentMethods() async {
//{{base_uri}}/payment_methods/country?country=ZA
    var countryCode = organization!.country!.iso2!;
    var currencyName = organization!.country!.currencyName!;
    var url = '${_baseUrl}payment_methods/country?country=$countryCode';
    pp('$mm ........ RAPYD url: $url');
    var headers = _getHeaders(url, 'get', body: "");
    pp('$mm ... headers ............');
    myPrettyJsonPrint(headers);
    //
    // Make the HTTP GET request
    http.Response response = await http.get(Uri.parse(url), headers: headers);
    pp('$mm ... RAPYD response, statusCode: ${response.statusCode} - ${response.body}');
    // Handle the response
    if (response.statusCode == 200) {
      // Successful response
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      pp('$mm ... RAPYD responseBody: $responseBody ');
    } else {
      // Error response
      pp('$mm  👿 👿Error StatusCode: ${response.statusCode}');
      pp('$mm  👿 👿Error Response body: ${response.body}');
    }
  }

  Future getPaymentMethodRequiredFields() async {}

  String calculateSignature(
    String httpMethod,
    String urlPath,
    String salt,
    String timestamp,
    String accessKey,
    String secretKey,
    String bodyString,
  ) {
    String sigString = httpMethod +
        urlPath +
        salt +
        timestamp +
        accessKey +
        secretKey +
        bodyString;

    List<int> bytes = utf8.encode(sigString);
    Digest digest = Hmac(sha256, utf8.encode(secretKey)).convert(bytes);
    String signature = base64.encode(digest.bytes);

    return signature;
  }
}
