import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/data/organization.dart';
import 'package:sgela_sponsor_app/data/user.dart';
import 'package:sgela_sponsor_app/ui/branding_upload_one.dart';
import 'package:sgela_sponsor_app/ui/payments/bank_transfer_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/credit_card_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/e_wallet_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/google-apple_pay_widget.dart';
import 'package:sgela_sponsor_app/ui/organisation_user_add.dart';
import 'package:sgela_sponsor_app/ui/payments/pay_pal_widget.dart';
import 'package:sgela_sponsor_app/ui/payments/payment_type_chooser.dart';
import 'package:sgela_sponsor_app/ui/payments/sponsor_product_selector.dart';
import 'package:sgela_sponsor_app/ui/sponsor_product_selector.dart';
import 'package:sgela_sponsor_app/ui/widgets/color_gallery.dart';
import 'package:sgela_sponsor_app/ui/widgets/org_logo_widget.dart';
import 'package:sgela_sponsor_app/util/dark_light_control.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/navigation_util.dart';
import 'package:sgela_sponsor_app/util/prefs.dart';
import '../util/Constants.dart';
import '../data/branding.dart';
import '../services/firestore_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.organization});

  final Organization organization;

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵 Dashboard 🔵🔵';

  Prefs prefs = GetIt.instance<Prefs>();
  ColorWatcher colorWatcher = GetIt.instance<ColorWatcher>();
  FirestoreService firestoreService = GetIt.instance<FirestoreService>();

  List<Branding> brandings = [];
  List<User> users = [];

  int transactions = 0;

  double averageRating = 0.0;
  Organization? organization;
  bool _busy = false;
  String? logoUrl;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _getData() async {
    pp('$mm ..... get data; logoUrl & org');
    setState(() {
      _busy = true;
    });
    try {
      logoUrl = prefs.getLogoUrl();
      organization = prefs.getOrganization();
      if ((organization != null)) {
        brandings = await firestoreService.getBranding(organization!.id!);
        users = await firestoreService.getUsers(organization!.id!);
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

  _navigateToColorPicker() {
    NavigationUtils.navigateToPage(
        context: context,
        widget: ColorGallery(prefs: prefs, colorWatcher: colorWatcher));
  }

  _navigateToAddPerson() async {
    pp('$mm ... navigation to user add ...');
    await NavigationUtils.navigateToPage(
        context: context, widget: const OrganisationUserAdd());
    _getData();
  }

  _navigateToBrandUpload() {
    NavigationUtils.navigateToPage(
        context: context,
        widget: BrandingUploadOne(
          organization: widget.organization,
          onBrandingUploaded: (br) {
            pp('$mm ... branding uploaded OK ....');
            showToast(
                message: 'Branding items uploaded OK',
                backgroundColor: Colors.green,
                padding: 24,
                duration: const Duration(seconds: 6),
                context: context);
            _getData();
          },
        ));
  }

  _navigateToPaymentTypeWidget() {
    pp('$mm ... _navigateToPaymentTypeWidget ...');

    switch(selectedPaymentType) {
      case Constants.googlePay:
        NavigationUtils.navigateToPage(context: context,
            widget: const GoogleApplePayWidget(isApplePay: false));
        break;
      case Constants.applePay:
        NavigationUtils.navigateToPage(context: context,
            widget: const GoogleApplePayWidget(isApplePay: true));
        break;
      case Constants.visa:
        NavigationUtils.navigateToPage(context: context,
            widget: const CreditCardWidget(cardType: Constants.visa));
        break;
      case Constants.masterCard:
        NavigationUtils.navigateToPage(context: context,
            widget: const CreditCardWidget(cardType: Constants.masterCard));
        break;
      case Constants.bankTransfer:
        NavigationUtils.navigateToPage(context: context,
            widget: const BankTransferWidget());
        break;
      case Constants.payPal:
        NavigationUtils.navigateToPage(context: context,
            widget: const PayPalWidget());
        break;
      case Constants.eWallet:
        NavigationUtils.navigateToPage(context: context,
            widget: const EWalletWidget());
        break;
    }

    NavigationUtils.navigateToPage(
        context: context, widget: const SponsorProductSelector());
  }

  int selectedPaymentType = 0;
  _showPaymentTypeDialog() {
    showDialog(context: context, builder: (_){
      return AlertDialog(
        content: PaymentTypeChooser(onPaymentTypeSelected: (type){
          pp('$mm onPaymentTypeSelected: $type');
          setState(() {
            selectedPaymentType = type;
          });
          _navigateToPaymentTypeWidget();
        }),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    var tag = '';
    var name = '';
    if ((organization != null)) {
      name = organization!.name!;
      if (organization!.tagLine != null) {
        tag = organization!.tagLine!;
      }
    }
    Branding? branding;
    if (brandings.isNotEmpty) {
      branding = brandings.first;
    }
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: gapW4,
        title: OrgLogoWidget(
          branding: branding,
          logoUrl: logoUrl,
        ),
        actions: [
          IconButton(
              onPressed: () {
                _navigateToColorPicker();
              },
              icon: Icon(
                Icons.color_lens_outlined,
                color: Theme.of(context).primaryColor,
              )),
          organization == null
              ? gapW4
              : IconButton(
                  onPressed: () {
                    _navigateToAddPerson();
                  },
                  icon: Icon(
                    Icons.person_add,
                    color: Theme.of(context).primaryColor,
                  )),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(24),
            child: Column(
              children: [
                Text(tag),
                gapH4,
              ],
            )),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        gapH32,
                        Text(
                          name,
                          style: myTextStyle(
                              context,
                              Theme.of(context).primaryColorLight,
                              28,
                              FontWeight.normal),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GridView(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2),
                              children: [
                                TotalCard(
                                    caption: 'Users',
                                    total: users.length.toDouble()),
                                TotalCard(
                                  caption: 'Branding',
                                  total: brandings.length.toDouble(),
                                  fontSize: 48,
                                ),
                                TotalCard(
                                    caption: 'Average Rating',
                                    total: averageRating),
                                TotalCard(
                                    caption: 'Students Subscribed',
                                    total: averageRating),
                                TotalCard(
                                  caption: 'AI Requests',
                                  total: transactions.toDouble(),
                                  fontSize: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // gapH32, gapH32,
                        SizedBox(
                          height: 160,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 300,
                                child: ElevatedButton.icon(
                                  style: const ButtonStyle(
                                    elevation: MaterialStatePropertyAll(16.0),
                                  ),
                                  onPressed: () {
                                    _navigateToBrandUpload();
                                  },
                                  icon: Icon(Icons.upload,
                                      color: Theme.of(context).primaryColor),
                                  label: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Upload Branding',
                                      style: myTextStyle(
                                          context,
                                          Theme.of(context).primaryColorLight,
                                          18,
                                          FontWeight.normal),
                                    ),
                                  ),
                                ),
                              ),
                              gapH16,
                              SizedBox(
                                width: 300,
                                child: ElevatedButton.icon(
                                  style: const ButtonStyle(
                                    elevation: MaterialStatePropertyAll(4.0),
                                  ),
                                  onPressed: () {
                                    _showPaymentTypeDialog();
                                  },
                                  icon: Icon(
                                    Icons.back_hand_sharp,
                                    size: 20,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  label: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Manage Subscription',
                                      style: myTextStyle(
                                          context,
                                          Theme.of(context).primaryColorLight,
                                          18,
                                          FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  ),
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

class TotalCard extends StatelessWidget {
  const TotalCard(
      {super.key, required this.caption, required this.total, this.fontSize});

  final String caption;
  final double total;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    var fmt = NumberFormat('###,###,###,###,###');
    var num = fmt.format(total);
    return Card(
      elevation: 12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            num,
            style: myTextStyle(context, Theme.of(context).primaryColor,
                fontSize == null ? 28 : fontSize!, FontWeight.w900),
          ),
          gapH16,
          Text(
            caption,
            style: myTextStyleSmall(context),
          )
        ],
      ),
    );
  }
}
