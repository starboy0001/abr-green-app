import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/colors.dart';
import '../Constants/constants.dart';
import '../res/app_urls.dart';
import 'package:http/http.dart' as http;

class ViewReceiptScreen2 extends StatefulWidget {
  String receiptId;
  ViewReceiptScreen2(this.receiptId, {super.key});

  @override
  State<ViewReceiptScreen2> createState() => _ViewReceiptScreen2State();
}

class _ViewReceiptScreen2State extends State<ViewReceiptScreen2> {
  bool showSpinner = true;
  Map<String, dynamic>? receiptData;
  Map<String, dynamic>? applicationData;
  Map<String, dynamic>? projectData;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReceiptData();
  }

  getReceiptData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    String url = AppUrl.viewReceipt;

    final response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    }, body: {
      "id": widget.receiptId
    });
    setState(() {
      showSpinner = false;
    });

    if (response.statusCode == 200) {
      List<dynamic> receipts = json.decode(response.body)["data"]["reciepts"];
      receiptData = receipts[0];
      applicationData = receiptData!["applications"];
      projectData = applicationData!["project"];
      print("receipt data is >>>> ");
      print(receiptData);
    } else if (response.statusCode == 400) {
      print(response.statusCode);
    } else if (response.statusCode == 401) {
      print(response.statusCode);
    } else {
      print(response.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'View Receipt',
            style: appThemeTextWhiteC,
          ),
          flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: appBarGradient,
          ),
        ),
        ),
        body: receiptData == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                children: [
                                  TextSpan(
                                      text:
                                          "Received with thanks from Sh./Smt./M/s "),
                                  TextSpan(
                                      text: "${applicationData!['name']}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: " having address at "),
                                  TextSpan(
                                      text:
                                          "${applicationData!['address']}, ${applicationData!['city']}, ${applicationData!['state']} ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: "Mobile: "),
                                  TextSpan(
                                      text: "${applicationData!['mobile']}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: " a sum of Rs. "),
                                  TextSpan(
                                    text: "${receiptData!['amount']}",
                                    style: TextStyle(
                                      color: Colors.orange[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                      text:
                                          " on account of booking /part/payment for Unit No. "),
                                  TextSpan(
                                      text:
                                          "${applicationData!['allotted_plot']} ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: "of "),
                                  TextSpan(
                                      text: "${projectData!['project_name']} ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: "under "),
                                  TextSpan(
                                      text:
                                          "(${projectData!['project_subsidy_name']}) ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: "on "),
                                  TextSpan(
                                      text:
                                          "${DateFormat("yyyy-MM-dd").format(DateTime.parse(receiptData!['due_date']))} ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
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
