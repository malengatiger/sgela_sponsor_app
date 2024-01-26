import 'package:flutter/material.dart';

class CreditCardWidget extends StatefulWidget {
  const CreditCardWidget({super.key, required this.cardType});

  final int cardType;
  @override
  CreditCardWidgetState createState() => CreditCardWidgetState();
}

class CreditCardWidgetState extends State<CreditCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
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
