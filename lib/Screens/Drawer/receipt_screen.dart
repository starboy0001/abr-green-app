import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:property_project/Constants/reusable_widgets.dart';
import 'package:property_project/Screens/view_receipt_screen_2.dart';
import 'package:property_project/res/app_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../Constants/colors.dart';
import '../../Constants/constants.dart';

class ReceiptScreen extends StatefulWidget {
  String item;
  ReceiptScreen({super.key, required this.item});

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  List receiptList = [];
  bool showSpinner = false;
  bool dataFound = true;
  @override
  void initState() {
    super.initState();
    fetchReceiptData();
  }

  fetchReceiptData() async {
    setState(() {
      showSpinner = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    String url = AppUrl.receiptData;

    final response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      setState(() {
        showSpinner = false;
      });

      receiptList = json.decode(response.body)["data"]["reciepts"];
      print("length of receipts : " + receiptList.length.toString());
      if (receiptList.length == 0) {
        setState(() {
          dataFound = false;
        });
      }
      for (var i = 0; i < receiptList.length; i++) {
        print('this is all receipt data: ${receiptList[i]}');
        setState(() {
          receiptList;
        });
      }
    } else {
      setState(() {
        dataFound = false;
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Receipts',
          style: appThemeTextWhiteC,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: appBarGradient,
          ),
        ),
      ),
      body: showSpinner
          ? Center(
              child: CircularProgressIndicator(),
            )
          : !dataFound
              ? Center(
                  child: Text("Data Not Found"),
                )
    : ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            height: height,
            width: width,
            color: whiteC,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20.0,
                ),
                Text('RECEIPT DETAILS', style: appThemeTextBlackC),
                SizedBox(
                  height: 10.0,
                ),
                Expanded(
                    child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: receiptList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 220,
                      child: Card(
                        child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Project Name', style: receiptText),
                                        Text('Date', style: receiptText),
                                        Text('Ticket ID',
                                            style: appThemeTextBlackC),
                                        Text('Ref id', style: receiptText),
                                        Text('Amount', style: receiptText),
                                        Text('Title', style: receiptText),
                                      ],
                                    ),
                                    SizedBox(width: 30.0),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            receiptList[index]["applications"]
                                                ["project"]["project_name"],
                                            style: receiptText),
                                        Text(receiptList[index]["due_date"],
                                            style: receiptText),
                                        Text(
                                            receiptList[index]["applications"]
                                                        ["ticket_no"] ==
                                                    null
                                                ? ''
                                                : receiptList[index]
                                                    ["applications"]["ticket_no"],
                                            style: receiptText),
                                        Text(
                                            receiptList[index]["applications"]
                                                        ["ref_id"] ==
                                                    null
                                                ? ''
                                                : receiptList[index]
                                                    ["applications"]["ref_id"],
                                            style: receiptText),
                                        Text(receiptList[index]["amount"].toString(),
                                            style: receiptText),
                                        Text(receiptList[index]["particular"],
                                            style: receiptText),
                                      ],
                                    ),
                                  ],
                                ),
                                MaterialButton(
                                  minWidth:
                                      MediaQuery.of(context).size.width - 20,
                                  color: Colors.orange[600],
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ViewReceiptScreen2(
                                            receiptList[index]['id'].toString()),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "View Receipt",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            )),
                      ),
                    );
                  },
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const receiptText = TextStyle(
  color: blackC,
  fontSize: 17,
);
