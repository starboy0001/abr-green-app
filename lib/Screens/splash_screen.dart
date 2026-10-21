import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:property_project/Screens/Auth%20Screen/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: unused_import
import 'dart:math' as math;

import '../res/app_urls.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    startXeeProcesses();
  }

  startXeeProcesses() {
    Timer(const Duration(seconds: 2), () {
      checkCustomerVerification();
    });
  }

  checkCustomerVerification() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String accessToken = prefs.getString("accessToken") ?? "";
      print("access token from sharepref is : $accessToken");

      if (accessToken.isEmpty) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false);
        return;
      }

      String url = AppUrl.customerVerifyApiEndPoint;
      final response = await http.post(Uri.parse(url), headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 4));

      if (!mounted) return;

      if (response.statusCode == 200) {
        bool success = json.decode(response.body)["success"] ?? false;
        if (success == true) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false);
          return;
        }
      }
    } catch (e) {
      print("Splash verification exception: $e");
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        child:
            Center(child: Image(image: AssetImage('assets/images/splash.png'))),
      ),
    );
  }
}
