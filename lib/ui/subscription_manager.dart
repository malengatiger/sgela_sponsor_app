import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/data/organization.dart';
import 'package:sgela_sponsor_app/data/pricing.dart';
import 'package:sgela_sponsor_app/data/subscription.dart';
import 'package:sgela_sponsor_app/services/firestore_service.dart';
import 'package:sgela_sponsor_app/ui/widgets/org_logo_widget.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/util/prefs.dart';

class SubscriptionManager extends StatefulWidget {
  const SubscriptionManager({super.key});

  @override
  SubscriptionManagerState createState() => SubscriptionManagerState();
}

class SubscriptionManagerState extends State<SubscriptionManager>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🧡🧡🧡🧡🧡🧡 SubscriptionManager: 🧡';

  Organization? organization;
  Prefs prefs = GetIt.instance<Prefs>();
  FirestoreService firestoreService = GetIt.instance<FirestoreService>();

  String? logoUrl;
  Pricing? pricing;
  bool _busy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getData();
  }

  _getData() async {
    setState(() {
      _busy = true;
    });
    try {
      logoUrl = prefs.getLogoUrl();
      organization = prefs.getOrganization();
      pp('$mm organization: ${organization!.toJson()}');
      pp('$mm logoUrl: $logoUrl');
      pricing = await firestoreService.getPricing(organization!.country!.id!);
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

  void _confirmMonthlySubs() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text(
              'You selected the MONTHLY subscription',
              style: myTextStyleMediumLarge(context, 20),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              ElevatedButton(
                  style: const ButtonStyle(
                    elevation: MaterialStatePropertyAll(8),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _submitSubs(monthlySubscription);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: Text(
                      'Continue',
                      style: myTextStyle(
                          context,
                          Theme.of(context).primaryColor,
                          16,
                          FontWeight.normal),
                    ),
                  )),
            ],
          );
        });
  }

  void _confirmAnnualSubs() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text('You selected the ANNUAL subscription',
                style: myTextStyleMediumLarge(context, 20)),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              ElevatedButton(
                  style: const ButtonStyle(
                    elevation: MaterialStatePropertyAll(8),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _submitSubs(annualSubscription);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      'Continue',
                      style: myTextStyle(
                          context,
                          Theme.of(context).primaryColor,
                          16,
                          FontWeight.normal),
                    ),
                  )),
            ],
          );
        });
  }

  Subscription? subscription;

  void _submitSubs(String type) async {
    pp('$mm ... _submitSubs ... type: $type');
    setState(() {
      _busy = true;
    });
    try {
      var user = prefs.getUser();
      var sub = Subscription(
          null,
          organization!.country!.id,
          organization!.id!,
          user!.id!,
          DateTime.now().toIso8601String(),
          pricing,
          type,
          true,
          organization!.name);

      subscription = await firestoreService.addSubscription(sub);

      if (mounted) {
        if (subscription == null) {
          showErrorDialog(context, 'Subscription failed');
        } else {
          pp('$mm subscription added: ${subscription!.toJson()}');
          showToast(
              message: 'Subscription added OK',
              padding: 24,
              backgroundColor: Colors.green,
              textStyle: myTextStyleMediumWithColor(context, Colors.white),
              context: context);
          Navigator.of(context).pop();
        }
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
        title: OrgLogoWidget(
          logoUrl: logoUrl,
          name: organization == null ? '' : organization!.name,
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
                    gapH32,
                    Card(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Students to Sponsor'),
                            gapW32,
                            NumberDropDown(
                                multiplier: 10000,
                                base: 12,
                                onChanged: (number) {
                                  setState(() {
                                    numberOfStudents = number;
                                  });
                                }),
                          ],
                        ),
                      ),
                    ),
                    pricing == null
                        ? const Card(
                            child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Pricing not available yet'),
                          ))
                        : PricingWidget(
                            onMonthlySub: () {
                              _confirmMonthlySubs();
                            },
                            onAnnualSub: () {
                              _confirmAnnualSubs();
                            },
                            pricing: pricing!,
                            organization: organization!,
                            numberOfStudents: numberOfStudents,
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

  int numberOfStudents = 0;
}

class PricingWidget extends StatelessWidget {
  const PricingWidget(
      {super.key,
      required this.onMonthlySub,
      required this.onAnnualSub,
      required this.pricing,
      required this.organization,
      required this.numberOfStudents});

  final Function onMonthlySub;
  final Function onAnnualSub;
  final Pricing pricing;
  final Organization organization;
  final int numberOfStudents;

  @override
  Widget build(BuildContext context) {
    String monthlyPrice = pricing.monthlyPrice!.toStringAsFixed(2);
    String annualPrice = pricing.annualPrice!.toStringAsFixed(2);
    var fmt = NumberFormat('###,###,###,###');
    String students = fmt.format(numberOfStudents);
    return SizedBox(
      width: 400,
      child: Card(
        elevation: 16,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              gapH32,
              Row(
                children: [
                  const Text('Students:'),
                  gapW16,
                  Text(
                    students,
                    style: myTextStyleMediumLarge(context, 24),
                  )
                ],
              ),
              gapH32,
              GestureDetector(
                onTap: () {
                  onMonthlySub();
                },
                child: Card(
                  elevation: 8,
                  child: SizedBox(
                    height: 120,
                    width: 240,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${organization.country!.currencySymbol}',
                                style: const TextStyle(fontSize: 32),
                              ),
                              Text(
                                monthlyPrice,
                                style: myTextStyle(
                                    context,
                                    Theme.of(context).primaryColor,
                                    36,
                                    FontWeight.w900),
                              ),
                            ],
                          ),
                          gapH8,
                          Text(
                            'Monthly',
                            style: myTextStyleMediumLarge(context, 16),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              gapH32,
              GestureDetector(
                onTap: () {
                  onAnnualSub();
                },
                child: Card(
                  elevation: 8,
                  child: SizedBox(
                    height: 120,
                    width: 240,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${organization.country!.currencySymbol}',
                                style: const TextStyle(fontSize: 32),
                              ),
                              Text(
                                annualPrice,
                                style: myTextStyle(
                                    context,
                                    Theme.of(context).primaryColor,
                                    36,
                                    FontWeight.w900),
                              ),
                            ],
                          ),
                          gapH8,
                          Text(
                            'Annual',
                            style: myTextStyleMediumLarge(context, 16),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              gapH32,
              const Text('Pricing is by Student or Teacher sponsored'),
              gapH32,
            ],
          ),
        ),
      ),
    );
  }
}

class NumberDropDown extends StatelessWidget {
  const NumberDropDown(
      {super.key, required this.onChanged, this.multiplier, this.base});

  final Function(int) onChanged;
  final int? multiplier, base;

  @override
  Widget build(BuildContext context) {
    var mMultiplier = 100, mBase = 10;
    if (multiplier != null) {
      mMultiplier = multiplier!;
    }
    if (base != null) {
      mBase = base!;
    }
    List<DropdownMenuItem<int>> items = [];
    for (int x = 0; x < mBase; x++) {
      int num = (x + 1) * mMultiplier;
      items.add(DropdownMenuItem(value: num, child: Text('$num')));
    }
    return DropdownButton<int>(
        items: items,
        onChanged: (mNumber) {
          if (mNumber != null) {
            onChanged(mNumber);
          }
        });
  }
}
