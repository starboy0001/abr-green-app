import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:property_project/Utils/utils.dart';
import 'package:property_project/res/app_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../Constants/colors.dart';
import '../../Constants/constants.dart';
import '../../Constants/reusable_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final String item;

  const ProfileScreen({required this.item});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> drawerItems = [
    'DASHBOARD',
    'MY PROFILE',
    'MY APPLICATIONS',
    'LUCKY DRAW',
    'CONTACT US',
    'PAYMENT DETAILS',
    'ABOUT US',
    'RECEIPT',
    'SIGN OUT',
  ];

  final List<IconData> drawerIcons = [
    Icons.home,
    Icons.person_outline,
    Icons.apps,
    Icons.redeem,
    Icons.headphones,
    Icons.attach_money,
    Icons.error_outline,
    Icons.description_outlined,
    Icons.logout_outlined,
  ];

  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  int selectedIndex = 0;
  bool showSpinner = false;
  bool initialLoader = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfileData();
  }

  getProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    String url = AppUrl.getProfile;

    final response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    });
    setState(() {
      initialLoader = false;
    });

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['success'] != null) {
        if (jsonData['success'] == true) {
          setState(() {
            userData = jsonData['data'];
            nameController.text =
                '${userData!['name'] ?? ''} ${userData!['surname'] ?? ''}'
                    .trim();
            mobileController.text = userData!['mobile'] ?? "";
            addressController.text = userData!['address'] ?? "";
            cityController.text = userData!['city'] ?? "";
            stateController.text = userData!['state'] ?? "";
          });
        } else {
          Utils.flushBarErrorMessage(
              "Some error occured while fetching data", context);
        }
      } else {
        Utils.flushBarErrorMessage(
            "Some error occured while fetching data", context);
      }
    } else {
      Utils.flushBarErrorMessage(
          "Some error occured while fetching data", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'My Profile',
            style: appThemeTextWhiteC,
          ),
          flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: appBarGradient,
          ),
        ),
        ),
        drawer: AppDrawer(),
        body: initialLoader == true
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ModalProgressHUD(
                inAsyncCall: showSpinner,
                child: SingleChildScrollView(
                    child: Container(
                  // height: height,
                  width: width,
                  color: selectedColor,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Container(
                          // height: 100,
                          // width: width,
                          child: Row(
                            children: [
                              Icon(Icons.person),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'Update Profile',
                                style: appThemeTextBlackCSmall,
                              )
                            ],
                          ),
                        ),
                      ),
                      profileContainer(width),
                      Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Container(
                          child: Row(
                            children: [
                              SizedBox(height: 10,),
                              Icon(Icons.lock),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'Change Password',
                                style: appThemeTextBlackCSmall,
                              )
                            ],
                          ),
                        ),
                      ),
                      changePasswordContainer(width)
                    ],
                  ),
                )),
              ));
  }

  profileContainer(double width) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        width: width,
        color: whiteC,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text("Email: " +
                  userData!["email"],
                  style: TextStyle(color: dividerC, fontSize: 18),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: nameController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  labelStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: mobileController,
                decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),),
              ),
              SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                    labelText: 'Address', labelStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),),
              ),
              SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                    labelText: 'City', labelStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),),
              ),
              SizedBox(height: 12),
              TextField(
                controller: stateController,
                decoration: InputDecoration(
                    labelText: 'State', 
                    labelStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),),
                    
              ),
              SizedBox(height: 12),
              Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => _submitForm(),
                    child: Container(
                      height: 43,
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: appBarGradient,
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(color: orangeC)),
                      child: Center(
                        child: Text(
                          'UPDATE',
                          style: TextStyle(color: whiteC),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  changePasswordContainer(double width) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        height: 210,
        width: width,
        color: whiteC,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                ),
              ),
              SizedBox(height: 16),
              Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => _submitPasswordForm(),
                    child: Container(
                      height: 43,
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: appBarGradient,
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(color: orangeC)),
                      child: Center(
                        child: Text(
                          'UPDATE',
                          style: TextStyle(color: whiteC),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (mobileController.text.isEmpty &&
        addressController.text.isEmpty &&
        cityController.text.isEmpty &&
        stateController.text.isEmpty) {
      Utils.flushBarErrorMessage('Please fill all fields', context);
    }

    updateProfile();
  }

  void _submitPasswordForm() {
    if (oldPasswordController.text.isEmpty &&
        newPasswordController.text.isEmpty) {
      Utils.flushBarErrorMessage('Please fill all fields', context);
    }

    updatePassword();
  }

  updateProfile() async {
    setState(() {
      showSpinner = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    String url = AppUrl.updateProfile;

    try {
      final response = await http.post(Uri.parse(url), body: {
        "mobile": mobileController.text.trim().toString(),
        "address": addressController.text.toString(),
        "city": cityController.text.toString(),
        "state": stateController.text.toString()
      }, headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          showSpinner = false;
        });
        mobileController.clear();
        addressController.clear();
        cityController.clear();
        stateController.clear();
        Utils.flushBarSuccessMessage('Profile Updated Successfully', context);
      } else {
        setState(() {
          showSpinner = false;
        });
        print(response.statusCode);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
        Utils.flushBarErrorMessage('Failed to update profile.', context);
      }
      print("updateProfile error: $e");
    }
  }

  updatePassword() async {
    setState(() {
      showSpinner = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      String url = AppUrl.updatePassword;

      final response = await http.post(Uri.parse(url), body: {
        "old_password": oldPasswordController.text.trim().toString(),
        "new_password": newPasswordController.text.trim().toString(),
      }, headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          showSpinner = false;
        });
        oldPasswordController.clear();
        newPasswordController.clear();
        Utils.flushBarSuccessMessage('Password Updated Successfully', context);
      } else if (response.statusCode == 422) {
        setState(() {
          showSpinner = false;
        });
        String msg = json.decode(response.body)["errors"][0][0].toString();
        Utils.flushBarErrorMessage('$msg', context);
        print('error msg is: $msg');
      } else {
        setState(() {
          showSpinner = false;
        });
        print(response.statusCode);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
        Utils.flushBarErrorMessage('Failed to update password.', context);
      }
      print("updatePassword error: $e");
    }
  }
}
