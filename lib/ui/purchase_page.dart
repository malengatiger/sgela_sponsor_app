
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgela_services/sgela_util/functions.dart';

import '../util/functions.dart';


class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  PurchasePageState createState() => PurchasePageState();
}

class PurchasePageState extends State<PurchasePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;


  static const mm = '🔵🔵🔵🔵 PurchasePage  🔵🔵';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getData();
  }

  bool _busy = false;

  _getData() async {
    pp('$mm ... getting data ...');
    setState(() {
      _busy = false;
    });
    try {
      // organization = prefs.getOrganization();
      // country = prefs.getCountry();
    } catch (e) {
      pp(e);
      showErrorDialog(context, '$e');
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
              title: const Text('Purchases'),
            ),
            body: ScreenTypeLayout.builder(
              mobile: (_) {
                return const Stack();
              },
              tablet: (_) {
                return const Stack();
              },
              desktop: (_) {
                return const Stack();
              },
            )));
  }
}
