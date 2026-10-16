import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:property_project/Constants/colors.dart';
import 'package:property_project/Utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:path/path.dart' as pth;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:intl/intl.dart';

import '../Constants/constants.dart';
import '../res/app_urls.dart';
import 'Classes/prefs_class.dart';
import 'Drawer/payment_screen.dart';
import 'home_screen.dart';

class CreateApplicationScreen extends StatefulWidget {
  int? projectId;
  CreateApplicationScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  _CreateApplicationScreenState createState() =>
      _CreateApplicationScreenState();
}

class _CreateApplicationScreenState extends State<CreateApplicationScreen> {
  String? finalProfileUrl;
  String? finalProfileUrlCo;
  String? finalAdhaarUrl;
  String? finalAdhaarUrlCo;
  String? finalPanUrl;
  String? finalPanUrlCo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPreferences();
  }

  int _activeCurrentStep = 0;
//   **************     applicant controllers      *******************
  TextEditingController nameController = TextEditingController();
  TextEditingController surNameController = TextEditingController();
  TextEditingController relationController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController professionController = TextEditingController();
  TextEditingController adhaarController = TextEditingController();
  TextEditingController panController = TextEditingController();

  bool nameError = false;
  String? nameErrorMessage = null;
  bool surnameError = false;
  String? surnameErrorMessage = null;
  bool relationError = false;
  String? relationErrorMessage = null;
  bool emailError = false;
  String? emailErrorMessage = null;
  bool mobileError = false;
  String? mobileErrorMessage = null;
  bool addressError = false;
  String? addressErrorMessage = null;
  bool cityError = false;
  String? cityErrorMessage = null;
  bool stateError = false;
  String? stateErrorMessage = null;
  bool nationalityError = false;
  String? nationalityErrorMessage = null;
  bool dobError = false;
  String? dobErrorMessage = null;
  bool professionError = false;
  String? professionErrorMessage = null;
  bool adhaarError = false;
  String? adhaarErrorMessage = null;
  bool panError = false;
  String? panErrorMessage = null;

  //   **************     applicant controllers      *******************

  bool _submittedprofile1 = false;
  bool _submittedaadhaar1 = false;
  bool _submittedpan1 = false;
  bool _submittedprofile2 = false;
  bool _submittedaadhaar2 = false;
  bool _submittedpan2 = false;

  //   **************     preferences controllers      *******************

  TextEditingController nameControllerPrefer = TextEditingController();
  TextEditingController surNameControllerPrefer = TextEditingController();
  TextEditingController relationControllerPrefer = TextEditingController();
  TextEditingController emailControllerPrefer = TextEditingController();
  TextEditingController mobileControllerPrefer = TextEditingController();
  TextEditingController addressControllerPrefer = TextEditingController();
  TextEditingController cityControllerPrefer = TextEditingController();
  TextEditingController stateControllerPrefer = TextEditingController();
  TextEditingController nationalityControllerPrefer = TextEditingController();
  TextEditingController dobControllerPrefer = TextEditingController();
  TextEditingController professionControllerPrefer = TextEditingController();
  TextEditingController adhaarControllerPrefer = TextEditingController();
  TextEditingController panControllerPrefer = TextEditingController();

  bool nameErrorPrefer = false;
  String? nameErrorMessagePrefer = null;
  bool surnameErrorPrefer = false;
  String? surnameErrorMessagePrefer = null;
  bool relationErrorPrefer = false;
  String? relationErrorMessagePrefer = null;
  bool emailErrorPrefer = false;
  String? emailErrorMessagePrefer = null;
  bool mobileErrorPrefer = false;
  String? mobileErrorMessagePrefer = null;
  bool addressErrorPrefer = false;
  String? addressErrorMessagePrefer = null;
  bool cityErrorPrefer = false;
  String? cityErrorMessagePrefer = null;
  bool stateErrorPrefer = false;
  String? stateErrorMessagePrefer = null;
  bool nationalityErrorPrefer = false;
  String? nationalityErrorMessagePrefer = null;
  bool dobErrorPrefer = false;
  String? dobErrorMessagePrefer = null;
  bool professionErrorPrefer = false;
  String? professionErrorMessagePrefer = null;
  bool adhaarErrorPrefer = false;
  String? adhaarErrorMessagePrefer = null;
  bool panErrorPrefer = false;
  String? panErrorMessagePrefer = null;

  //   **************     preferences controllers      *******************
  DateTime? _selectedDate;
  DateTime? _selectedDatePrefs;
  // String? _selectedOption;
  final myKeyApplication = GlobalKey<FormState>();

  File? image1;
  File? image2;
  File? image1Co;
  File? image2Co;

  File? profileImage;
  File? profileImageApplicant;
  File? profileImageCo;
  File? ImagePreference;

  final _imageProfilePickerApplicant = ImagePicker();
  final _imageProfilePickerCo = ImagePicker();
  final _imagePicker1 = ImagePicker();
  final _imagePicker2 = ImagePicker();
  final _imagePicker1Co = ImagePicker();
  final _imagePicker2Co = ImagePicker();

  String dropdownValue = 'Manesh';
  String dropdownValuePlotSize = 'More then 100 sqyd';
  List<String> advisorNames = ['Manesh', 'Paul', 'Dharmesh', 'Kartik'];

  bool cornerValue = false;
  bool mainRoad = false;
  bool parkFacing = false;
  String dropdownValueFormType = 'Form Type';

  String? _selectedItem;
  int numberOfApps = 1;
  List<int> _itemsNumberofApps = [1, 2, 3, 4];

  bool showSpinner = false;

  String? _selectedItemPaymentPlan;
  List<String> _dropdownItems = [];

  List<String> _dropdownItemsPaymentPlan = [];
  // List<String> _dropdownItemsAgent = [];
  List<String> _selectedItemsPlotFace = [];
  List<String> _checkboxItemsPlotFace = [];

//  ********    plot size     ********
  List<FormType> _formType = [];
  FormType? _selectedFormType;

//  ********    plot size     ********
  List<PlotSize> _plotSizes = [];
  PlotSize? _selectedPlotSize;

  //  ********    plot size     ********

