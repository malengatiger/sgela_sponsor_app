import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pay/pay.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/data/sponsor_payment_type.dart';
import 'package:sgela_sponsor_app/services/firestore_service.dart';
import 'package:sgela_sponsor_app/ui/busy_indicator.dart';
import 'package:sgela_sponsor_app/util/functions.dart';

class GoogleApplePayWidget extends StatefulWidget {
  const GoogleApplePayWidget({super.key, required this.isApplePay});

  final bool isApplePay;
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵 GoogleApplePayWidget 🔵🔵';

  @override
  GoogleApplePayWidgetState createState() => GoogleApplePayWidgetState();
}

class GoogleApplePayWidgetState extends State<GoogleApplePayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late final Future<PaymentConfiguration> _paymentConfigurationFuture;
  List<SponsorProduct> sponsorProducts = [];
  FirestoreService firestoreService = GetIt.instance<FirestoreService>();
  bool _busy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    if (widget.isApplePay) {
      _paymentConfigurationFuture =
          PaymentConfiguration.fromAsset('default_apple_pay_config.json');
    } else {
      _paymentConfigurationFuture =
          PaymentConfiguration.fromAsset('default_google_pay_config.json');
    }
    _getPaymentTypes();
  }

  _getPaymentTypes() async {
    setState(() {
      _busy = true;
    });
    sponsorProducts = await firestoreService.getSponsorProducts();
    for (var spt in sponsorProducts) {
      var total = spt.studentsSponsored! * spt.amountPerSponsoree!;
      var item = PaymentItem(
          amount: '$total',
          label: spt.title,
          status: PaymentItemStatus.final_price,
          type: PaymentItemType.total);
      _paymentItems.add(item);

      setState(() {
        _busy = false;
      });
    }
  }

  void onGooglePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
  }
  void onApplePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
  }

  static const _paymentItems = [
    PaymentItem(
      label: 'Total',
      amount: '99.99',
      status: PaymentItemStatus.final_price,
    )
  ];

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
        title: const Text('Google and Apple Pay'),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              _busy? const BusyIndicator(
                caption: 'Preparing for payment',
              ):Column(
                children: [
                  const Text('Sponsorship Message'),
                  gapH16,
                  if (!widget.isApplePay)   FutureBuilder<PaymentConfiguration>(
                      future: _paymentConfigurationFuture,
                      builder: (context, snapshot) => snapshot.hasData
                          ? GooglePayButton(
                              paymentConfiguration: snapshot.data!,
                              paymentItems: _paymentItems,
                              type: GooglePayButtonType.buy,
                              margin: const EdgeInsets.only(top: 15.0),
                              onPaymentResult: onGooglePayResult,
                              loadingIndicator: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const SizedBox.shrink()),
                  if (widget.isApplePay)   FutureBuilder<PaymentConfiguration>(
                      future: _paymentConfigurationFuture,
                      builder: (context, snapshot) => snapshot.hasData
                          ? ApplePayButton(
                        paymentConfiguration: snapshot.data!,
                        paymentItems: _paymentItems,
                        type: ApplePayButtonType.buy,
                        margin: const EdgeInsets.only(top: 15.0),
                        onPaymentResult: onApplePayResult,
                        loadingIndicator: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : const SizedBox.shrink()),

                ],
              )
            ],
          );
        },
        tablet: (_) {
          return const Stack();
        },
      ),
    ));
  }
}
