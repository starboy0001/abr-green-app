import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:property_project/Screens/Auth%20Screen/login_screen.dart';
import 'package:property_project/Screens/home_screen.dart';
import 'package:property_project/res/app_urls.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants/colors.dart';
import '../../Constants/constants.dart';
import '../../Utils/utils.dart';
import '../../notifications/noti.dart';

FirebaseApi firebaseApi = FirebaseApi();

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // GlobalKey<FormState> _formKeySignup = GlobalKey<FormState>();
  GlobalKey<FormState> myKeySignup =
      GlobalKey<FormState>(debugLabel: '_signupScreenkey');
  bool showSpinner = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Form(
        key: myKeySignup,
        child: SafeArea(
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
                    height: 30,
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
                    height: 10,
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
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Center(
                                child: Text(
                                  "Welcome to Family",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        30.0), // Set border radius
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: surnameController,
                                decoration: InputDecoration(
                                  labelText: 'Surname',
                                  prefixIcon:
                                      Icon(Icons.person_add_alt_rounded),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        30.0), // Set border radius
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter surname';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Enter Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        30.0), // Set border radius
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: mobileController,
                                decoration: InputDecoration(
                                  labelText: 'Mobile',
                                  prefixIcon: Icon(Icons.phone_iphone),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        30.0), // Set border radius
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter mobile no.';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                obscureText: true,
                                controller: passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.key),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        30.0), // Set border radius
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: addressController,
                                decoration: InputDecoration(
                                  labelText: 'Address',
                                  prefixIcon: Icon(Icons.place),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        30.0), // Set border radius
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: cityController,
                                decoration: InputDecoration(
                                  labelText: 'City',
                                  prefixIcon: Icon(Icons.location_city),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        30.0), // Set border radius
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter city';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: stateController,
                                decoration: InputDecoration(
                                  labelText: 'State',
                                  prefixIcon: Icon(Icons.location_searching),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        30.0), // Set border radius
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter state';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  if (myKeySignup.currentState!.validate()) {
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => HomeScreen()));
                                    registerCustomer();
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
                                    child: Text('REGISTER',
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                            builder: (context) => LoginScreen(),
                                          ),
                                        );
                                      },
                                      child: ShaderMask(
                                        shaderCallback: (Rect bounds) {
                                          return appBarGradient
                                              .createShader(bounds);
                                        },
                                        blendMode: BlendMode.srcIn,
                                        child: Text(
                                          'Login Here',
                                          style: TextStyle(
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
          ),
        ),
      ),
    );
  }

  registerCustomer() async {
    setState(() {
      showSpinner = true;
    });

    // String? token = sp.getString('token');
    // print('token from register 168 $token');
    String url = AppUrl.registerApiEndPoint;

    try {
      final response = await http.post(Uri.parse(url), body: {
        'name': nameController.text.trim().toString(),
        'surname': surnameController.text.trim(),
        'email': emailController.text.trim(),
        'mobile': mobileController.text.trim(),
        'password': passwordController.text.trim(),
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
      }).timeout(const Duration(seconds: 10));

      print(">>> ${response.statusCode.toString()}");

      if (response.statusCode == 200) {
        setState(() {
          showSpinner = false;
        });

        print(
            'this is register api response: ${json.decode(response.body)["data"]}');
        var jsonData = json.decode(response.body);
        String accessToken = jsonData["data"]["access"];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("accessToken", accessToken);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
        nameController.clear();
        surnameController.clear();
        emailController.clear();
        mobileController.clear();
        passwordController.clear();
        addressController.clear();
        cityController.clear();
        stateController.clear();

        await firebaseApi.pushFCM();
      } else if (response.statusCode == 400) {
        setState(() {
          showSpinner = false;
        });
        Utils.flushBarErrorMessage('Registration failed. Please check inputs.', context);
      } else if (response.statusCode == 401) {
        setState(() {
          showSpinner = false;
        });
        Utils.flushBarErrorMessage(
            '${json.decode(response.body)["errors"][0][0]}', context);
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
        Utils.flushBarErrorMessage('Registration failed. Please try again.', context);
      }
    } catch (err) {
      setState(() {
        showSpinner = false;
      });
      Utils.flushBarErrorMessage('Connection failed. Please check network/server.', context);
      print("Registration error: $err");
    }
  }
}
