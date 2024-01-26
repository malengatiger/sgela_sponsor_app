import 'package:flutter/material.dart';
import 'package:sgela_sponsor_app/util/Constants.dart';
import 'package:sgela_sponsor_app/util/functions.dart';

class PaymentTypeChooser extends StatelessWidget {
  const PaymentTypeChooser({super.key, required this.onPaymentTypeSelected});

  final Function(int) onPaymentTypeSelected;

  @override
  Widget build(BuildContext context) {
    var mStyle = const ButtonStyle(
      elevation: MaterialStatePropertyAll(8.0),
    );
    return SizedBox(
      height: 300, width: 320,
      child: Column(
        children: [
          gapH16,
          SizedBox(width: 260,
            child: ElevatedButton(
                style: mStyle,
                onPressed: () {
                  onPaymentTypeSelected(Constants.visa);
                },
                child: const Text('Visa')),
          ),
          gapH16,
          SizedBox(width: 260,
            child: ElevatedButton(
                style: mStyle,
                onPressed: () {
                  onPaymentTypeSelected(Constants.masterCard);
                },
                child: const Text('Mastercard')),
          ),
          gapH16,
          SizedBox(width: 260,
            child: ElevatedButton(
                style: mStyle,
                onPressed: () {
                  onPaymentTypeSelected(Constants.bankTransfer);
                },
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Bank Transfer (EFT)'),
                )),
          ),
          gapH16,
          SizedBox(width: 260,
            child: ElevatedButton(
                style: mStyle,
                onPressed: () {
                  onPaymentTypeSelected(Constants.payPal);
                },
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('PayPal'),
                )),
          ),
          gapH16,
          SizedBox(width: 260,
            child: ElevatedButton(
                style: mStyle,
                onPressed: () {
                  onPaymentTypeSelected(Constants.eWallet);
                },
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('eWallet'),
                )),
          ),
          gapH16,
        ],
      ),
    );
  }

}


