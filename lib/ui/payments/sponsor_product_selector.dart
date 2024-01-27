import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/data/country.dart';
import 'package:sgela_sponsor_app/data/organization.dart';
import 'package:sgela_sponsor_app/data/sponsor_product.dart' as sp;
import 'package:sgela_sponsor_app/services/firestore_service.dart';
import 'package:sgela_sponsor_app/ui/payments/bank_transfer_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/credit_card_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/e_wallet_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/google-apple_pay_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/pay_pal_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/payment_type_chooser.dart';
import 'package:sgela_sponsor_app/ui/widgets/org_logo_widget.dart';
import 'package:sgela_sponsor_app/util/Constants.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';
import 'package:sgela_sponsor_app/util/prefs.dart';

class SponsorProductSelector extends StatefulWidget {
  const SponsorProductSelector({super.key});

  @override
  SponsorProductSelectorState createState() => SponsorProductSelectorState();
}

class SponsorProductSelectorState extends State<SponsorProductSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  List<sp.SponsorProduct> sponsorProducts = [];
  FirestoreService firestoreService = GetIt.instance<FirestoreService>();
  Prefs prefs = GetIt.instance<Prefs>();
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵 SponsorProductSelector 🔵🔵';

  Country? country;
  Organization? organization;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getSponsorProducts();
  }

  _getSponsorProducts() async {
    sponsorProducts = await firestoreService.getSponsorProducts(true);
    sponsorProducts
        .sort((a, b) => b.studentsSponsored!.compareTo(a.studentsSponsored!));
    _filterTypes();
    country = prefs.getCountry();
    organization = prefs.getOrganization();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isIndividual = false;
  List<sp.SponsorProduct> filtered = [];

  int selectedPaymentType = 0;

  _showPaymentTypeDialog(sp.SponsorProduct sponsorProduct) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: PaymentTypeChooser(onPaymentTypeSelected: (type) {
              pp('$mm .... onPaymentTypeSelected: $type');
              setState(() {
                selectedPaymentType = type;
              });
              Navigator.of(context).pop();
              _navigateToPaymentTypeWidget(sponsorProduct);
            }),
          );
        });
  }

  _navigateToPaymentTypeWidget(sp.SponsorProduct sponsorProduct) {
    pp('$mm ... _navigateToPaymentTypeWidget ...');

    switch (selectedPaymentType) {
      case Constants.googlePay:
        NavigationUtils.navigateToPage(
            context: context,
            widget: ApplePayWidget(
              sponsorProduct: sponsorProduct,
            ));
        break;
      case Constants.applePay:
        NavigationUtils.navigateToPage(
            context: context,
            widget: ApplePayWidget(
              sponsorProduct: sponsorProduct,
            ));
        break;
      case Constants.visa:
        NavigationUtils.navigateToPage(
            context: context,
            widget: CreditCardWidget(
              cardType: Constants.visa,
              sponsorProduct: sponsorProduct,
            ));
        break;
      case Constants.masterCard:
        NavigationUtils.navigateToPage(
            context: context,
            widget: CreditCardWidget(
              cardType: Constants.masterCard,
              sponsorProduct: sponsorProduct,
            ));
        break;
      case Constants.bankTransfer:
        NavigationUtils.navigateToPage(
            context: context,
            widget: BankTransferWidget(
              sponsorProduct: sponsorProduct,
            ));
        break;
      case Constants.payPal:
        NavigationUtils.navigateToPage(
            context: context, widget: const PayPalWidget());
        break;
      case Constants.eWallet:
        NavigationUtils.navigateToPage(
            context: context,
            widget: EWalletWidget(
              sponsorProduct: sponsorProduct,
            ));
        break;
    }
  }

  sp.SponsorProduct? sponsorProduct;

  _filterTypes() {
    filtered.clear();
    if (isIndividual) {
      for (var value in sponsorProducts) {
        if (value.title!.contains("Individual")) {
          filtered.add(value);
        }
      }
    } else {
      for (var value in sponsorProducts) {
        if (value.title!.contains("Corp")) {
          filtered.add(value);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: organization == null
            ? const Text('Sponsorships')
            : OrgLogoWidget(
                name: organization!.name!,
              ),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isIndividual
                                ? 'Individual Sponsorships'
                                : 'Corporate Sponsorships',
                            style: myTextStyleMediumLarge(context, 20),
                          ),
                          Switch(
                              value: isIndividual,
                              onChanged: (change) {
                                setState(() {
                                  isIndividual = !isIndividual;
                                });
                                _filterTypes();
                              }),
                        ],
                      ),
                    ),
                    gapH16,
                    country == null
                        ? gapW4
                        : Expanded(
                            child: SponsorProductGrid(
                            sponsorProducts: filtered,
                            country: country!,
                            onSponsorProduct: (sponsorProduct) {
                              _showPaymentTypeDialog(sponsorProduct);
                            },
                          ))
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

class SponsorProductGrid extends StatelessWidget {
  const SponsorProductGrid({
    super.key,
    required this.sponsorProducts,
    required this.country,
    required this.onSponsorProduct,
  });

  final List<sp.SponsorProduct> sponsorProducts;
  final Country country;
  final Function(sp.SponsorProduct) onSponsorProduct;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: sponsorProducts.length,
        itemBuilder: (ctx, index) {
          var type = sponsorProducts.elementAt(index);
          return GestureDetector(
              onTap: () {
                onSponsorProduct(type);
              },
              child: SponsorProductCard(
                sponsorProduct: type,
                elevation: 8,
                country: country,
              ));
        });
  }
}

class SponsorProductCard extends StatelessWidget {
  const SponsorProductCard(
      {super.key,
      required this.elevation,
      required this.sponsorProduct,
      required this.country});

  final sp.SponsorProduct sponsorProduct;
  final double elevation;
  final Country country;

  @override
  Widget build(BuildContext context) {
    var fmt = NumberFormat('###,###.##');
    var fmt2 = NumberFormat('###,###,###,###');
    var amountPerSponsoree =
        sponsorProduct.amountPerSponsoree!.toStringAsFixed(2);
    var total =
        sponsorProduct.amountPerSponsoree! * sponsorProduct.studentsSponsored!;
    var totalFmt = fmt.format(total);
    var students = fmt2.format(sponsorProduct.studentsSponsored);

    return Card(
      elevation: elevation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          gapH16,
          Text(
            students,
            style: myTextStyle(
                context, Theme.of(context).primaryColor, 26, FontWeight.w700),
          ),
          Text(
            "Students Sponsored",
            style: myTextStyleSmall(context),
          ),
          gapH8,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Per Student",
                style: myTextStyleSmall(context),
              ),
              gapW4,
              Text(
                amountPerSponsoree,
                style: myTextStyle(context, Theme.of(context).primaryColor, 14,
                    FontWeight.normal),
              ),
            ],
          ),
          gapH16, gapH8,
          // Text("Total Amount", style: myTextStyleSmall(context),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                country.emoji!,
                style: const TextStyle(fontSize: 28),
              ),
              gapW4,
              Text(
                totalFmt,
                style: myTextStyle(context, Theme.of(context).primaryColorLight,
                    18, FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
