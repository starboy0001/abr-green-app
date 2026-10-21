import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:property_project/Screens/payment_receipt_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:property_project/Constants/colors.dart';
import '../Constants/constants.dart';
import '../Utils/utils.dart';
import '../res/app_urls.dart';
import 'Drawer/contact_us_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class SingleApplicationScreen extends StatefulWidget {
  SingleApplicationScreen(this.customerId, {super.key});
  String customerId;

  @override
  State<SingleApplicationScreen> createState() =>
      _SingleApplicationScreenState();
}

class _SingleApplicationScreenState extends State<SingleApplicationScreen> {
  var application;
  var projectDetail;
  late List<dynamic> agentList;
  late List<dynamic> formTypeList;
  late List<dynamic> plotSizeList;
  late List<dynamic> plotFacingList;
  late List<dynamic> paymentModeList;
  late List<dynamic> paymentPlanList;
  String accessToken = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startXeeProcesses();
  }

  startXeeProcesses() async {
    await getSharedPref();
    await getPreferences();
    await getData();
  }

  getSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("accessToken") ?? "";
  }

  void downloadImage(String imageUrl) async {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16.0),
              Text("Downloading..."),
            ],
          ),
        );
      },
    );
    var response = await http.post(Uri.parse(imageUrl), headers: {
      'Authorization': 'Bearer $accessToken',
    }, body: {
      "id": widget.customerId
    });
    Navigator.pop(context); // Close the
    if (response.statusCode == 200) {
      // Image downloaded successfully
      var bytes = response.bodyBytes;
      // Save the image locally or use it as needed
      // For example, you can save it to a file using the following code:
      var directory = await getApplicationDocumentsDirectory();
      var filePath = '${directory.path}/letter.pdf';
      File pdfFile = await File(filePath).writeAsBytes(bytes);
      // Utils.flushBarSuccessMessage("File Downloaded", context);
      OpenFilex.open(pdfFile.path);
    } else {
      print(response.statusCode);
      Utils.flushBarErrorMessage("Cannot Download", context);
      // Failed to download image
      // Handle the error
    }
  }

  getPreferences() async {
    print("============================= get preferences ");

    String url = AppUrl.getPreferences;

    final response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    });
    print(response.statusCode);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      // print(jsonData);
      // Get data of a specific ID from the 'agent' list
      setState(() {
        agentList = jsonData['data']['agent'];
        formTypeList = jsonData['data']['formType'];
        plotSizeList = jsonData['data']['plotSize'];
        plotFacingList = jsonData['data']['plotFacing'];
        paymentModeList = jsonData['data']['paymentMode'];
        paymentPlanList = jsonData['data']['paymentPlan'];
      });

      // Specify the ID of the agent you want to retrieve
    } else {
      Utils.flushBarErrorMessage("Something went wrong", context);
    }
  }

  String getAgent(int specificId) {
    Map<String, dynamic>? specificAgentData = agentList
        .firstWhere((agent) => agent['id'] == specificId, orElse: () => null);
    if (specificAgentData != null) {
      // Data of the specific agent ID is available
      print(specificAgentData.toString());
      return specificAgentData["name"];
    } else {
      // Data of the specific agent ID is not found
      return "N/A";
    }
  }

  String getPlotSize(int specificId) {
    Map<String, dynamic>? specificData = plotSizeList
        .firstWhere((agent) => agent['id'] == specificId, orElse: () => null);
    if (specificData != null) {
      // Data of the specific agent ID is available
      return specificData["name"];
    } else {
      // Data of the specific agent ID is not found
      return "N/A";
    }
  }

  List<String> getPlotFacing(String ids) {
    List<String> selectedNames = [];

    // Extracting the selected IDs
    List<int> selectedIds = ids.split(',').map(int.parse).toList();

    // Filtering the plotFacingList based on the selected IDs
    for (var item in plotFacingList) {
      int id = item['id'];
      if (selectedIds.contains(id)) {
        String name = item['name'];
        selectedNames.add(name);
      }
    }

    return selectedNames;
  }

  String getPaymentMode(int specificId) {
    Map<String, dynamic>? specificData = paymentModeList
        .firstWhere((agent) => agent['id'] == specificId, orElse: () => null);
    if (specificData != null) {
      // Data of the specific agent ID is available
      return specificData["name"];
    } else {
      // Data of the specific agent ID is not found
      return "N/A";
    }
  }

  String getPaymentPlan(int specificId) {
    Map<String, dynamic>? specificData = paymentPlanList
        .firstWhere((agent) => agent['id'] == specificId, orElse: () => null);
    if (specificData != null) {
      // Data of the specific agent ID is available
      return specificData["name"];
    } else {
      // Data of the specific agent ID is not found
      return "N/A";
    }
  }

  String getFormType(int specificId) {
    Map<String, dynamic>? specificData = formTypeList
        .firstWhere((agent) => agent['id'] == specificId, orElse: () => null);
    if (specificData != null) {
      // Data of the specific agent ID is available
      return specificData["name"];
    } else {
      // Data of the specific agent ID is not found
      return "N/A";
    }
  }

  getData() async {
    print(' ===========================  get data');

    // accessToken = "";
    print("access token from sharepref is : $accessToken");
    print(">>> customer id is ${widget.customerId}");

    String url = AppUrl.customerApplicationView;
    // print(url);
    final response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    }, body: {
      "id": widget.customerId
    });
    print(response.statusCode);
    var jsonData = json.decode(response.body);
    setState(() {
      application = jsonData['data']['application'];
      projectDetail = jsonData['data']['project_detail'];
    });

    if (response.statusCode == 200) {
      if (jsonData['success'] == true) {
        // get all user application data
      } else {
        Utils.flushBarSuccessMessage("Something went wrong", context);
      }
    } else {
      Utils.flushBarErrorMessage("Something went wrong", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'Application Detail',
            style: appThemeTextWhiteC,
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: appBarGradient,
            ),
          ),
        ),
        body: application == null || projectDetail == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: double.infinity,
                          child: DataTable(
                            columns: <DataColumn>[
                              DataColumn(label: Text("Applicant Detail")),
                              DataColumn(label: Text(""))
                            ],
                            rows: <DataRow>[
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Profile Image')),
                                  DataCell(
                                    CircleAvatar(
                                      backgroundColor: lightBlueContainerC,
                                      radius: 33,
                                      backgroundImage: NetworkImage(
                                          AppUrl.imageBaseUrl != null &&
                                                  application["avatar"] != null
                                              ? AppUrl.imageBaseUrl +
                                                  application["avatar"]
                                              : ''),
                                    ),
                                  ),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Name')),
                                  DataCell(Text(application['name'] +
                                      " " +
                                      application['surname'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('S/D/W/O')),
                                  DataCell(Text(application['sonof'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Email')),
                                  DataCell(Text(application['email'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Mobile')),
                                  DataCell(Text(application['mobile'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Adhaar')),
                                  DataCell(Text(application['adhaar'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('City')),
                                  DataCell(Text(application['city'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Profession')),
                                  DataCell(Text(application['profession'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Nationality')),
                                  DataCell(Text(application['nationality'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Date of Birth')),
                                  DataCell(Text(application['dob'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('State')),
                                  DataCell(Text(application['state'])),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: double.infinity,
                          child: DataTable(
                            columns: <DataColumn>[
                              DataColumn(label: Text("Co-Applicant Detail")),
                              DataColumn(label: Text(""))
                            ],
                            rows: <DataRow>[
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Profile Image')),
                                  DataCell(
                                    CircleAvatar(
                                      backgroundColor: lightBlueContainerC,
                                      radius: 33,
                                      backgroundImage: NetworkImage(
                                          AppUrl.imageBaseUrl != null &&
                                                  application["ca_avatar"] !=
                                                      null
                                              ? AppUrl.imageBaseUrl +
                                                  application["ca_avatar"]
                                              : ''),
                                    ),
                                  ),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Name')),
                                  DataCell(Text(application['ca_name'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('S/O')),
                                  DataCell(Text(application['ca_sonof'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Email')),
                                  DataCell(Text(application['ca_email'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Mobile')),
                                  DataCell(Text(application['ca_mobile'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(
                                    Text('Adhaar'),
                                  ),
                                  DataCell(Text(application['ca_adhaar'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('City')),
                                  DataCell(Text(application['ca_city'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Profession')),
                                  DataCell(Text(application['ca_profession'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Nationality')),
                                  DataCell(Text(application['ca_nationality'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Date of Birth')),
                                  DataCell(Text(application['ca_dob'])),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('State')),
                                  DataCell(Text(application['ca_state'])),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: double.infinity,
                          child: DataTable(
                            columns: <DataColumn>[
                              DataColumn(label: Text("Preferences")),
                              DataColumn(label: Text(""))
                            ],
                            rows: <DataRow>[
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Advisor')),
                                  DataCell(Text(
                                    getAgent(int.parse(
                                        application["selected_advisor"])),
                                  )),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Plot Size')),
                                  DataCell(Text(getPlotSize(int.parse(
                                      application['selected_plot_size'])))),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Plot Facing')),
                                  DataCell(
                                    SizedBox(
                                      height: 700,
                                      width: 500,
                                      child: ListView.builder(
                                          itemCount: getPlotFacing(application[
                                                  "selected_plot_facing"])
                                              .length,
                                          itemBuilder: (context, i) {
                                            return Text(getPlotFacing(
                                                application[
                                                    "selected_plot_facing"])[i]);
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Payment Plan')),
                                  DataCell(Text(getPaymentPlan(int.parse(
                                      application["selected_payment_plan"])))),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Form Type')),
                                  DataCell(Text(
                                      application["selected_form_type"]
                                          .toString())),
                                ],
                              ),
                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Payment Mode')),
                                  DataCell(Text(getPaymentMode(int.parse(
                                      application['selected_payment_mode'])))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          application["ticket_no"] == null ||
                                  application["ticket_no"] == "" &&
                                      application["status"] == 1
                              ? Container()
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: appBarGradient,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: MaterialButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PaymentReceiptScreen(
                                            applicationId: int.tryParse(
                                                    widget.customerId) ??
                                                1,
                                            application: application,
                                          ),
                                        ),
                                      );
                                    },
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "View Receipt",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                          SizedBox(width: 7),
                          Container(
                            decoration: BoxDecoration(
                              gradient: appBarGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: MaterialButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ContactUsScreen(),
                                  ),
                                );
                              },
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Contact Support",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      const SizedBox(height: 5),
                    ]),
              ));
  }
}