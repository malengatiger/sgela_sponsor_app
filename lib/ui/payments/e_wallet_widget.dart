import 'package:flutter/material.dart';

class EWalletWidget extends StatefulWidget {
  const EWalletWidget({super.key});

  @override
  EWalletWidgetState createState() => EWalletWidgetState();
}

class EWalletWidgetState extends State<EWalletWidget>
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
