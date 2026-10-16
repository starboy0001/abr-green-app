import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:property_project/Constants/colors.dart';
import 'package:property_project/Screens/Auth%20Screen/signup_screen.dart';
import 'package:property_project/Screens/home_screen.dart';
import 'package:property_project/Utils/utils.dart';
import 'package:property_project/res/app_urls.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants/constants.dart';
import 'forget_password_Screen.dart';
import '../../notifications/noti.dart';

FirebaseApi firebaseApi = FirebaseApi();

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> myKey =
      GlobalKey<FormState>(debugLabel: '_homeScreenkey');
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showSpinner = false;
  String? accessToken;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Form(
            key: myKey,
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
                      height: 50,
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
                        padding: EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Text(
                                        "Welcome Back",
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 30),
                                      TextFormField(
                                        autocorrect: false,
                                        controller: emailController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please fill Field';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Enter Email / Mobile no.',
                                          prefixIcon: Icon(Icons.person),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                30.0), // Set border radius
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.blue),
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      TextFormField(
                                        controller: passwordController,
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          prefixIcon: Icon(Icons.key_rounded),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                30.0), // Set border radius
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.blue),
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                        ),
                                        obscureText: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter Password';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ForgetPasswordScreen()));
                                              },
                                              child: Text(
                                                'Forgot Password?',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      GestureDetector(
                                        onTap: () {
                                          if (myKey.currentState!.validate()) {
                                            // If the form is valid, display a snackbar. In the real world,
                                            // you'd often call a server or save the information in a database.
                                            //
                                            loginCustomer();
                                          }
                                        },
                                        child: Container(
                                          height: 50,
                                          width: width,
                                          decoration: BoxDecoration(
                                            gradient:
                                                appBarGradient, // Set background color
                                            borderRadius: BorderRadius.circular(
                                                30), // Set border radius
                                          ),
                                          child: Center(
                                            child: Text('LOGIN',
                                                style: appThemeTextWhiteC),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () {
                                          // Don't have an account logic
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Not a Member? ",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            SignupScreen()));
                                              },
                                              child: ShaderMask(
                                                shaderCallback: (Rect bounds) {
                                                  return appBarGradient
                                                      .createShader(bounds);
                                                },
                                                blendMode: BlendMode.srcIn,
                                                child: Text(
                                                  'Register Now',
                                                  style: TextStyle(
                                                    letterSpacing: 1,
                                                    fontWeight: FontWeight.bold,
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
                              ]),
                        ),
                      ),
                    ))
                  ],
                ),
              ),
            )));
  }

  loginCustomer() async {
    setState(() {
      showSpinner = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // String? token = sp.getString('token');
    // print('token from register 168 $token');
    String url = AppUrl.loginEndPoint;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    print("version: $version");

    try {
      final response = await http.post(Uri.parse(url), body: {
        'email': emailController.text.trim().toString(),
        'password': passwordController.text.trim(),
        'version': version,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          showSpinner = false;
        });
        print(
            'this is login api response: ${json.decode(response.body)["data"]}');
        print('access token is: ${json.decode(response.body)["data"]["access"]}');
        accessToken = json.decode(response.body)["data"]["access"];
        prefs.setString('accessToken', accessToken!);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false);
        await firebaseApi.pushFCM();
      } else if (response.statusCode == 400) {
        Utils.flushBarErrorMessage('Something went wrong!', context);
        setState(() {
          showSpinner = false;
        });
        print(response.statusCode);
      } else if (response.statusCode == 401) {
        Utils.flushBarErrorMessage(
            '${json.decode(response.body)["errors"][0][0]}', context);
        setState(() {
          showSpinner = false;
        });
        print(response.statusCode);
      } else if (response.statusCode == 500) {
        Utils.flushBarErrorMessage('Server error. Please try again.', context);
        setState(() {
          showSpinner = false;
        });
        print(response.statusCode);
      } else {
        Utils.flushBarErrorMessage('Something went wrong!', context);
        setState(() {
          showSpinner = false;
        });
      }
    } catch (e) {
      setState(() {
        showSpinner = false;
      });
      Utils.flushBarErrorMessage('Cannot connect to server. Check connection.', context);
      print("Login error: $e");
    }
  }
}