//  ********    agent name     ********
  List<AgentName> _agentname = [];
  AgentName? _selectedAgentName;

  List<PaymentMode> _paymentMode = [];
  PaymentMode? _selectedPaymentMode;

  List<PaymentPlan> _paymentPlan = [];
  PaymentPlan? _selectedPaymentPlan;

  List<PlotFacing> _plotFacings = [];
  List<PlotFacing> _selectedPlotFacings = [];

  dynamic jsonDataAvatar;
  dynamic jsonDataAvatarCo;
  dynamic jsonDataAdhaar;
  dynamic jsonDataAdhaarCo;
  dynamic jsonDataPan;
  dynamic jsonDataPanCo;

  int? _selectedAgentId;
  bool selectedAgentIdError = false;

  int? selectedPaymentModeId;
  bool selectedPaymentModeIdError = false;

  int? selectedPaymentPlanId;
  bool selectedPaymentPlanIdError = false;

  int? _selectedFormTypeId;
  String? _selectedFormTypeName;
  bool selectedFormTypeNameError = false;

  int? selectedPlotSizeIds;
  bool selectedPlotSizeIdsError = false;

  int? selectedFormType;

  List<int> selectedPlotFacingIds = [];
  bool selectedPlotFacingIdsError = false;

  //   **************     applicant calender function      *******************

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        final formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        dobController.text = formattedDate;
        dobError = false;
        dobErrorMessage = null;
      });
    }
  }

  //   **************     applicant calender function      *******************

  //   **************     prefs calender function      *******************

  Future<void> _selectDatePreference(BuildContext context) async {
    final DateTime? pickedPrefs = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedPrefs != null && pickedPrefs != _selectedDate) {
      setState(() {
        _selectedDatePrefs = pickedPrefs;
        final formattedDateprefer =
            DateFormat('dd-MM-yyyy').format(pickedPrefs);
        dobControllerPrefer.text =
            formattedDateprefer; // Update the text field value
        dobErrorPrefer = false;
        dobErrorMessagePrefer = null;
      });
    }
  }

  //   **************     prefs calender function      *******************

  @override
  void dispose() {
    dobController.dispose();
    dobControllerPrefer.dispose();
    super.dispose();
  }

  String? _validateText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  bool _validateAllFields() {
    bool isValid = true;
    if (nameController.text.isEmpty) {
      setState(() {
        nameError = true;
        nameErrorMessage = "Please fill your name.";
      });
      isValid = false;
    }
    if (surNameController.text.isEmpty) {
      setState(() {
        surnameError = true;
        surnameErrorMessage = "Please fill your surname.";
      });
      isValid = false;
    }
    if (relationController.text.isEmpty) {
      setState(() {
        relationError = true;
        relationErrorMessage = "Please fill S/O | D/O | W/O.";
      });
      isValid = false;
    }
    if (emailController.text.isEmpty) {
      setState(() {
        emailError = true;
        emailErrorMessage = "Please fill your email.";
      });
      isValid = false;
    }
    if (mobileController.text.isEmpty) {
      setState(() {
        mobileError = true;
        mobileErrorMessage = "Please fill your mobile.";
      });
      isValid = false;
    }
    if (addressController.text.isEmpty) {
      setState(() {
        addressError = true;
        addressErrorMessage = "Please fill your address.";
      });
      isValid = false;
    }
    if (cityController.text.isEmpty) {
      setState(() {
        cityError = true;
        cityErrorMessage = "Please fill your city.";
      });
      isValid = false;
    }
    if (stateController.text.isEmpty) {
      setState(() {
        stateError = true;
        stateErrorMessage = "Please fill your state.";
      });
      isValid = false;
    }
    if (nationalityController.text.isEmpty) {
      setState(() {
        nationalityError = true;
        nationalityErrorMessage = "Please fill your nationality.";
      });
      isValid = false;
    }
    if (dobController.text.isEmpty) {
      setState(() {
        dobError = true;
        dobErrorMessage = "Please fill your DOB.";
      });
      isValid = false;
    }
    if (professionController.text.isEmpty) {
      setState(() {
        professionError = true;
        professionErrorMessage = "Please fill your Profession.";
      });
      isValid = false;
    }
    if (adhaarController.text.isEmpty) {
      setState(() {
        adhaarError = true;
        adhaarErrorMessage = "Please fill your Aadhaar Number.";
      });
      isValid = false;
    }
    if (panController.text.isEmpty) {
      setState(() {
        panError = true;
        panErrorMessage = "Please fill your Pan Number.";
      });
      isValid = false;
    }
    if (profileImageApplicant == null) {
      setState(() {
        _submittedprofile1 = true;
      });
      isValid = false;
    }
    if (image1 == null) {
      setState(() {
        _submittedaadhaar1 = true;
      });
      isValid = false;
    }
    if (image2 == null) {
      setState(() {
        _submittedpan1 = true;
      });
      isValid = false;
    }

    return isValid;
  }

  bool _validateCoFields() {
    bool isValid = true;
    if (checkedValue) return isValid;
    if (nameControllerPrefer.text.isEmpty) {
      setState(() {
        nameErrorPrefer = true;
        nameErrorMessagePrefer = "Please fill your name.";
      });
      isValid = false;
    }
    if (surNameControllerPrefer.text.isEmpty) {
      setState(() {
        surnameErrorPrefer = true;
        surnameErrorMessagePrefer = "Please fill your surname.";
      });
      isValid = false;
    }
    if (relationControllerPrefer.text.isEmpty) {
      setState(() {
        relationErrorPrefer = true;
        relationErrorMessagePrefer = "Please fill S/O | D/O | W/O.";
      });
      isValid = false;
    }
    if (emailControllerPrefer.text.isEmpty) {
      setState(() {
        emailErrorPrefer = true;
        emailErrorMessagePrefer = "Please fill your email.";
      });
      isValid = false;
    }
    if (mobileControllerPrefer.text.isEmpty) {
      setState(() {
        mobileErrorPrefer = true;
        mobileErrorMessagePrefer = "Please fill your mobile.";
      });
      isValid = false;
    }
    if (addressControllerPrefer.text.isEmpty) {
      setState(() {
        addressErrorPrefer = true;
        addressErrorMessagePrefer = "Please fill your address.";
      });
      isValid = false;
    }
    if (cityControllerPrefer.text.isEmpty) {
      setState(() {
        cityErrorPrefer = true;
        cityErrorMessagePrefer = "Please fill your city.";
      });
      isValid = false;
    }
    if (stateControllerPrefer.text.isEmpty) {
      setState(() {
        stateErrorPrefer = true;
        stateErrorMessagePrefer = "Please fill your state.";
      });
      isValid = false;
    }
    if (nationalityControllerPrefer.text.isEmpty) {
      setState(() {
        nationalityErrorPrefer = true;
        nationalityErrorMessagePrefer = "Please fill your nationality.";
      });
      isValid = false;
    }
    if (dobControllerPrefer.text.isEmpty) {
      setState(() {
        dobErrorPrefer = true;
        dobErrorMessagePrefer = "Please fill your DOB.";
      });
      isValid = false;
    }
    if (professionControllerPrefer.text.isEmpty) {
      setState(() {
        professionErrorPrefer = true;
        professionErrorMessagePrefer = "Please fill your Profession.";
      });
      isValid = false;
    }
    if (adhaarControllerPrefer.text.isEmpty) {
      setState(() {
        adhaarErrorPrefer = true;
        adhaarErrorMessagePrefer = "Please fill your Aadhaar Number.";
      });
      isValid = false;
    }
    if (panControllerPrefer.text.isEmpty) {
      setState(() {
        panErrorPrefer = true;
        panErrorMessagePrefer = "Please fill your Pan Number.";
      });
      isValid = false;
    }
    if (profileImageCo == null) {
      setState(() {
        _submittedprofile2 = true;
      });
      isValid = false;
    }
    if (image1Co == null) {
      setState(() {
        _submittedaadhaar2 = true;
      });
      isValid = false;
    }
    if (image2Co == null) {
      setState(() {
        _submittedpan2 = true;
      });
      isValid = false;
    }

    return isValid;
  }

  bool _validatePrefields() {
    bool isValid = true;
    if (_selectedAgentId.toString() == "null") {
      setState(() {
        selectedAgentIdError = true;
      });
      isValid = false;
    }
    if (selectedPaymentModeId.toString() == "null") {
      setState(() {
        selectedPaymentModeIdError = true;
      });
      isValid = false;
    }
    if (selectedPaymentPlanId.toString() == "null") {
      setState(() {
        selectedPaymentPlanIdError = true;
      });
      isValid = false;
    }
    if (_selectedFormTypeName.toString() == "null") {
      setState(() {
        selectedFormTypeNameError = true;
      });
      isValid = false;
    }
    if (selectedPlotSizeIds.toString() == "null") {
      setState(() {
        selectedPlotSizeIdsError = true;
      });
      isValid = false;
    }
    if (selectedPlotFacingIds.isEmpty) {
      setState(() {
        selectedPlotFacingIdsError = true;
      });
      isValid = false;
    }

    return isValid;
  }

  List<Step> stepList() => [
        // This is step1 which is called Account.
        // Here we will fill our personal details
        Step(
          // state:
          //     _activeCurrentStep <= 0 ? StepState.editing : StepState.complete,
          isActive: _activeCurrentStep >= 0,
          title: _activeCurrentStep == 0 ? const Text('Applicant') : Text(""),
          content: applicantData(),
        ),
        // This is Step2 here we will enter our address
        Step(
          // state:
          //     _activeCurrentStep <= 1 ? StepState.editing : StepState.complete,
          isActive: _activeCurrentStep >= 1,
          title:
              _activeCurrentStep == 1 ? const Text('Co-Applicant') : Text(""),
          content: checkedValue == false
              ? co_applicantData()
              : sameApplicantCheckBox(),
        ),

        // This is Step3 here we will display all the details
        // that are entered by the user
        Step(
          // state: StepState.complete,
          isActive: _activeCurrentStep >= 2,
          title: _activeCurrentStep == 2 ? const Text('Preference') : Text(""),
          content: preferenceData(),
        )
      ];

  //  ********    plot facing      ********

  void _onCheckboxChanged(String value) {
    setState(() {
      if (_selectedItemsPlotFace.contains(value)) {
        _selectedItemsPlotFace.remove(value);
      } else {
        _selectedItemsPlotFace.add(value);
      }
    });
  }

  Widget applicantData() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image Section
          profileImageApplicant != null
              ? CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(profileImageApplicant!),
                )
              : GestureDetector(
                  onTap: () => showImageSourceOptions("profile1"),
                  child: Column(
                    children: [
                      Icon(Icons.add_a_photo, color: Colors.orange, size: 50),
                      SizedBox(height: 6),
                      Text("Upload Profile Picture",
                          style: TextStyle(color: Colors.orange, fontSize: 14)),
                    ],
                  ),
                ),
          if (_submittedprofile1 && profileImageApplicant == null)
            Text(
              'Profile Photo is required',
              style: TextStyle(color: Colors.red),
            ),

          SizedBox(height: 16),

          // Form Fields
          _buildTextField(nameController, "Name", nameError, nameErrorMessage),
          _buildTextField(
              surNameController, "Surname", surnameError, surnameErrorMessage),
          _buildTextField(relationController, "S/O | D/O | W/O", relationError,
              relationErrorMessage),
          _buildTextField(
              emailController, "Email Address", emailError, emailErrorMessage),
          _buildTextField(
              mobileController, "Mobile", mobileError, mobileErrorMessage),
          _buildTextField(
              addressController, "Address", addressError, addressErrorMessage),
          _buildTextField(cityController, "City", cityError, cityErrorMessage),
          _buildTextField(
              stateController, "State", stateError, stateErrorMessage),
          _buildTextField(nationalityController, "Nationality",
              nationalityError, nationalityErrorMessage),

          // Date Picker
          _buildDatePickerField(context, dobController, dobError,
              dobErrorMessage, () => _selectDate(context)),

          _buildTextField(professionController, "Profession", professionError,
              professionErrorMessage),
          _buildTextField(
              adhaarController, "Aadhaar", adhaarError, adhaarErrorMessage),
          _buildTextField(panController, "PAN", panError, panErrorMessage),

          SizedBox(height: 16),

          // Aadhaar & PAN Upload Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildUploadCard("Aadhaar Card", image1, "aadhaar1"),
                    if (_submittedaadhaar1 && image1 == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Aadhaar is required',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _buildUploadCard("PAN Card", image2, "pan1"),
                    if (_submittedpan1 && image2 == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Pan is required',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Reusable Modern TextField Widget
  Widget _buildTextField(TextEditingController controller, String label,
      bool hasError, String? errorMessage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          errorText: hasError ? errorMessage : null,
        ),
      ),
    );
  }

