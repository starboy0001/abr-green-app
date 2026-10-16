import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:property_project/Screens/Auth%20Screen/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:property_project/Utils/utils.dart';
import 'package:property_project/res/app_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants/colors.dart';
import '../../Constants/constants.dart';

class ForgetPasswordScreen extends StatefulWidget {
  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  GlobalKey<FormState> _formKeyForgetPassword =
      GlobalKey<FormState>(debugLabel: '_forgetScreenkey');
  bool showSpinner = false;
  TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Form(
            key: _formKeyForgetPassword,
            child: Scaffold(
              body: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    colors: [
                      Color.fromARGB(255, 255, 115, 39),
                      // Color(0xFFEF6C00),
                      Color(0xFFFFA726)
                    ],
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/images/backgroud.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 120,
                    ),
                    Container(
                      height: 100,
                      width: width,
                      child: Center(
                        child: Image(
                            height: 100,
                            image: AssetImage('assets/images/drawer.png')),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    Expanded(
                      child: Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(60),
                              topRight: Radius.circular(60)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "Forget Password",
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        TextFormField(
                                          controller: _textEditingController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Mobile Number',
                                            prefixIcon: Icon(
                                                Icons.mobile_friendly_outlined),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      30.0), // Set border radius
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blue),
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                          ),
                                          validator: (value) {
                                            print(value);
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter registered mobile no.';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 15),
                                        GestureDetector(
                                          onTap: () {
                                            if (_formKeyForgetPassword
                                                .currentState!
                                                .validate()) {
                                              forgetPassword();
                                            }
                                          },
                                          child: Container(
                                            height: 50,
                                            width: width,
                                            decoration: BoxDecoration(
                                              gradient: appBarGradient, // Set background color
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      30), // Set border radius
                                            ),
                                            child: Center(
                                              child: Text('SUBMIT',
                                                  style: appThemeTextWhiteC),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        GestureDetector(
                                          onTap: () {
                                            // Don't have an account logic
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Already a Member? ",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              LoginScreen()));
                                                },
                                                child: ShaderMask(
                                                  shaderCallback:
                                                      (Rect bounds) {
                                                    return appBarGradient
                                                        .createShader(bounds);
                                                  },
                                                  blendMode: BlendMode.srcIn,
                                                  child: Text(
                                                    'Login Here',
                                                    style: TextStyle(
                                                      letterSpacing: 1,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }

  forgetPassword() async {
    setState(() {
      showSpinner = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    // String? token = sp.getString('token');
    // print('token from register 168 $token');
    String url = AppUrl.forgetPassword;

    try {
      final response = await http.post(Uri.parse(url), body: {
        'mobile': _textEditingController.text,
      }, headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      print(">>> forgot password response ${response.body.toString()}");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        print(">>> response body forgot_password page ${jsonData}");
        if (jsonData["success"] == true) {
          Utils.flushBarSuccessMessage('Password Updated Successfully', context);
        } else {
          Utils.flushBarErrorMessage("Something went wrong", context);
        }

        setState(() {
          showSpinner = false;
        });
      } else if (response.statusCode == 400) {
        setState(() {
          showSpinner = false;
        });
        print(response.statusCode);
      } else if (response.statusCode == 401) {
        var jsonData = json.decode(response.body);
        if (jsonData["success"] == false) {
          Utils.flushBarErrorMessage(jsonData["errors"][0], context);
        } else {
          Utils.flushBarErrorMessage("Something went wrong", context);
        }
        setState(() {
          showSpinner = false;
        });
        print(response.statusCode);
      } else if (response.statusCode == 422) {
        setState(() {
          showSpinner = false;
        });
        String error = json.decode(response.body)["errors"][0];
        Utils.flushBarErrorMessage(error, context);
      } else {
        setState(() {
          showSpinner = false;
        });
      }
    } catch (err) {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
        Utils.flushBarErrorMessage("Connection error. Please try again.", context);
      }
      print("forgetPassword error: $err");
    }
  }
}
