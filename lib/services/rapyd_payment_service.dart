import 'package:get_it/get_it.dart';
import 'package:sgela_services/sgela_util/prefs.dart';
import 'package:sgela_sponsor_app/util/dio_util.dart';
import 'package:sgela_sponsor_app/util/environment.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_services/sgela_util/sponsor_prefs.dart';
import 'package:sgela_services/data/holder.dart';
class RapydPaymentService {
  final DioUtil dioUtil;
  static const mm = '🔵🔵🔵🔵🔵️RapydPaymentService: 🔵';

  RapydPaymentService(this.dioUtil, this.prefs);

  final SponsorPrefs prefs;

  var prefix = SponsorsEnvironment.getGeminiUrl();

  Future<RequiredFields> getPaymentMethodRequiredFields(
      String type) async {
    ppx('$mm ... getPaymentMethodRequiredFields .... type: $type');

    var raw = await dioUtil.sendGetRequest(
        "${prefix}rapyd/getPaymentMethodRequiredFields?type=$type", {});
    var status = Status.fromJson(raw['status']);
    RequiredFields reqFields = RequiredFields.fromJson(raw['data']);
    int cnt = 1;

      try {
        ppx('$mm ... RequiredFields for type: $type : 🌿🌿🌿 #$cnt 🍎🍎 ${reqFields.fields?.length}');
        if (reqFields.fields != null) {
          for (var field in reqFields.fields!) {
            ppx('$mm  name: ${field.name} type: ${field.type} description: ${field.description}');
          }
        }
        if (reqFields.payment_options != null) {
          for (var option in reqFields.payment_options!) {
            ppx('$mm  paymentOption:  🌀name: ${option.name} type: ${option.type} description: ${option.description}');
          }
        }
        if (reqFields.payment_method_options != null) {
          for (var option in reqFields.payment_method_options!) {
            ppx('$mm  paymentMethodOption:  🌀name: ${option.name} type: ${option.type} description: ${option.description}');
          }
        }
        ppx('\n\n');

      } catch (e,s) {
        ppx('$mm ... getPaymentMethodRequiredFields ERROR ... e: $e');
        ppx('$mm ... getPaymentMethodRequiredFields ERROR ... stackTrace: $s');

        ppx(reqFields);
      }
      cnt++;

    return reqFields;
  }
  final List<PaymentMethod> methods = [];
  final List<RequiredFields> requiredFieldsList = [];
  Future<List<PaymentMethod>> getCountryPaymentMethods(
      String countryCode) async {
    ppx('$mm ... getCountryPaymentMethods ....');
    var prefix = SponsorsEnvironment.getGeminiUrl();
    // var pms = prefs.getPaymentMethods();
    // if (pms.isNotEmpty) {
    //   pp('$mm ... getCountryPaymentMethods .... ${pms.length} found in cache');
    //   return pms;
    // }
    var raw = await dioUtil.sendGetRequest(
        "${prefix}rapyd/getCountryPaymentMethods?countryCode=$countryCode", {});
    var status = Status.fromJson(raw['status']);
    List mList = raw['data'];
    int cnt = 1;
    for (var m in mList) {
      try {
        var pm = PaymentMethod.fromJson(m);
        ppx('$mm ... payment method: 🍎🍎 #$cnt 🍎🍎 ${pm.name} \n');
        methods.add(pm);
        var rf = await getPaymentMethodRequiredFields(pm.type!);
        requiredFieldsList.add(rf);
      } catch (e,s) {
        ppx('$mm ... getCountryPaymentMethods ERROR ... e: $e');
        ppx('$mm ... getCountryPaymentMethods ERROR ... stackTrace: $s');
        ppx(m);
      }
      cnt++;
    }
    ppx('$mm ... getCountryPaymentMethods: save payment methods in prefs ... ${methods.length}');
    // prefs.savePaymentMethods(methods);
    return methods;
  }

  Future<Customer?> addCustomer(CustomerRequest customerReq) async {
    ppx(' ... addCustomer ....');
    var url = '${prefix}rapyd/createCustomer';
    var resp = await dioUtil.sendPostRequest(url, customerReq.toJson());
    var cr = CustomerResponse.fromJson(resp);
    ppx('$mm addCustomer response: ${cr.toJson()}');
    if (cr.data != null) {
      //prefs.saveCustomer(cr.data!);
    }
    return cr.data;
  }

  //  async addCustomerPaymentMethod(customer: string, type: string): Promise<any> {
  Future addCustomerPaymentMethod(String customer, String type) async {
    ppx(' ... addCustomerPaymentMethod ...');
    var url = '${prefix}rapyd/addCustomerPaymentMethod';
    var resp = await dioUtil.sendGetRequest(url, {
      "customer": customer,
      "type": type,
    });
    var cr = CustomerPaymentMethodResponse.fromJson(resp);
    ppx('$mm addCustomerPaymentMethod response:  🥬🥬🥬🥬 ${cr.toJson()}');
    return cr.data;
  }

  Future<Checkout> createCheckOut(CheckoutRequest request) async {
    ppx(' ... checkOut ....');
    var url = '${prefix}rapyd/createCheckout';
    var resp = await dioUtil.sendPostRequest(url, request.toJson());
    ppx('$mm raw response from createCheckOut: $resp');
    myPrettyJsonPrint(resp);
    var cr = CheckoutResponse.fromJson(resp);
    ppx('$mm createCheckOut response, will need redirect: ${cr.toJson()}');
    return cr.data!;
  }
  Future<PaymentResponse> createPaymentByCard(PaymentByCardRequest request) async {
    ppx(' ... createPaymentByCard ...');
    var url = '${prefix}rapyd/createPaymentByCard';
    var resp = await dioUtil.sendPostRequest(url, request.toJson());
    var cr = PaymentResponse.fromJson(resp);
    ppx('$mm createPaymentByCard response, will need redirect: ${cr.toJson()}');
    return cr;
  }

  Future<PaymentResponse> createPaymentByBankTransfer(PaymentByBankTransferRequest request) async {
    ppx(' ... payByBankTransfer ...');
    var url = '${prefix}rapyd/createPaymentByBankTransfer';
    var resp = await dioUtil.sendPostRequest(url, request.toJson());
    var cr = PaymentResponse.fromJson(resp);
    ppx('$mm payByBankTransfer response, will need redirect: ${cr.toJson()}');
    return cr;
  }
  Future<PaymentResponse> createPaymentByWallet(PaymentByWalletRequest request) async {
    ppx(' ... payByBankTransfer ...');
    var url = '${prefix}rapyd/createPaymentByWallet';
    var resp = await dioUtil.sendPostRequest(url, request.toJson());
    var cr = PaymentResponse.fromJson(resp);
    ppx('$mm createPaymentByWallet response, will need redirect: ${cr.toJson()}');
    return cr;
  }

  Future payByWallet() async {
    ppx(' ...');
  }

  Future getCustomerPayments() async {
    ppx(' ...');
  }
}
