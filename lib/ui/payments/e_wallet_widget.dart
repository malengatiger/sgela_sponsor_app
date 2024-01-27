import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sgela_sponsor_app/data/country.dart';
import 'package:sgela_sponsor_app/data/rapyd/holder.dart';
import 'package:sgela_sponsor_app/data/sponsor_product.dart';
import 'package:sgela_sponsor_app/services/rapyd_payment_service.dart';
import 'package:sgela_sponsor_app/ui/payments/payment_web_view.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';
import 'package:sgela_sponsor_app/util/prefs.dart';

class EWalletWidget extends StatefulWidget {
  const EWalletWidget({super.key, required this.sponsorProduct});

  final SponsorProduct sponsorProduct;

  @override
  EWalletWidgetState createState() => EWalletWidgetState();
}

class EWalletWidgetState extends State<EWalletWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵 EWalletWidget 🔵🔵';
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
      _buildPaymentMethods();
    } catch (e) {
      pp(e);
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
                  title: '${paymentMethod!.name!} Payment'));
        }
      }
    } else {
      showErrorDialog(context, "Error occurred handling your payment");
    }
  }

  _startBankTransfer() async {
    pp('$mm ... _startBankTransfer ...');
    var amount = widget.sponsorProduct.studentsSponsored! *
        widget.sponsorProduct.amountPerSponsoree!;
    try {
      var request = PaymentByBankTransferRequest(
          amount, widget.sponsorProduct.currency, customer!.id!, paymentMethod);
      var resp = await rapydPaymentService.createPaymentByBankTransfer(request);
      _handlePaymentResponse(resp);
    } catch (e) {
      pp(e);
      if (mounted) {
        showErrorDialog(context, '$e');
      }
    }
  }

  List<Widget> _buildPaymentMethods() {
    filtered.clear();
    for (var pm in paymentMethods) {
      if (pm.type!.contains('wallet')) {
        filtered.add(pm);
      }
    }
    List<Widget> widgets = [];
    int cnt = 1;
    for (var pm in filtered) {
      //var img = CachedNetworkImage(imageUrl: pm.image!,);
      var name = pm.name!;
      var card = GestureDetector(
        onTap: () {
          setState(() {
            paymentMethod = pm;
          });
          _startBankTransfer();
        },
        child: SizedBox(
          width: 400,
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text('$cnt',
                      style: myTextStyle(context,
                          Theme.of(context).primaryColor, 18, FontWeight.bold)),
                  gapW8,
                  Text(name, style: myTextStyleMediumLarge(context, 18)),
                ],
              ),
            ),
          ),
        ),
      );
      widgets.add(card);
      cnt++;
    }
    return widgets;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
