import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:property_project/Screens/Classes/lucky_draw.dart';
import 'package:property_project/Screens/Classes/referals_model.dart';
import 'package:property_project/Utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/colors.dart';
import '../Constants/constants.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../Constants/reusable_widgets.dart';
import '../res/app_urls.dart';

class ReferalsScreen extends StatefulWidget {
  ReferalsScreen({super.key});

  @override
  State<ReferalsScreen> createState() => _ReferalsScreenState();
}

class _ReferalsScreenState extends State<ReferalsScreen> {
  bool spinner = true;
  String accessToken = "";
  List<ReferalData> referalsList = [];
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startProcesses();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String mobile = _mobileController.text;

      // Do something with the form data
      print('Name: $name');
      print('Mobile: $mobile');

      String url = AppUrl.createReferal;
      final response = await http.post(Uri.parse(url), headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      }, body: {
        "name": _nameController.text,
        "mobile": _mobileController.text
      });
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          _nameController.text = "";
          _mobileController.text = "";
          Utils.flushBarSuccessMessage("Referal Added Successfully", context);
          getReferals();
        } else {
          Utils.flushBarErrorMessage(
              "Cannot add referal, some error occured", context);
        }
      } else {
        Utils.flushBarErrorMessage(
            "Cannot submit, some error occured", context);
      }
    }
  }

  startProcesses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    getReferals();
  }

  getReferals() async {
    referalsList = [];
    String url = AppUrl.getReferals;
    final response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    });
    setState(() {
      spinner = false;
    });
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        List<dynamic> referals = jsonData['data']['referrals'];
        setState(() {
          referalsList = referals.map((e) => ReferalData.fromJson(e)).toList();
        });
        print(referalsList);
      } else {
        Utils.flushBarErrorMessage("Cannot get referals", context);
      }
    } else {
      Utils.flushBarErrorMessage("Cannot get referals", context);
    }
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    DateFormat format = DateFormat('y-MM-dd HH:mm:ss');
    String formattedDateTime = format.format(dateTime);
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        centerTitle: false,
        title: Text('Referals'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: appBarGradient,
          ),
        ),
      ),
      body: spinner == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                                labelText: 'Enter Referee Name'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter name';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _mobileController,
                            decoration: InputDecoration(
                                labelText: 'Enter Referee Mobile'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter mobile number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.0),
                          MaterialButton(
                            color: orangeC,
                            onPressed: _submitForm,
                            child: Text(
                              'Submit',
                              style: TextStyle(color: whiteC),
                            ),
                          ),
                        ],
                      )),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: referalsList.length,
                      itemBuilder: (context, i) {
                        return Card(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      referalsList[i].name,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text("Mobile"),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      referalsList[i].mobile,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: orangeC),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
    );
  }
}