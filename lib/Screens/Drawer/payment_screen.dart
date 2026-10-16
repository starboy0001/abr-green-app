import 'package:flutter/material.dart';

import '../../Constants/colors.dart';
import '../../Constants/constants.dart';
import '../../Constants/reusable_widgets.dart';

class PaymentScreen extends StatelessWidget {
  final String item;

  const PaymentScreen({super.key, required this.item});

  static const _yesBankScreenshot = 'assets/images/payment_yesbank.png';
  static const _kotakScreenshot = 'assets/images/payment_kotak.png';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Payment Details', style: appThemeTextWhiteC),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: appBarGradient),
        ),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: 1285 / 1365,
                child: Image.asset(
                  _yesBankScreenshot,
                  width: screenWidth,
                  fit: BoxFit.fitWidth,
                  semanticLabel: 'YES BANK UPI and bank account details',
                ),
              ),
            ),
            Image.asset(
              _kotakScreenshot,
              width: screenWidth,
              fit: BoxFit.fitWidth,
              semanticLabel: 'Kotak Mahindra UPI and bank account details',
            ),
          ],
        ),
      ),
    );
  }
}
