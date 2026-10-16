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

class ResaleScreen extends StatefulWidget {
  ResaleScreen({super.key});

  @override
  State<ResaleScreen> createState() => _ResaleScreenState();
}

class _ResaleScreenState extends State<ResaleScreen> {
  bool spinner = true;
  String accessToken = "";
  String resaleStatus = "";
  final _formKey = GlobalKey<FormState>();

  List<Project> projectList = [];
  Project? selectedProject;
  TextEditingController _societyController = TextEditingController();
  TextEditingController _plotController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _societyController.dispose();
    _plotController.dispose();
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
      String url = AppUrl.createResale;
      final response = await http.post(Uri.parse(url), headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      }, body: {
        "project_id": selectedProject!.id.toString(),
        "society": _societyController.text,
        "plot": _plotController.text
      });
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          _societyController.text = "";
          _plotController.text = "";
          setState(() {
            selectedProject = null;
          });
          Utils.flushBarSuccessMessage(jsonData['data'][0].toString(), context);
        } else {
          Utils.flushBarErrorMessage(
              "Cannot add resale, some error occured", context);
        }
      } else {
        print(response.statusCode);
        Utils.flushBarErrorMessage(
            "Cannot submit, some error occured", context);
      }
    }
  }

  startProcesses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    await getProjects();
    await getStatus();
  }

  getProjects() async {
    String url = AppUrl.getProjects;
    final response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['success'] == true) {
        List<dynamic> projects = jsonData['data']['projects'];
        setState(() {
          projectList = projects.map((project) {
            return Project(project['id'], project['project_name']);
          }).toList();
        });
        // Convert the projects data into a list of Project objects

        print(">>> Projects");
      } else {
        Utils.flushBarErrorMessage("Cannot get projects list", context);
      }
    } else {
      Utils.flushBarErrorMessage("Cannot get projects list", context);
    }
  }

  getStatus() async {
    String url = AppUrl.verifyResale;
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
        resaleStatus = jsonData['data'][0]['resale_status'] ?? "1";
        if (resaleStatus == "1") {
          // eligible
          print("user is eligible");
        } else {
          // not eligible messge
          print("user is not eligible");
        }
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
        title: Text('Resale'),
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
          : resaleStatus == "1"
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<Project>(
                              value: selectedProject,
                              onChanged: (Project? newValue) {
                                setState(() {
                                  selectedProject = newValue;
                                });
                              },
                              items: projectList.map((Project project) {
                                return DropdownMenuItem<Project>(
                                  value: project,
                                  child: Text(project.projectName),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                labelText: 'Select Project',
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.projectName.isEmpty) {
                                  return 'Please select a project';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _societyController,
                              decoration:
                                  InputDecoration(labelText: 'Enter Society'),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter society';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _plotController,
                              decoration:
                                  InputDecoration(labelText: 'Enter Plot'),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter plot';
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
                )
              : Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: orangeC,
                      size: 50,
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "You are not eligible for resale yet. Please contact your relationship manager.",
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                )),
    );
  }
}

// Define a class to represent the project data
class Project {
  final int id;
  final String projectName;

  Project(this.id, this.projectName);
}