// Modern Date Picker Field
// Widget _buildDatePickerField(BuildContext context, TextEditingController controller, bool hasError, String? errorMessage) {
//   return GestureDetector(
//     onTap: () => _selectDate(context),
//     child: AbsorbPointer(
//       child: _buildTextField(controller, "Choose Date of Birth", hasError,
//           errorMessage),
//     ),
//   );
// }

  Widget _buildDatePickerField(
      BuildContext context,
      TextEditingController controller,
      bool hasError,
      String? errorMessage,
      Function() onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: "Choose Date of Birth",
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              suffixIcon: Icon(Icons.event, color: Colors.blue),
              errorText: hasError ? errorMessage : null,
            ),
          ),
        ),
      ),
    );
  }

// Modern Upload Card
  Widget _buildUploadCard(String label, File? image, String type) {
    return GestureDetector(
      onTap: () => showImageSourceOptions(type),
      child: Container(
        width: 150,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: appBarGradient, // Apply your gradient
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Transparent background
                  shadowColor: Colors.transparent, // Removes unwanted shadows
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => showImageSourceOptions(type),
                child: Text(label, style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 8),
            image != null
                ? Image.file(image, width: 120, height: 80, fit: BoxFit.cover)
                : Icon(Icons.image, color: Colors.grey, size: 50),
          ],
        ),
      ),
    );
  }

  bool checkedValue = false;

  Widget co_applicantData() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          sameApplicantCheckBox(),
          // Profile Image Section
          profileImageCo != null
              ? CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(profileImageCo!),
                )
              : GestureDetector(
                  onTap: () => showImageSourceOptions("profile2"),
                  child: Column(
                    children: [
                      Icon(Icons.add_a_photo, color: Colors.orange, size: 50),
                      SizedBox(height: 6),
                      Text("Upload Profile Picture",
                          style: TextStyle(color: Colors.orange, fontSize: 14)),
                    ],
                  ),
                ),
          if (_submittedprofile2 && profileImageCo == null)
            Text(
              'Profile Photo is required',
              style: TextStyle(color: Colors.red),
            ),

          SizedBox(height: 16),

          // Form Fields
          _buildTextField(nameControllerPrefer, "Name", nameErrorPrefer,
              nameErrorMessagePrefer),
          _buildTextField(surNameControllerPrefer, "Surname",
              surnameErrorPrefer, surnameErrorMessagePrefer),
          _buildTextField(relationControllerPrefer, "S/O | D/O | W/O",
              relationErrorPrefer, relationErrorMessagePrefer),
          _buildTextField(emailControllerPrefer, "Email Address",
              emailErrorPrefer, emailErrorMessagePrefer),
          _buildTextField(mobileControllerPrefer, "Mobile", mobileErrorPrefer,
              mobileErrorMessagePrefer),
          _buildTextField(addressControllerPrefer, "Address",
              addressErrorPrefer, addressErrorMessagePrefer),
          _buildTextField(cityControllerPrefer, "City", cityErrorPrefer,
              cityErrorMessagePrefer),
          _buildTextField(stateControllerPrefer, "State", stateErrorPrefer,
              stateErrorMessagePrefer),
          _buildTextField(nationalityControllerPrefer, "Nationality",
              nationalityErrorPrefer, nationalityErrorMessagePrefer),

          // Date Picker
          _buildDatePickerField(context, dobControllerPrefer, dobErrorPrefer,
              dobErrorMessagePrefer, () => _selectDatePreference(context)),

          _buildTextField(professionControllerPrefer, "Profession",
              professionErrorPrefer, professionErrorMessagePrefer),
          _buildTextField(adhaarControllerPrefer, "Aadhaar", adhaarErrorPrefer,
              adhaarErrorMessagePrefer),
          _buildTextField(panControllerPrefer, "PAN", panErrorPrefer,
              panErrorMessagePrefer),

          SizedBox(height: 16),

          // Aadhaar & PAN Upload Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildUploadCard("Aadhaar Card", image1Co, "aadhaar2"),
                    if (_submittedaadhaar2 && image1Co == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Aadhaar is required',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _buildUploadCard("PAN Card", image2Co, "pan2"),
                    if (_submittedpan2 && image2Co == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Pan is required',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  preferenceData() {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 30.0,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: DropdownButton<AgentName>(
              isExpanded: true,
              underline: Container(height: 1.2, color: Color(0xFF8E8E8E8E)),
              value: _selectedAgentName,
              hint: Text('Select Advisor Name'),
              onChanged: (AgentName? newValue) {
                setState(() {
                  _selectedAgentName = newValue;
                  _selectedAgentId = newValue!.id;
                });

                print('Selected advisor are: ${newValue!.id}');
              },
              items: _agentname.map<DropdownMenuItem<AgentName>>(
                (AgentName value) {
                  return DropdownMenuItem<AgentName>(
                    value: value,
                    child: Text(value.name),
                  );
                },
              ).toList(),
            ),
          ),
          if (selectedAgentIdError && _selectedAgentId == null)
            Text(
              'Select Advisor Name',
              style: TextStyle(
                color: Colors.red,
              ),
              textAlign: TextAlign.left,
            ),

          //   **************     select advisor dropdown      *******************

          //   **************     payment method dropdown      *******************
          SizedBox(
            height: 30.0,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: DropdownButton<PaymentMode>(
              isExpanded: true,
              underline: Container(height: 1.2, color: Color(0xFF8E8E8E8E)),
              value: _selectedPaymentMode,
              hint: Text('Select Payment Mode'),
              onChanged: (PaymentMode? newValue) {
                setState(() {
                  _selectedPaymentMode = newValue;
                  selectedPaymentModeId = newValue!.id;
                });

                print('Selected Payment mode ids: ${newValue!.id}');
              },
              items: _paymentMode.map<DropdownMenuItem<PaymentMode>>(
                (PaymentMode value) {
                  return DropdownMenuItem<PaymentMode>(
                    value: value,
                    child: Text(value.name),
                  );
                },
              ).toList(),
            ),
          ),
          if (selectedPaymentModeIdError && selectedPaymentModeId == null)
            Text(
              'Select Payment Mode',
              style: TextStyle(
                color: Colors.red,
              ),
              textAlign: TextAlign.left,
            ),

          //   **************     payment method dropdown      *******************

          //   **************     payment plan dropdown      *******************
          SizedBox(
            height: 30.0,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: DropdownButton<PaymentPlan>(
              isExpanded: true,
              underline: Container(height: 1.2, color: Color(0xFF8E8E8E8E)),
              value: _selectedPaymentPlan,
              hint: Text('Select Payment Plan'),
              onChanged: (PaymentPlan? newValue) {
                setState(() {
                  _selectedPaymentPlan = newValue;
                  selectedPaymentPlanId = newValue!.id;
                });

                print('Selected Payment plan ids: ${newValue!.id}');
              },
              items: _paymentPlan.map<DropdownMenuItem<PaymentPlan>>(
                (PaymentPlan value) {
                  return DropdownMenuItem<PaymentPlan>(
                    value: value,
                    child: Text(value.name),
                  );
                },
              ).toList(),
            ),
          ),
          if (selectedPaymentPlanIdError && selectedPaymentPlanId == null)
            Text(
              'Select Payment Plan',
              style: TextStyle(
                color: Colors.red,
              ),
              textAlign: TextAlign.left,
            ),

          //   **************     payment plan dropdown      *******************

          //   **************     select form type dropdown      *******************
          SizedBox(
            height: 30.0,
          ),

          //   **************     select form type dropdown      *******************
          Container(
            width: MediaQuery.of(context).size.width,
            child: DropdownButton<FormType>(
              isExpanded: true,
              underline: Container(height: 1.2, color: Color(0xFF8E8E8E8E)),
              value: _selectedFormType,
              hint: Text('Select Form Type'),
              onChanged: (FormType? newValue) {
                setState(() {
                  _selectedFormType = newValue;
                  _selectedFormTypeName = newValue!.name;
                  _selectedFormTypeId = newValue!.id;
                });

                print('Selected form type id: ${newValue!.id}');
              },
              items: _formType.map<DropdownMenuItem<FormType>>(
                (FormType value) {
                  return DropdownMenuItem<FormType>(
                    value: value,
                    child: Text(value.name),
                  );
                },
              ).toList(),
            ),
          ),
          if (selectedFormTypeNameError && _selectedFormTypeName == null)
            Text(
              'Select Form Type Name',
              style: TextStyle(
                color: Colors.red,
              ),
              textAlign: TextAlign.left,
            ),

          SizedBox(
            height: 30.0,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: DropdownButton<PlotSize>(
              isExpanded: true,
              underline: Container(height: 1.2, color: Color(0xFF8E8E8E8E)),
              value: _selectedPlotSize,
              hint: Text('Select Plot Size'),
              onChanged: (PlotSize? newValue) {
                setState(() {
                  _selectedPlotSize = newValue;
                  selectedPlotSizeIds = newValue!.id;
                });

                print('Selected plot size ids: ${newValue!.id}');
              },
              items: _plotSizes.map<DropdownMenuItem<PlotSize>>(
                (PlotSize value) {
                  return DropdownMenuItem<PlotSize>(
                    value: value,
                    child: Text(value.name),
                  );
                },
              ).toList(),
            ),
          ),
          if (selectedPlotSizeIdsError && selectedPlotSizeIds == null)
            Text(
              'Select Plot Size',
              style: TextStyle(
                color: Colors.red,
              ),
              textAlign: TextAlign.left,
            ),

          //   **************     number of apps dropdown      *******************

          SizedBox(
            height: 30.0,
          ),
          DropdownButton<int>(
            isExpanded: true,
            underline: Container(height: 1.2, color: Color(0xFF8E8E8E8E)),
            value: numberOfApps,
            onChanged: (int? newValue) {
              setState(() {
                numberOfApps = newValue ?? 0;
                print('number of apps are: $numberOfApps');
              });
            },
            items: _itemsNumberofApps.map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),

          //   **************     number of apps dropdown      *******************

          //   **************     select  plot facing dropdown      *******************
          SizedBox(
            height: 30.0,
          ),
          SizedBox(
            height: 30.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Plot Facing'),
              for (var plotFacing in _plotFacings)
                CheckboxListTile(
                  title: Text(plotFacing.name),
                  value: _selectedPlotFacings.contains(plotFacing),
                  onChanged: (value) => togglePlotFacing(plotFacing),
                ),
            ],
          ),
          if (selectedPlotFacingIdsError && selectedPlotFacingIds.isEmpty)
            Text(
              'Select Plot Facing',
              style: TextStyle(
                color: Colors.red,
              ),
              textAlign: TextAlign.left,
            ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  CheckboxListTile sameApplicantCheckBox() {
    return CheckboxListTile(
      title: Text("Same as Applicant"),
      value: checkedValue,
      onChanged: (newValue) {
        setState(() {
          checkedValue = newValue!;
          print(checkedValue);
        });
      },
      controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: myKeyApplication,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Text(
              'Create Application',
              style: appThemeTextWhiteC,
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: appBarGradient,
              ),
            ),
          ),
          body: Stepper(
            type: StepperType.horizontal,
            currentStep: _activeCurrentStep,
            steps: stepList(),
            controlsBuilder: (context, _) {
              return Row(
                children: <Widget>[
                  Expanded(
                      flex: 6,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(orangeC)),
                        onPressed: () {
                          print(1);
                          if (myKeyApplication.currentState!.validate()) {
                            print(">>> current step is $_activeCurrentStep");
                            if (_validateAllFields()) {
                              if (_activeCurrentStep == 1) {
                                if (_validateCoFields()) {
                                  setState(() {
                                    _activeCurrentStep += 1;
                                  });
                                }
                              } else if (_activeCurrentStep == 2) {
                                if (_validateCoFields()) {
                                  if (_validatePrefields()) {
                                    applicationCreate();
                                  }
                                } else {
                                  Utils.flushBarErrorMessage(
                                      'Please Fill Co-Applicant Fields',
                                      context);
                                }
                              } else if (_activeCurrentStep <
                                  (stepList().length - 1)) {
                                setState(() {
                                  _activeCurrentStep += 1;
                                });
                              }
                            } else {
                              Utils.flushBarErrorMessage(
                                  'Please Fill Applicant Fields', context);
                            }
                          }
                        },
                        child: const Text('CONTINUE'),
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      flex: 3,
                      child: OutlinedButton(
                        onPressed: () {
                          if (_activeCurrentStep == 0) {
                            Navigator.pop(context);
                            return;
                          }

                          setState(() {
                            _activeCurrentStep -= 1;
                          });
                        },
                        child: const Text('BACK'),
                      )),
                ],
              );
            },
            // onStepContinue takes us to the next step
            onStepContinue: () {
              print(1);
              if (myKeyApplication.currentState!.validate()) {
                print(">>> current step is $_activeCurrentStep");
                if (_validateAllFields()) {
                  if (_activeCurrentStep == 1) {
                    if (_validateCoFields()) {
                      setState(() {
                        _activeCurrentStep += 1;
                      });
                    }
                  } else if (_activeCurrentStep == 2) {
                    if (_validateCoFields()) {
                      if (_validatePrefields()) {
                        applicationCreate();
                      }
                    } else {
                      Utils.flushBarErrorMessage(
                          'Please Fill Co-Applicant Fields', context);
                    }
                  } else if (_activeCurrentStep < (stepList().length - 1)) {
                    setState(() {
                      _activeCurrentStep += 1;
                    });
                  }
                } else {
                  Utils.flushBarErrorMessage(
                      'Please Fill Applicant Fields', context);
                }
              }
            },

            // onStepCancel takes us to the previous step
            onStepCancel: () {
              if (_activeCurrentStep == 0) {
                Navigator.pop(context);
                return;
              }

              setState(() {
                _activeCurrentStep -= 1;
              });
            },

            // onStepTap allows to directly click on the particular step we want
            onStepTapped: (int index) {
              setState(() {
                print(_activeCurrentStep);
                _activeCurrentStep = index;
              });
            },
          ),
        ));
  }

  void showImageSourceOptions(String where) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                if (where == "aadhaar1") {
                  pickImage1(ImageSource.camera);
                } else if (where == "pan1") {
                  pickImage2(ImageSource.camera);
                } else if (where == "aadhaar2") {
                  pickImage1Co(ImageSource.camera);
                } else if (where == "pan2") {
                  pickImage2Co(ImageSource.camera);
                } else if (where == "profile1") {
                  pickprofileImage(1, ImageSource.camera);
                } else if (where == "profile2") {
                  pickprofileImage(2, ImageSource.camera);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                if (where == "aadhaar1") {
                  pickImage1(ImageSource.gallery);
                } else if (where == "pan1") {
                  pickImage2(ImageSource.gallery);
                } else if (where == "aadhaar2") {
                  pickImage1Co(ImageSource.gallery);
                } else if (where == "pan2") {
                  pickImage2Co(ImageSource.gallery);
                } else if (where == "profile1") {
                  pickprofileImage(1, ImageSource.gallery);
                } else if (where == "profile2") {
                  pickprofileImage(2, ImageSource.gallery);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future pickprofileImage(int forUser, ImageSource source) async {
    if (forUser == 1) {
      final pickedProfileImageApplicant = await _imageProfilePickerApplicant
          .pickImage(source: source, imageQuality: 80);

      if (pickedProfileImageApplicant != null) {
        profileImageApplicant = File(pickedProfileImageApplicant.path);
        setState(() {
          profileImageApplicant;
        });
        uploadProfileImage(forUser);
        print('image 1 path $profileImageApplicant');
      } else {
        print('no image selected');
      }
    } else {
      final pickedProfileImageCo = await _imageProfilePickerCo.pickImage(
          source: source, imageQuality: 80);

      if (pickedProfileImageCo != null) {
        profileImageCo = File(pickedProfileImageCo.path);
        setState(() {
          profileImageCo;
        });
        uploadProfileImage(forUser);
        print('image 1 path $profileImageCo');
      } else {
        print('no image selected');
      }
    }
  }

  Future pickImage1(ImageSource source) async {
    final pickedFile1 =
        await _imagePicker1.pickImage(source: source, imageQuality: 80);

    if (pickedFile1 != null) {
      image1 = File(pickedFile1.path);
      setState(() {
        image1;
      });
      uploadAdhaarCard(1);
      print('image 1 path $image1');
    } else {
      print('no image selected');
    }
  }

  Future pickImage1Co(ImageSource source) async {
    final pickedFile1Co =
        await _imagePicker1Co.pickImage(source: source, imageQuality: 80);

    if (pickedFile1Co != null) {
      image1Co = File(pickedFile1Co.path);
      setState(() {
        image1Co;
      });
      uploadAdhaarCard(2);
      print('image 1 path $image1Co');
    } else {
      print('no image selected');
    }
  }

  Future pickImage2(ImageSource source) async {
    final pickedFile2 =
        await _imagePicker2.pickImage(source: source, imageQuality: 80);

    if (pickedFile2 != null) {
      image2 = File(pickedFile2.path);
      uploadPanCard(1);
      setState(() {
        image2;
      });
    } else {
      print('no image selected');
    }
  }

  Future pickImage2Co(ImageSource source) async {
    final pickedFile2Co =
        await _imagePicker2Co.pickImage(source: source, imageQuality: 80);

    if (pickedFile2Co != null) {
      image2Co = File(pickedFile2Co.path);
      uploadPanCard(2);
      setState(() {
        image2Co;
      });
    } else {
      print('no image selected');
    }
  }

  Future pickPreferenceImage() async {
    final preferenceFile = await _imagePicker2.pickImage(
        source: ImageSource.gallery, imageQuality: 80);

    if (preferenceFile != null) {
      ImagePreference = File(preferenceFile.path);
      setState(() {});
    } else {
      print('no image selected');
    }
  }

  getPreferences() async {
    // setState(() {
    //   showSpinner = true;
    // });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    String url = AppUrl.getPreferences;

    final response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      // setState(() {
      //   showSpinner = false;
      // });

      var parsedJson = json.decode(response.body);
      List<dynamic> plotSizeList = parsedJson['data']['plotSize'];
      List<dynamic> plotFaceList = parsedJson['data']['plotFacing'];
      List<dynamic> paymentModeList = parsedJson['data']['paymentMode'];
      List<dynamic> paymentPlan = parsedJson['data']['paymentPlan'];
      List<dynamic> agentNameList = parsedJson['data']['agent'];
      List<dynamic> formTypeList = parsedJson['data']['formType'];

      // xee code ************* for ids and name of form type ***********
      final List<dynamic> formTypeLists = parsedJson["data"]['formType'];
      setState(() {
        _formType =
            formTypeLists.map((json) => FormType.fromJson(json)).toList();
      });

//  *********   for ids and name  agent name  **************

      final List<dynamic> agentName = parsedJson["data"]['agent'];
      setState(() {
        _agentname = agentName.map((json) => AgentName.fromJson(json)).toList();
      });

      //  *********   for ids and name  plot size  **************
//  *********   for ids and name payment mode  **************

      final List<dynamic> paymentMode = parsedJson["data"]['paymentMode'];
      setState(() {
        _paymentMode =
            paymentMode.map((json) => PaymentMode.fromJson(json)).toList();
      });

//  *********   for ids and name payment mode  **************

      //  *********   for ids and name  plot size  **************

      final List<dynamic> plotSizeLists = parsedJson["data"]['plotSize'];
      setState(() {
        _plotSizes =
            plotSizeLists.map((json) => PlotSize.fromJson(json)).toList();
      });

      //  *********   for ids and name  plot size  **************
      //  *********   for ids and paymetn plan  **************

      final List<dynamic> paymentPlanList = parsedJson["data"]['paymentPlan'];
      setState(() {
        _paymentPlan =
            paymentPlanList.map((json) => PaymentPlan.fromJson(json)).toList();
      });

      //  *********    for ids and paymetn plan **************
      //  *********   for ids and plot facing  **************

      final List<dynamic> plotFacingList = parsedJson["data"]['plotFacing'];
      setState(() {
        _plotFacings =
            plotFacingList.map((json) => PlotFacing.fromJson(json)).toList();
      });

      //  *********    for ids and plot facing **************

      List<String> names =
          plotSizeList.map<String>((item) => item['name']).toList();

      List<String> plotFaceNames =
          plotFaceList.map<String>((item) => item['name']).toList();

      List<String> paymentPlanName =
          paymentPlan.map<String>((item) => item['name']).toList();

      print('agent name: $agentName');

      setState(() {
        _checkboxItemsPlotFace = plotFaceNames;

        _dropdownItems = names;
        _selectedItem =
            _dropdownItems.isNotEmpty ? _dropdownItems[0] : 'Plot Size';

        _dropdownItemsPaymentPlan = paymentPlanName;
        _selectedItemPaymentPlan = _dropdownItemsPaymentPlan.isNotEmpty
            ? _dropdownItemsPaymentPlan[0]
            : 'Payment Plan';
      });

      // }
    } else {
      print("Preferences status code: ${response.statusCode}");
    }
  }

  void togglePlotFacing(PlotFacing plotFacing) {
    setState(() {
      if (_selectedPlotFacings.contains(plotFacing)) {
        _selectedPlotFacings.remove(plotFacing);
      } else {
        _selectedPlotFacings.add(plotFacing);
      }
    });

    _selectedPlotFacings.forEach((plotFacing) => print(plotFacing.id));

    if (selectedPlotFacingIds.contains(plotFacing.id)) {
      selectedPlotFacingIds.remove(plotFacing.id);
    } else {
      selectedPlotFacingIds.add(plotFacing.id);
    }
    print('Selected Plot Facing IDs: $selectedPlotFacingIds');
  }

  uploadProfileImage(int forUser) async {
    if (forUser == 1) {
      setState(() {
        showSpinner = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      var stream = http.ByteStream(
          DelegatingStream.typed(profileImageApplicant!.openRead()));
      // get file length
      var length =
          await profileImageApplicant!.length(); //imageFile is your image file
      Map<String, String> headers = {
        // "Accept": "application/json",
        "Authorization": "Bearer " + accessToken!
      }; // ignore this headers if there is no authentication

      // string to uri
      var uri = Uri.parse(AppUrl.uploadApplicationFiles);

      // create multipart request
      var request = http.MultipartRequest("POST", uri);

      request.fields['avatar'] = profileImageApplicant.toString();

      // multipart that takes file
      var multipartFileSign = http.MultipartFile('avatar', stream, length,
          filename: pth.basename(profileImageApplicant!.path));

      // add file to multipart
      request.files.add(multipartFileSign);

      //add headers
      request.headers.addAll(headers);

      // send
      var response = await request.send();
      print('response line number 1499: $response');
      setState(() {
        showSpinner = false;
      });

      print(response.statusCode);
      // listen for response
      response.stream.transform(utf8.decoder).listen((value1) {
        print(value1);
        final jsonDataAvatar = json.decode(value1);
        print(jsonDataAvatar);
        print(jsonDataAvatar["data"]["url"]);
        print('line number 1507: ${jsonDataAvatar["data"]["url"]}');
        finalProfileUrl = jsonDataAvatar["data"]["url"];
        print("final profile url is $finalProfileUrl");

        setState(() {
          jsonDataAvatar;
          finalProfileUrl;
        });
      });
    } else {
      setState(() {
        showSpinner = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      var stream =
          http.ByteStream(DelegatingStream.typed(profileImageCo!.openRead()));
      // get file length
      var length =
          await profileImageCo!.length(); //imageFile is your image file
      Map<String, String> headers = {
        // "Accept": "application/json",
        "Authorization": "Bearer " + accessToken!
      }; // ignore this headers if there is no authentication

      // string to uri
      var uri = Uri.parse(AppUrl.uploadApplicationFiles);

      // create multipart request
      var request = http.MultipartRequest("POST", uri);

      request.fields['ca_avatar'] = profileImageCo.toString();

      // multipart that takes file
      var multipartFileSign = http.MultipartFile('ca_avatar', stream, length,
          filename: pth.basename(profileImageCo!.path));

      // add file to multipart
      request.files.add(multipartFileSign);

      //add headers
      request.headers.addAll(headers);

      // send
      var response = await request.send();
      print('response line number 1499: $response');
      setState(() {
        showSpinner = false;
      });

      print(response.statusCode);
      // listen for response
      response.stream.transform(utf8.decoder).listen((value1) {
        print(value1);
        final jsonDataAvatar = json.decode(value1);
        print(jsonDataAvatar);
        print(jsonDataAvatar["data"]["url"]);
        print('line number 1507: ${jsonDataAvatar["data"]["url"]}');
        finalProfileUrlCo = jsonDataAvatar["data"]["url"];
        print("final profile url is $finalProfileUrlCo");

        setState(() {
          jsonDataAvatarCo;
          finalProfileUrlCo;
        });
      });
    }
  }

  uploadAdhaarCard(int forUser) async {
    setState(() {
      showSpinner = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    if (forUser == 1) {
      var stream = http.ByteStream(DelegatingStream.typed(image1!.openRead()));
      // get file length
      var length = await image1!.length(); //imageFile is your image file
      Map<String, String> headers = {
        // "Accept": "application/json",
        "Authorization": "Bearer " + accessToken!
      }; // ignore this headers if there is no authentication

      // string to uri
      var uri = Uri.parse(AppUrl.uploadApplicationFiles);

      // create multipart request
      var request = http.MultipartRequest("POST", uri);

      request.fields['adhaar'] = image1.toString();

      // multipart that takes file
      var multipartFileSign = http.MultipartFile('adhaar', stream, length,
          filename: pth.basename(image1!.path));

      // add file to multipart
      request.files.add(multipartFileSign);

      //add headers
      request.headers.addAll(headers);

      // send
      var response = await request.send();
      print('response line number 1560: $response');
      setState(() {
        showSpinner = false;
      });

      print(response.statusCode);
      // listen for response
      response.stream.transform(utf8.decoder).listen((value1) {
        print(value1);
        jsonDataAdhaar = json.decode(value1);
        print('line number 1570: ${jsonDataAdhaar["data"]["url"]}');
        finalAdhaarUrl = jsonDataAdhaar["data"]["url"];
        print("final adhar url is : " + finalAdhaarUrl.toString());
        setState(() {
          jsonDataAdhaar;
          finalAdhaarUrl;
        });
      });
    } else {
      var stream =
          http.ByteStream(DelegatingStream.typed(image1Co!.openRead()));
      // get file length
      var length = await image1Co!.length(); //imageFile is your image file
      Map<String, String> headers = {
        // "Accept": "application/json",
        "Authorization": "Bearer " + accessToken!
      }; // ignore this headers if there is no authentication

      // string to uri
      var uri = Uri.parse(AppUrl.uploadApplicationFiles);

      // create multipart request
      var request = http.MultipartRequest("POST", uri);

      request.fields['adhaar'] = image1Co.toString();

      // multipart that takes file
      var multipartFileSign = http.MultipartFile('adhaar', stream, length,
          filename: pth.basename(image1Co!.path));

      // add file to multipart
      request.files.add(multipartFileSign);

      //add headers
      request.headers.addAll(headers);

      // send
      var response = await request.send();
      print('response line number 1560: $response');
      setState(() {
        showSpinner = false;
      });

      print(response.statusCode);
      // listen for response
      response.stream.transform(utf8.decoder).listen((value1) {
        print(value1);
        jsonDataAdhaarCo = json.decode(value1);
        print('line number 1570: ${jsonDataAdhaarCo["data"]["url"]}');
        finalAdhaarUrlCo = jsonDataAdhaarCo["data"]["url"];
        setState(() {
          jsonDataAdhaarCo;
          finalAdhaarUrlCo;
        });
      });
    }
  }

  uploadPanCard(int forUser) async {
    setState(() {
      showSpinner = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    if (forUser == 1) {
      var stream = http.ByteStream(DelegatingStream.typed(image2!.openRead()));
      // get file length
      var length = await image2!.length(); //imageFile is your image file
      Map<String, String> headers = {
        // "Accept": "application/json",
        "Authorization": "Bearer " + accessToken!
      }; // ignore this headers if there is no authentication

      // string to uri
      var uri = Uri.parse(AppUrl.uploadApplicationFiles);

      // create multipart request
      var request = http.MultipartRequest("POST", uri);

      request.fields['pan'] = image2.toString();

      // multipart that takes file
      var multipartFileSign = http.MultipartFile('pan', stream, length,
          filename: pth.basename(image2!.path));

      // add file to multipart
      request.files.add(multipartFileSign);

      //add headers
      request.headers.addAll(headers);

      // send
      var response = await request.send();
      print('response line number 1560: $response');
      setState(() {
        showSpinner = false;
      });

      print(response.statusCode);
      // listen for response
      response.stream.transform(utf8.decoder).listen((value1) {
        print(value1);
        jsonDataPan = json.decode(value1);
        print('line number 1570: ${jsonDataPan["data"]["url"]}');
        finalPanUrl = jsonDataPan["data"]["url"];
        print("final pan url is : " + finalPanUrl.toString());
        setState(() {
          jsonDataPan;
          finalPanUrl;
        });
      });
    } else {
      var stream =
          http.ByteStream(DelegatingStream.typed(image2Co!.openRead()));
      // get file length
      var length = await image2Co!.length(); //imageFile is your image file
      Map<String, String> headers = {
        // "Accept": "application/json",
        "Authorization": "Bearer " + accessToken!
      }; // ignore this headers if there is no authentication

      // string to uri
      var uri = Uri.parse(AppUrl.uploadApplicationFiles);

      // create multipart request
      var request = http.MultipartRequest("POST", uri);

      request.fields['pan'] = image2Co.toString();

      // multipart that takes file
      var multipartFileSign = http.MultipartFile('pan', stream, length,
          filename: pth.basename(image2Co!.path));

      // add file to multipart
      request.files.add(multipartFileSign);

      //add headers
      request.headers.addAll(headers);

      // send
      var response = await request.send();
      print('response line number 1560: $response');
      setState(() {
        showSpinner = false;
      });

      print(response.statusCode);
      // listen for response
      response.stream.transform(utf8.decoder).listen((value1) {
        print(value1);
        jsonDataPanCo = json.decode(value1);
        print('line number 1570: ${jsonDataPanCo["data"]["url"]}');
        finalPanUrlCo = jsonDataPanCo["data"]["url"];
        setState(() {
          jsonDataPanCo;
          finalPanUrlCo;
        });
      });
    }
  }

  applicationCreate() async {
    setState(() {
      showSpinner = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    // print('token from register 168 $token');
    String url = AppUrl.applicationCreate;
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
              Text("Submitting Application..."),
            ],
          ),
        );
      },
    );

    final response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    }, body: {
      "project_id": widget.projectId.toString(),
      "same_as_applicant": checkedValue ? "1" : "0",
      "avatar": finalProfileUrl ?? "",
      "name": nameController.text.trim().toString(),
      "surname": surNameController.text.trim().toString(),
      "sonof": relationController.text.trim().toString(),
      "email": emailController.text.trim().toString(),
      "mobile": mobileController.text.trim().toString(),
      "address": addressController.text.trim().toString(),
      "city": cityController.text.trim().toString(),
      "state": stateController.text.trim().toString(),
      "nationality": nationalityController.text.trim().toString(),
      "dob": dobController.text.trim().toString(),
      "profession": professionController.text.trim().toString(),
      "adhaar": adhaarController.text.trim().toString(),
      "pan": panController.text.trim().toString(),
      "adhaar_file": finalAdhaarUrl ?? "",
      "pan_file": finalPanUrl ?? "",

      //    ********       co     ***********
      "ca_avatar": finalProfileUrlCo ?? "",
      "ca_name": nameControllerPrefer.text.trim().toString(),
      "ca_surname": surNameControllerPrefer.text.trim().toString(),
      "ca_sonof": relationControllerPrefer.text.trim().toString(),
      "ca_email": emailControllerPrefer.text.trim().toString(),
      "ca_mobile": mobileControllerPrefer.text.trim().toString(),
      "ca_address": addressControllerPrefer.text.trim().toString(),
      "ca_city": cityControllerPrefer.text.trim().toString(),
      "ca_state": stateControllerPrefer.text.trim().toString(),
      "ca_nationality": nationalityControllerPrefer.text.trim().toString(),
      "ca_dob": dobControllerPrefer.text.trim().toString(),
      "ca_profession": professionControllerPrefer.text.trim().toString(),
      "ca_adhaar_file": finalAdhaarUrlCo ?? "",
      "ca_adhaar": adhaarControllerPrefer.text.trim().toString(),
      "ca_pan_file": finalPanUrlCo ?? "",
      "ca_pan": panControllerPrefer.text.trim().toString(),
      //    ********       preferences     ***********

      "selected_advisor": _selectedAgentId.toString() == "null"
          ? ""
          : _selectedAgentId.toString(),
      "selected_plot_size": selectedPlotSizeIds.toString() == "null"
          ? ""
          : selectedPlotSizeIds.toString(),
      "selected_plot_facing":
          selectedPlotFacingIds.isEmpty ? "" : selectedPlotFacingIds.toString(),
      "selected_form_type": _selectedFormTypeName.toString() == "null"
          ? ""
          : _selectedFormTypeName.toString(),
      "selected_payment_plan": selectedPaymentPlanId.toString() == "null"
          ? ""
          : selectedPaymentPlanId.toString(),
      "selected_payment_mode": selectedPaymentModeId.toString() == "null"
          ? ""
          : selectedPaymentModeId.toString(),
      "no_of_app": numberOfApps.toString(),
      "additional_info": "nothing"
    });
    Navigator.pop(context);

    print("response.statusCode ${response.statusCode}");
    var jsonData = json.decode(response.body);
    print(">>> response body create application page ${jsonData}");

    if (response.statusCode == 200) {
      setState(() {
        showSpinner = false;
      });

      if (jsonData["success"] == true) {
        Utils.flushBarSuccessMessage(
            'Application Created Successfully', context);
        Timer(Duration(seconds: 1), () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => PaymentScreen(
                        item: '',
                      )),
              (Route<dynamic> route) => false);
        });
      } else {
        Utils.flushBarErrorMessage("Something went wrong", context);
      }
    } else if (response.statusCode == 400) {
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
    } else if (response.statusCode == 422) {
      if (jsonData["success"] == false) {
        print(jsonData["errors"][0].runtimeType);
        Utils.flushBarErrorMessage(jsonData["errors"][0].toString(), context);
      } else {
        Utils.flushBarErrorMessage("All fields are required", context);
      }
    } else if (response.statusCode == 500) {
      print(response.body.toString());
    } else {
      setState(() {
        showSpinner = false;
      });
      Utils.flushBarErrorMessage("Submission failed. Please check details.", context);
    }
  }
}
