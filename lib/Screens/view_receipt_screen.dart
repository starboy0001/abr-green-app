import 'package:flutter/material.dart';

import '../Constants/colors.dart';
import '../Constants/constants.dart';

class ViewReceiptScreen extends StatefulWidget {
  String name,
      surname,
      address,
      city,
      state,
      mobile,
      paymentPlanAmount,
      projectName,
      projectSubsidyName,
      refId;
  ViewReceiptScreen(
      this.name,
      this.surname,
      this.address,
      this.city,
      this.state,
      this.mobile,
      this.paymentPlanAmount,
      this.projectName,
      this.projectSubsidyName,
      this.refId,
      {super.key});

  @override
  State<ViewReceiptScreen> createState() => _ViewReceiptScreenState();
}

class _ViewReceiptScreenState extends State<ViewReceiptScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'Application Receipt',
            style: appThemeTextWhiteC,
          ),
          flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: appBarGradient,
          ),
        ),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Image.asset("assets/images/letter-head.png"),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Payment Receipt",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          children: [
                            TextSpan(
                                text:
                                    "Received with thanks from Sh./Smt./M/s "),
                            TextSpan(
                                text: "${widget.name} ${widget.surname}",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: " having address at "),
                            TextSpan(
                                text:
                                    "${widget.address}, ${widget.city}, ${widget.state} ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: "Mobile: "),
                            TextSpan(
                                text: "${widget.mobile}",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: " a sum of Rs. "),
                            TextSpan(
                              text: "${widget.paymentPlanAmount}",
                              style: TextStyle(
                                color: Colors.orange[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                                text:
                                    " on account of booking /part/payment of at "),
                            TextSpan(
                                text:
                                    "${widget.projectName}, (${widget.projectSubsidyName}) ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: "by Ticket No: "),
                            TextSpan(
                              text: "${widget.refId}",
                              style: TextStyle(
                                color: Colors.orange[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "From ABR GREENS INFRASTRUCTURE",
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    Text(
                      " This is computer generated receipt, hence requires no signature",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )),
        ));
    ;
  }
}
