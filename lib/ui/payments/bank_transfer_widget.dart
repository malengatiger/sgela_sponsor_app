import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/data/country.dart';
import 'package:sgela_sponsor_app/data/sponsor_product.dart';
import 'package:sgela_sponsor_app/ui/busy_indicator.dart';
import 'package:sgela_sponsor_app/ui/payments/payment_web_view.dart';
import 'package:sgela_sponsor_app/ui/payments/sponsor_product_widget.dart';
import 'package:sgela_sponsor_app/util/environment.dart';

import '../../data/rapyd/holder.dart';
import '../../services/rapyd_payment_service.dart';
import '../../util/functions.dart';
import '../../util/navigation_util.dart';
import '../../util/prefs.dart';

class BankTransferWidget extends StatefulWidget {
  const BankTransferWidget({super.key, required this.sponsorProduct});

  final SponsorProduct sponsorProduct;

  @override
  BankTransferWidgetState createState() => BankTransferWidgetState();
}

class BankTransferWidgetState extends State<BankTransferWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🔵🍐🍐🍐🍐 BankTransferWidget 🍎🍎';
  RapydPaymentService rapydPaymentService =
      GetIt.instance<RapydPaymentService>();
  Prefs prefs = GetIt.instance<Prefs>();
  List<PaymentMethod> paymentMethods = [];
  List<PaymentMethod> filtered = [];
  PaymentMethod? paymentMethod;
  Country? country;
  Customer? customer;
  bool _busy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getPaymentMethods();
  }

  _getPaymentMethods() async {
    pp('$mm ... _getPaymentMethods ...');
    setState(() {
      _busy = false;
    });
    try {
      country = prefs.getCountry();
      customer = prefs.getCustomer();
      paymentMethods =
          await rapydPaymentService.getCountryPaymentMethods(country!.iso2!);
      _filterPaymentMethods();
    } catch (e) {
      pp(e);
      if (mounted) {
        showErrorDialog(context, 'Unable to get Payment methods');
      }
    }
    setState(() {
      _busy = false;
    });
  }

  void _handlePaymentResponse(PaymentResponse resp) {
    pp('$mm ... _handlePaymentResponse ... ${resp.status!.status}');
    if (resp.status!.status!.contains('SUCCESS')) {
      Payment? payment = resp.data;
      if (payment != null) {
        if (mounted) {
          NavigationUtils.navigateToPage(
              context: context,
              widget: PaymentWebView(
                url: payment.redirect_url!,
                title: '${paymentMethod!.name} Payment',
              ));
        }
      }
    } else {
      showErrorDialog(context, "Error occurred handling your payment");
    }
  }

  _filterPaymentMethods() {
    filtered.clear();
    for (var pm in paymentMethods) {
      if (pm.type!.contains('bank')) {
        filtered.add(pm);
      }
    }
  }
  _startCheckout() async {
    pp('$mm ... _startCheckout ... ${widget.sponsorProduct.title} ');
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
              title: 'Payment',
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

  _startBankTransfer(PaymentMethod paymentMethod) async {
    pp('$mm ... _startBankTransfer ...');
    this.paymentMethod = paymentMethod;
    var amount = widget.sponsorProduct.studentsSponsored! *
        widget.sponsorProduct.amountPerSponsoree!;
    setState(() {
      _busy = true;
    });
    late PaymentByBankTransferRequest request;
    try {
      if (customer == null) {
        _startCheckout();
      } else {
        request = PaymentByBankTransferRequest(amount,
            widget.sponsorProduct.currency, customer!.id!, paymentMethod);

        var resp =
            await rapydPaymentService.createPaymentByBankTransfer(request);
        pp('$mm ... _startBankTransfer came back. status: ${resp.status!.toJson()} .');
        pp('$mm ... _startBankTransfer came back. data(Payment): ${resp.data!.toJson()} .');
        _handlePaymentResponse(resp);
      }
    } catch (e) {
      pp(e);
      if (mounted) {
        showErrorDialog(context, '$e');
      }
    }
    setState(() {
      _busy = false;
    });
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
        title: const Text('Bank Transfer (EFT)'),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SponsorProductWidget(
                        sponsorProduct: widget.sponsorProduct,
                        countryEmoji: '${country!.emoji}',
                      ),
                    ),
                    _busy
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: BusyIndicator(
                              caption: 'Contacting  ${paymentMethod?.name} ...',
                              showClock: true,
                            ),
                          )
                        : Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: bd.Badge(
                                position:
                                    bd.BadgePosition.topEnd(top: -10, end: 2),
                                badgeContent: Text('${filtered.length}'),
                                child: ListView.builder(
                                    itemCount: filtered.length,
                                    itemBuilder: (_, index) {
                                      var pm = filtered.elementAt(index);
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            paymentMethod = pm;
                                          });
                                          _startBankTransfer(pm);
                                        },
                                        child: Card(
                                          elevation: 8,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${index + 1}',
                                                  style: myTextStyle(
                                                      context,
                                                      Theme.of(context)
                                                          .primaryColor,
                                                      20,
                                                      FontWeight.w900),
                                                ),
                                                gapW16,
                                                Text(
                                                  '${pm.name}',
                                                  style: myTextStyleMediumBold(
                                                      context),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ),
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