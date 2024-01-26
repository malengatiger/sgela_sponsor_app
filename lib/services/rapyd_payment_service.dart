import 'package:get_it/get_it.dart';
import 'package:sgela_sponsor_app/data/rapyd/holder.dart';
import 'package:sgela_sponsor_app/util/dio_util.dart';
import 'package:sgela_sponsor_app/util/environment.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/prefs.dart';

class RapydPaymentService {
  final DioUtil dioUtil;
  static const mm = '🔵🔵🔵🔵🔵️RapydPaymentService: 🔵';

  RapydPaymentService(this.dioUtil, this.prefs);

  final Prefs prefs;

  var prefix = ChatbotEnvironment.getGeminiUrl();

  Future<RequiredFields> getPaymentMethodRequiredFields(
      String type) async {
    pp('$mm ... getPaymentMethodRequiredFields .... type: $type');

    var raw = await dioUtil.sendGetRequest(
        "${prefix}rapyd/getPaymentMethodRequiredFields?type=$type", {});
    var status = Status.fromJson(raw['status']);
    RequiredFields reqFields = RequiredFields.fromJson(raw['data']);
    int cnt = 1;

      try {
        pp('$mm ... RequiredFields for type: $type : 🌿🌿🌿 #$cnt 🍎🍎 ${reqFields.fields?.length}');
        if (reqFields.fields != null) {
          for (var field in reqFields.fields!) {
            pp('$mm  name: ${field.name} type: ${field.type} description: ${field.description}');
          }
        }
        if (reqFields.payment_options != null) {
          for (var option in reqFields.payment_options!) {
            pp('$mm  paymentOption:  🌀name: ${option.name} type: ${option.type} description: ${option.description}');
          }
        }
        if (reqFields.payment_method_options != null) {
          for (var option in reqFields.payment_method_options!) {
            pp('$mm  paymentMethodOption:  🌀name: ${option.name} type: ${option.type} description: ${option.description}');
          }
        }
        pp('\n\n');

      } catch (e,s) {
        pp('$mm ... getPaymentMethodRequiredFields ERROR ... e: $e');
        pp('$mm ... getPaymentMethodRequiredFields ERROR ... stackTrace: $s');

        pp(reqFields);
      }
      cnt++;

    return reqFields;
  }
  final List<PaymentMethod> methods = [];
  final List<RequiredFields> requiredFieldsList = [];
  Future<List<PaymentMethod>> getCountryPaymentMethods(
      String countryCode) async {
    pp('$mm ... getCountryPaymentMethods ....');
    var prefix = ChatbotEnvironment.getGeminiUrl();

    var raw = await dioUtil.sendGetRequest(
        "${prefix}rapyd/getCountryPaymentMethods?countryCode=$countryCode", {});
    var status = Status.fromJson(raw['status']);
    List mList = raw['data'];
    int cnt = 1;
    for (var m in mList) {
      try {
        var pm = PaymentMethod.fromJson(m);
        pp('$mm ... payment method: 🍎🍎 #$cnt 🍎🍎 ${pm.name} \n');
        methods.add(pm);
        var rf = await getPaymentMethodRequiredFields(pm.type!);
        requiredFieldsList.add(rf);
      } catch (e,s) {
        pp('$mm ... getCountryPaymentMethods ERROR ... e: $e');
        pp('$mm ... getCountryPaymentMethods ERROR ... stackTrace: $s');

        pp(m);
      }
      cnt++;
    }

    return methods;
  }

  Future<Customer?> addCustomer(CustomerRequest customerReq) async {
    pp(' ... addCustomer ....');
    var url = '${prefix}rapyd/createCustomer';
    var resp = await dioUtil.sendPostRequest(url, customerReq.toJson());
    var cr = CustomerResponse.fromJson(resp);
    pp('$mm addCustomer response: ${cr.toJson()}');
    if (cr.data != null) {
      prefs.saveCustomer(cr.data!);
    }
    return cr.data;
  }

  Future addCustomerPaymentMethod(AddCustomerPaymentMethodRequest request) async {
    pp(' ... addCustomerPaymentMethod ...');
    var url = '${prefix}rapyd/addCustomerPaymentMethod';
    var resp = await dioUtil.sendPostRequest(url, request.toJson());
    var cr = AddCustomerPaymentMethodResponse.fromJson(resp);
    pp('$mm addCustomerPaymentMethod response: ${cr.toJson()}');
    return cr.data;
  }

  Future<Checkout> createCheckOut(CheckoutRequest request) async {
    pp(' ... checkOut ....');
    var url = '${prefix}rapyd/createCheckout';
    var resp = await dioUtil.sendPostRequest(url, request.toJson());
    var cr = CheckoutResponse.fromJson(resp);
    pp('$mm createCheckOut response, will need redirect: ${cr.toJson()}');
    return cr.data!;
  }
  Future<PaymentResponse> createPaymentByCard(PaymentByCardRequest request) async {
    pp(' ... createPaymentByCard ...');
    var url = '${prefix}rapyd/createPaymentByCard';
    var resp = await dioUtil.sendPostRequest(url, request.toJson());
    var cr = PaymentResponse.fromJson(resp);
    pp('$mm createPaymentByCard response, will need redirect: ${cr.toJson()}');
    return cr;
  }

  Future<PaymentResponse> createPaymentByBankTransfer(PaymentByBankTransferRequest request) async {
    pp(' ... payByBankTransfer ...');
    var url = '${prefix}rapyd/createPaymentByBankTransfer';
    var resp = await dioUtil.sendPostRequest(url, request.toJson());
    var cr = PaymentResponse.fromJson(resp);
    pp('$mm payByBankTransfer response, will need redirect: ${cr.toJson()}');
    return cr;
  }
  Future<PaymentResponse> createPaymentByWallet(PaymentByWalletRequest request) async {
    pp(' ... payByBankTransfer ...');
    var url = '${prefix}rapyd/createPaymentByWallet';
    var resp = await dioUtil.sendPostRequest(url, request.toJson());
    var cr = PaymentResponse.fromJson(resp);
    pp('$mm createPaymentByWallet response, will need redirect: ${cr.toJson()}');
    return cr;
  }

  Future payByWallet() async {
    pp(' ...');
  }

  Future getCustomerPayments() async {
    pp(' ...');
  }
}
