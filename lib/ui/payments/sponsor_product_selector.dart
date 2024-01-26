import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_sponsor_app/data/country.dart';
import 'package:sgela_sponsor_app/services/firestore_service.dart';
import 'package:sgela_sponsor_app/ui/widgets/payment_controller.dart';
import 'package:sgela_sponsor_app/util/functions.dart';
import 'package:sgela_sponsor_app/data/sponsor_payment_type.dart' as sp;
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

  Country? country;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getSponsorTypes();
  }

  _getSponsorTypes() async {
    sponsorProducts = await firestoreService.getSponsorProducts();
    sponsorProducts.sort((a,b) => b.studentsSponsored!.compareTo(a.studentsSponsored!));
    _filterTypes();
    country = prefs.getCountry();
    setState(() {

    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isIndividual = false;
  List<sp.SponsorProduct> filtered = [];

  Future _navigateToPaymentController(sp.SponsorProduct type) async {
    var ok = await NavigationUtils.navigateToPage(context: context, widget: PaymentController(sponsorPaymentType: type));
    if (ok && mounted) {
      Navigator.of(context).pop();
    }
  }


  _filterTypes() {
    filtered.clear();
    if (isIndividual) {
      for (var value in sponsorProducts) {
        if (value.title!.contains("Individual")) {
          filtered.add(value);
        }
      }
    }  else {
      for (var value in sponsorProducts) {
        if (value.title!.contains("Corp")) {
          filtered.add(value);
        }
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: const Text('Sponsorships'),
      ),
      body: ScreenTypeLayout.builder(
        mobile: (_){
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text(isIndividual?'Individual Sponsorships':'Corporate Sponsorships', style: myTextStyleMediumLarge(context, 20),),
                          Switch(value: isIndividual, onChanged: (change){
                            setState(() {
                              isIndividual = !isIndividual;
                            });
                            _filterTypes();
                          }),
                        ],
                      ),
                    ),
                    gapH16,
                    country == null? gapW4 : Expanded(child: PaymentTypeGrid(sponsorPaymentTypes: filtered, country: country!,
                      onSponsorPaymentType: (sponsorPaymentType ) {
                          _navigateToPaymentController(sponsorPaymentType);
                      },))
                  ],
                ),
              )
            ],
          );
        },
        tablet: (_){
          return const Stack();
        },
        desktop: (_){
          return const Stack();
        },
      ),
    ));
  }
}


class PaymentTypeGrid extends StatelessWidget {
  const PaymentTypeGrid({super.key, required this.sponsorPaymentTypes, required this.country, required this.onSponsorPaymentType, });

  final List<sp.SponsorProduct> sponsorPaymentTypes;
  final Country country;
  final Function(sp.SponsorProduct ) onSponsorPaymentType;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: sponsorPaymentTypes.length,
        itemBuilder: (ctx,index){
          var type = sponsorPaymentTypes.elementAt(index);
          return GestureDetector(
              onTap: (){
                  onSponsorPaymentType(type);
              },
              child: PaymentCard(sponsorPaymentType: type, elevation: 8, country: country,));
        });
  }
}


class PaymentCard extends StatelessWidget {
  const PaymentCard({super.key,  required this.elevation, required this.sponsorPaymentType, required this.country});
 final sp.SponsorProduct sponsorPaymentType;
  final double elevation;
  final Country country;

  @override
  Widget build(BuildContext context) {
    var fmt = NumberFormat('###,###.##');
    var fmt2 = NumberFormat('###,###,###,###');
    var amountPerSponsoree = sponsorPaymentType.amountPerSponsoree!.toStringAsFixed(2);
    var total =  sponsorPaymentType.amountPerSponsoree! * sponsorPaymentType.studentsSponsored!;
    var totalFmt = fmt.format(total);
    var students = fmt2.format(sponsorPaymentType.studentsSponsored);
    
    return Card(
      elevation: elevation,
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          gapH16,
          Text(students, style: myTextStyle(context, Theme.of(context).primaryColor,
              22, FontWeight.w900),),
          Text("Students Sponsored", style: myTextStyleSmall(context),),
          gapH8,
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Per Student", style: myTextStyleSmall(context),),
              gapW4,
              Text(amountPerSponsoree, style: myTextStyle(context, Theme.of(context).primaryColor,
                  16, FontWeight.w900),),
            ],
          ),
          gapH16, gapH8,
          // Text("Total Amount", style: myTextStyleSmall(context),),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(country.emoji!, style: const TextStyle(fontSize: 28),),
              gapW4,
              Text(totalFmt, style: myTextStyle(context, Theme.of(context).primaryColorLight,
                  18, FontWeight.w900),),
            ],
          ),
        ],
      ),
    );
  }
}


