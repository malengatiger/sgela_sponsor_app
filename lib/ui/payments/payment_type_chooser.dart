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
      height: 400,
      width: 320,
      child: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            gapH8,
            Text(
              'Payment Types',
              style: myTextStyleMediumLarge(context, 20),
            ),
            gapH32,
            SizedBox(
              width: 260,
              child: ElevatedButton(
                  style: mStyle,
                  onPressed: () {
                    onPaymentTypeSelected(Constants.visa);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('Visa'),
                  )),
            ),
            gapH16,
            SizedBox(
              width: 260,
              child: ElevatedButton(
                  style: mStyle,
                  onPressed: () {
                    onPaymentTypeSelected(Constants.masterCard);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('Mastercard'),
                  )),
            ),
            gapH16,
            SizedBox(
              width: 260,
              child: ElevatedButton(
                  style: mStyle,
                  onPressed: () {
                    onPaymentTypeSelected(Constants.bankTransfer);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('Bank Transfer (EFT)'),
                  )),
            ),
            // gapH16,
            // SizedBox(width: 260,
            //   child: ElevatedButton(
            //       style: mStyle,
            //       onPressed: () {
            //         onPaymentTypeSelected(Constants.applePay);
            //       },
            //       child: const Padding(
            //         padding: EdgeInsets.all(20.0),
            //         child: Text('Apple Pay'),
            //       )),
            // ),
            // gapH16,
            // SizedBox(width: 260,
            //   child: ElevatedButton(
            //       style: mStyle,
            //       onPressed: () {
            //         onPaymentTypeSelected(Constants.googlePay);
            //       },
            //       child: const Padding(
            //         padding: EdgeInsets.all(20.0),
            //         child: Text('Google Pay'),
            //       )),
            // ),
            gapH16,
            SizedBox(
              width: 260,
              child: ElevatedButton(
                  style: mStyle,
                  onPressed: () {
                    //onPaymentTypeSelected(Constants.payPal);
                    showToast(message: 'PayPal is not available yet. Stay tuned!', 
                        backgroundColor: Colors.amber,
                        textStyle: myTextStyleMediumWithColor(context, Colors.black),
                        context: context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('PayPal'),
                  )),
            ),
            // gapH16,
            // SizedBox(
            //   width: 260,
            //   child: ElevatedButton(
            //       style: mStyle,
            //       onPressed: () {
            //         onPaymentTypeSelected(Constants.eWallet);
            //       },
            //       child: const Padding(
            //         padding: EdgeInsets.all(20.0),
            //         child: Text('eWallet'),
            //       )),
            // ),
            gapH16,
          ],
        ),
      ),
    );
  }
}
