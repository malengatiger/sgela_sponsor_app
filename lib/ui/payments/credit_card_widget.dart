import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/data/country.dart';
import 'package:sgela_sponsor_app/data/rapyd/holder.dart';
import 'package:sgela_sponsor_app/data/sponsor_product.dart';
import 'package:sgela_sponsor_app/services/firestore_service.dart';
import 'package:sgela_sponsor_app/services/rapyd_payment_service.dart';
import 'package:sgela_sponsor_app/ui/payments/payment_web_view.dart';
import 'package:sgela_sponsor_app/ui/payments/sponsor_product_widget.dart';
import 'package:sgela_sponsor_app/util/Constants.dart';
import 'package:sgela_sponsor_app/util/environment.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';
import 'package:sgela_sponsor_app/util/prefs.dart';

class CreditCardWidget extends StatefulWidget {
  const CreditCardWidget(
      {super.key, required this.cardType, required this.sponsorProduct});

  final int cardType;
  final SponsorProduct sponsorProduct;

  @override
  CreditCardWidgetState createState() => CreditCardWidgetState();
}

class CreditCardWidgetState extends State<CreditCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵 CreditCardWidget 🍎🍎';
  RapydPaymentService rapydPaymentService =
      GetIt.instance<RapydPaymentService>();
  FirestoreService firestoreService = GetIt.instance<FirestoreService>();
  Prefs prefs = GetIt.instance<Prefs>();
  List<PaymentMethod> paymentMethods = [];
  List<PaymentMethod> filtered = [];
  PaymentMethod? paymentMethod;
  Country? country;
  Customer? customer;
  bool _busy = false;

  String cardName = '';
  String assetPath = 'assets/mastercard2.png';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    if (widget.cardType == Constants.visa) {
      cardName = 'Visa';
      assetPath = 'assets/visa1.png';
    }
    if (widget.cardType == Constants.masterCard) {
      cardName = 'MasterCard';
      assetPath = 'assets/mastercard2.png';
    }
    _getData();
  }

  _getData() async {
    country = prefs.getCountry();
    customer = prefs.getCustomer();
    paymentMethods =
        await rapydPaymentService.getCountryPaymentMethods(country!.iso2!);

    if (widget.cardType == Constants.visa) {
      for (var value in paymentMethods) {
        if (value.type!.contains('visa')) {
          paymentMethod = value;
        }
      }
    }
    if (widget.cardType == Constants.masterCard) {
      for (var value in paymentMethods) {
        if (value.type!.contains('master')) {
          paymentMethod = value;
        }
      }
    }
    setState(() {});
  }

  _startCheckout() async {
    pp('$mm ... _startCheckout ... ${widget.sponsorProduct.title} with card: $cardName');
    var amount = widget.sponsorProduct.studentsSponsored! *
        widget.sponsorProduct.amountPerSponsoree!;
    String ref = 'sgelaAI_${DateTime.now().millisecondsSinceEpoch}';

    try {
      var now = DateTime.now().millisecondsSinceEpoch ~/ 1000 + (60 * 20);
      var checkOutRequest = CheckoutRequest(
          amount.toInt(),
          ChatbotEnvironment.getPaymentCompleteUrl(),
          country!.iso2!,
          paymentMethod!.currencies.first,
          null,
          ChatbotEnvironment.getPaymentErrorUrl(),
          ref,
          true,
          'en',
          null,
          [paymentMethod!.type!],
          now,
          ChatbotEnvironment.getCheckoutCancelUrl(),
          ChatbotEnvironment.getCheckoutCompleteUrl(),
          []);

      pp('$mm ... sending checkOut request: ${checkOutRequest.toJson()}');
      var gr = await rapydPaymentService.createCheckOut(checkOutRequest);
      pp('$mm ... _startCheckout returned with checkout, should redirect');
      if (mounted) {
        NavigationUtils.navigateToPage(
            context: context,
            widget: PaymentWebView(
              url: gr.redirect_url!,
              title: '$cardName Payment',
            ));
      }

      // _handlePaymentResponse(resp);
    } catch (e, s) {
      pp(e);
      pp(s);
      if (mounted) {
        showErrorDialog(context, '$e');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(cardName),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SponsorProductWidget(
                          sponsorProduct: widget.sponsorProduct,
                          countryEmoji:
                              country == null ? '' : '${country!.emoji}'),
                    ),
                    gapH16,
                    Expanded(
                        child:
                            Card(elevation: 8, child: Image.asset(assetPath))),
                    gapH16,
                    ElevatedButton(
                        style: const ButtonStyle(
                          elevation: MaterialStatePropertyAll(8),
                        ),
                        onPressed: () {
                          _startCheckout();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Pay with $cardName',
                            style: myTextStyle(
                                context,
                                Theme.of(context).primaryColor,
                                24,
                                FontWeight.w900),
                          ),
                        )),
                    gapH32,
                  ],
                ),
              )
            ],
          );
        },
        tablet: (_) {
          return const Stack();
        },
        desktop: (_) {
          return const Stack();
        },
      ),
    ));
  }
}
