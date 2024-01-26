import 'package:flutter/material.dart';

class BankTransferWidget extends StatefulWidget {
  const BankTransferWidget({super.key});

  @override BankTransferWidgetState createState() => BankTransferWidgetState();
}

class BankTransferWidgetState extends State<BankTransferWidget>
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
