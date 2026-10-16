import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as pth;
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/colors.dart';
import '../Utils/utils.dart';
import '../res/app_urls.dart';
import 'Drawer/payment_screen.dart';

class ApplicantFormScreen extends StatefulWidget {
  final int? projectId;

  const ApplicantFormScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  State<ApplicantFormScreen> createState() => _ApplicantFormScreenState();
}

class _ApplicantFormScreenState extends State<ApplicantFormScreen>
    with SingleTickerProviderStateMixin {
  // 0: Personal Identity, 1: Address & Location, 2: Biometric KYC Vault
  int _currentStep = 0;
  bool _isLoading = false;
  String _loadingMessage = 'Securing application data...';

  final ImagePicker _picker = ImagePicker();

  // ---------------- ULTRA LUXURY PALETTE ----------------
  static const Color luxuryGold = Color(0xFFD4AF37);
  static const Color brightGold = Color(0xFFF3C759);
  static const Color deepGold = Color(0xFFAA8012);
  static const Color obsidianBlack = Color(0xFF090D16);
  static const Color deepNavySlate = Color(0xFF0F172A);
  static const Color slateCard = Color(0xFF1E293B);
  static const Color surfacePure = Color(0xFFF8FAFC);
  static const Color inputBg = Color(0xFFF1F5F9);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color emeraldVerified = Color(0xFF10B981);
  static const Color sapphireAccent = Color(0xFF2563EB);

  // ---------------- STEP 0: APPLICANT IDENTITY ----------------
  File? _avatarImage;
  String? _avatarRemoteUrl;

  final TextEditingController _fullNameController = TextEditingController();
  String _relationType = 'S/O'; // 'S/O', 'W/O', 'D/O'
  final TextEditingController _relativeNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _altPhoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _anniversaryController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _nationalityController =
      TextEditingController(text: 'Indian');

  final List<Map<String, dynamic>> _quickOccupations = [
    {'title': 'Salaried', 'icon': Icons.business_center_rounded},
    {'title': 'Business Owner', 'icon': Icons.storefront_rounded},
    {'title': 'Professional (CA/Law)', 'icon': Icons.gavel_rounded},
    {'title': 'IT & Tech', 'icon': Icons.terminal_rounded},
    {'title': 'Govt. Service', 'icon': Icons.account_balance_rounded},
    {'title': 'Doctor / Medical', 'icon': Icons.health_and_safety_rounded},
    {'title': 'Self-Employed', 'icon': Icons.workspace_premium_rounded},
  ];

  // ---------------- STEP 1: RESIDENCE ADDRESS ----------------
  String _addressType = 'Permanent Home'; // Permanent Home, Office, Rental
  final TextEditingController _addressController = TextEditingController();
  String? _selectedState;
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  final List<String> _popularCities = [
    'Gurugram',
    'New Delhi',
    'Noida',
    'Faridabad',
    'Ghaziabad',
    'Jaipur',
    'Chandigarh',
    'Mumbai',
    'Bengaluru',
  ];

  final List<String> _indianStates = [
    'Delhi',
    'Haryana',
    'Uttar Pradesh',
    'Rajasthan',
    'Punjab',
    'Maharashtra',
    'Gujarat',
    'Madhya Pradesh',
    'Bihar',
    'West Bengal',
    'Karnataka',
    'Tamil Nadu',
    'Telangana',
    'Andhra Pradesh',
    'Kerala',
    'Uttarakhand',
    'Himachal Pradesh',
    'Jammu and Kashmir',
    'Goa',
    'Odisha',
    'Assam',
    'Chandigarh',
    'Jharkhand',
    'Chhattisgarh',
  ];

  // ---------------- STEP 2: BIOMETRIC KYC VAULT ----------------
  final TextEditingController _aadhaarNumberController =
      TextEditingController();
  File? _aadhaarFrontImage;
  String? _aadhaarFrontRemoteUrl;
  File? _aadhaarBackImage;
  String? _aadhaarBackRemoteUrl;

  final TextEditingController _panNumberController = TextEditingController();
  File? _panCardImage;
  String? _panCardRemoteUrl;

  bool _declarationAccepted = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfilePrefill();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _relativeNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _dobController.dispose();
    _anniversaryController.dispose();
    _occupationController.dispose();
    _nationalityController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    _landmarkController.dispose();
    _aadhaarNumberController.dispose();
    _panNumberController.dispose();
    super.dispose();
  }

  // Auto-prefill existing user data
  Future<void> _fetchUserProfilePrefill() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      if (accessToken == null) return;

      final response = await http.post(
        Uri.parse(AppUrl.getProfile),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final user = data['data'];
          if (mounted) {
            setState(() {
              if (_fullNameController.text.isEmpty && user['name'] != null) {
                _fullNameController.text = user['name'].toString();
              }
              if (_emailController.text.isEmpty && user['email'] != null) {
                _emailController.text = user['email'].toString();
              }
              if (_phoneController.text.isEmpty && user['mobile'] != null) {
                _phoneController.text = user['mobile'].toString();
              }
              if (_addressController.text.isEmpty && user['address'] != null) {
                _addressController.text = user['address'].toString();
              }
              if (_cityController.text.isEmpty && user['city'] != null) {
                _cityController.text = user['city'].toString();
              }
              if (_selectedState == null && user['state'] != null) {
                if (_indianStates.contains(user['state'].toString())) {
                  _selectedState = user['state'].toString();
                }
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Prefill error: $e');
    }
  }

  // Calculate age string from DOB
  String _getAgeString() {
    if (_dobController.text.isEmpty) return '';
    try {
      final parsed = DateFormat('dd MMM yyyy').parse(_dobController.text);
      final now = DateTime.now();
      int age = now.year - parsed.year;
      if (now.month < parsed.month ||
          (now.month == parsed.month && now.day < parsed.day)) {
        age--;
      }
      return '$age yrs';
    } catch (_) {
      return '';
    }
  }

  // Format Aadhaar display with spaces
  String _formatAadhaarDisplay(String raw) {
    String clean = raw.replaceAll(RegExp(r'\s+'), '');
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('  ');
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }

  // Ultra-Luxury Stylish & Gentle Date Picker
  Future<void> _pickDate({
    required TextEditingController controller,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String title = 'Select Date',
    bool isDob = false,
  }) async {
    DateTime tempDate = initialDate;
    if (controller.text.trim().isNotEmpty) {
      try {
        tempDate = DateFormat('dd MMM yyyy').parse(controller.text.trim());
      } catch (_) {
        try {
          tempDate = DateTime.parse(controller.text.trim());
        } catch (_) {}
      }
    }
    if (tempDate.isBefore(firstDate)) tempDate = firstDate;
    if (tempDate.isAfter(lastDate)) tempDate = lastDate;

    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (BuildContext dialogContext) {
        DateTime selected = tempDate;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String ageSnippet = '';
            if (isDob) {
              final now = DateTime.now();
              int age = now.year - selected.year;
              if (now.month < selected.month ||
                  (now.month == selected.month && now.day < selected.day)) {
                age--;
              }
              if (age >= 0) ageSnippet = '$age Years Old';
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      border: Border.all(
                        color: luxuryGold.withOpacity(0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Gentle Luxury Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 18),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                deepNavySlate,
                                Color(0xFF1E293B),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: luxuryGold.withOpacity(0.18),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_month_rounded,
                                          color: brightGold,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        title.toUpperCase(),
                                        style: const TextStyle(
                                          color: brightGold,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (ageSnippet.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color:
                                            emeraldVerified.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color:
                                              emeraldVerified.withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        ageSnippet,
                                        style: const TextStyle(
                                          color: Color(0xFF6EE7B7),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                DateFormat('EEEE, dd MMMM yyyy').format(selected),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isDob
                                    ? 'Tap the year above to jump decades easily'
                                    : 'Select official verification date',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Interactive Gentle Calendar
                        Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: deepNavySlate,
                              onPrimary: brightGold,
                              surface: Colors.white,
                              onSurface: textDark,
                            ),
                            datePickerTheme: DatePickerThemeData(
                              headerBackgroundColor: deepNavySlate,
                              headerForegroundColor: Colors.white,
                              dayStyle: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                              dayBackgroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return deepNavySlate;
                                }
                                return null;
                              }),
                              dayForegroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return brightGold;
                                }
                                return textDark;
                              }),
                              todayForegroundColor:
                                  WidgetStateProperty.all(deepGold),
                              todayBorder: const BorderSide(
                                  color: luxuryGold, width: 1.5),
                              yearStyle: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                              yearBackgroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return deepNavySlate;
                                }
                                return null;
                              }),
                              yearForegroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return brightGold;
                                }
                                return textDark;
                              }),
                            ),
                          ),
                          child: SizedBox(
                            height: 330,
                            child: CalendarDatePicker(
                              initialDate: selected,
                              firstDate: firstDate,
                              lastDate: lastDate,
                              initialCalendarMode: isDob
                                  ? DatePickerMode.year
                                  : DatePickerMode.day,
                              onDateChanged: (DateTime newDate) {
                                setDialogState(() {
                                  selected = newDate;
                                });
                              },
                            ),
                          ),
                        ),

                        const Divider(height: 1, color: borderLight),

                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          child: Row(
                            children: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, null),
                                style: TextButton.styleFrom(
                                  foregroundColor: textSecondary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [brightGold, deepGold],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: luxuryGold.withOpacity(0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 22, vertical: 11),
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, selected),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle_rounded,
                                          color: deepNavySlate, size: 17),
                                      SizedBox(width: 6),
                                      Text(
                                        'Confirm Date',
                                        style: TextStyle(
                                          color: deepNavySlate,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
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
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  // Luxury Image Picker Bottom Sheet
  void _showImagePickerSheet(Function(File) onImageSelected, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [brightGold, deepGold],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.document_scanner_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Upload original government document',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          Navigator.pop(ctx);
                          final XFile? file = await _picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 85,
                            maxWidth: 1600,
                          );
                          if (file != null) {
                            onImageSelected(File(file.path));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.camera_alt_rounded,
                                  size: 32, color: brightGold),
                              SizedBox(height: 8),
                              Text('Instant Camera',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 14)),
                              SizedBox(height: 2),
                              Text('Snap sharp photo',
                                  style: TextStyle(
                                      color: Color(0xFF94A3B8), fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          Navigator.pop(ctx);
                          final XFile? file = await _picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                            maxWidth: 1600,
                          );
                          if (file != null) {
                            onImageSelected(File(file.path));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            border: Border.all(color: borderLight, width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.photo_library_rounded,
                                  size: 32, color: deepGold),
                              SizedBox(height: 8),
                              Text('Photo Gallery',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textDark,
                                      fontSize: 14)),
                              SizedBox(height: 2),
                              Text('Select saved file',
                                  style: TextStyle(
                                      color: textSecondary, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // Upload file to server
  Future<String?> _uploadFile(File file, String fieldKey) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(AppUrl.uploadApplicationFiles),
      );

      if (accessToken != null) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }
      request.headers['Accept'] = 'application/json';

      var filePart = await http.MultipartFile.fromPath(
        'image',
        file.path,
        filename: pth.basename(file.path),
      );
      request.files.add(filePart);

      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 25));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResp = json.decode(response.body);
        if (jsonResp['success'] == true && jsonResp['data'] != null) {
          return jsonResp['data']['url'];
        }
      }
    } catch (e) {
      debugPrint('Error uploading $fieldKey: $e');
    }
    return null;
  }

  // Validations per step
  bool _validateStep0() {
    if (_fullNameController.text.trim().isEmpty) {
      Utils.flushBarErrorMessage('Please enter your Full Legal Name', context);
      return false;
    }
    if (_relativeNameController.text.trim().isEmpty) {
      Utils.flushBarErrorMessage(
          'Please enter relative name ($_relationType)', context);
      return false;
    }
    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains('@')) {
      Utils.flushBarErrorMessage('Please enter a valid Email address', context);
      return false;
    }
    if (_phoneController.text.trim().replaceAll(' ', '').length < 10) {
      Utils.flushBarErrorMessage(
          'Please enter a valid 10-digit Mobile Number', context);
      return false;
    }
    if (_dobController.text.trim().isEmpty) {
      Utils.flushBarErrorMessage('Please select Date of Birth', context);
      return false;
    }
    if (_occupationController.text.trim().isEmpty) {
      Utils.flushBarErrorMessage(
          'Please select or enter your Occupation', context);
      return false;
    }
    return true;
  }

  bool _validateStep1() {
    if (_addressController.text.trim().isEmpty) {
      Utils.flushBarErrorMessage('Please enter complete Street Address', context);
      return false;
    }
    if (_selectedState == null || _selectedState!.isEmpty) {
      Utils.flushBarErrorMessage('Please select your State / UT', context);
      return false;
    }
    if (_cityController.text.trim().isEmpty) {
      Utils.flushBarErrorMessage('Please specify your City', context);
      return false;
    }
    if (_pinCodeController.text.trim().length != 6) {
      Utils.flushBarErrorMessage('Please enter a valid 6-digit PIN Code', context);
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    final cleanAadhaar =
        _aadhaarNumberController.text.replaceAll(' ', '').trim();
    if (cleanAadhaar.length != 12) {
      Utils.flushBarErrorMessage(
          'Please enter complete 12-digit Aadhaar Number', context);
      return false;
    }
    final cleanPan = _panNumberController.text.trim();
    if (cleanPan.length != 10) {
      Utils.flushBarErrorMessage(
          'Please enter valid 10-character PAN (e.g. ABCDE1234F)', context);
      return false;
    }
    if (!_declarationAccepted) {
      Utils.flushBarErrorMessage(
          'Please accept the KYC genuine document declaration', context);
      return false;
    }
    return true;
  }

  // Submit Application
  Future<void> _submitApplication() async {
    if (!_validateStep2()) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Syncing KYC & Biometric Documents...';
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (_avatarImage != null && _avatarRemoteUrl == null) {
        _avatarRemoteUrl = await _uploadFile(_avatarImage!, 'avatar');
      }
      if (_aadhaarFrontImage != null && _aadhaarFrontRemoteUrl == null) {
        _aadhaarFrontRemoteUrl =
            await _uploadFile(_aadhaarFrontImage!, 'adhaar_file');
      }
      if (_aadhaarBackImage != null && _aadhaarBackRemoteUrl == null) {
        _aadhaarBackRemoteUrl =
            await _uploadFile(_aadhaarBackImage!, 'adhaar_back');
      }
      if (_panCardImage != null && _panCardRemoteUrl == null) {
        _panCardRemoteUrl = await _uploadFile(_panCardImage!, 'pan_file');
      }

      setState(() {
        _loadingMessage = 'Generating Property Allocation Token...';
      });

      final cleanAadhaar =
          _aadhaarNumberController.text.replaceAll(' ', '').trim();

      final payload = {
        'project_id': (widget.projectId ?? 1).toString(),
        'name': _fullNameController.text.trim(),
        'surname': '',
        'sonof': '$_relationType ${_relativeNameController.text.trim()}',
        'email': _emailController.text.trim(),
        'mobile': _phoneController.text.trim().replaceAll(' ', ''),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _selectedState ?? '',
        'nationality': _nationalityController.text.trim(),
        'dob': _dobController.text.trim(),
        'profession': _occupationController.text.trim(),
        'adhaar': cleanAadhaar,
        'pan': _panNumberController.text.trim().toUpperCase(),
        'avatar': _avatarRemoteUrl ?? '',
        'profile_url': _avatarRemoteUrl ?? '',
        'adhaar_file': _aadhaarFrontRemoteUrl ?? '',
        'aadhaar_url': _aadhaarFrontRemoteUrl ?? '',
        'pan_file': _panCardRemoteUrl ?? '',
        'pan_url': _panCardRemoteUrl ?? '',
        'additional_info': json.encode({
          'address_type': _addressType,
          'alt_mobile': _altPhoneController.text.trim(),
          'anniversary': _anniversaryController.text.trim(),
          'landmark': _landmarkController.text.trim(),
          'aadhaar_back': _aadhaarBackRemoteUrl ?? '',
        }),
        'no_of_app': '1',
      };

      final response = await http.post(
        Uri.parse(AppUrl.applicationCreate),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
        body: payload,
      ).timeout(const Duration(seconds: 15));

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final resJson = json.decode(response.body);
        if (resJson['success'] == true) {
          _showCelebrationModal();
        } else {
          Utils.flushBarErrorMessage(
              resJson['message'] ?? 'Failed to submit application', context);
        }
      } else {
        Utils.flushBarErrorMessage(
            'Server response error (${response.statusCode})', context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Utils.flushBarErrorMessage('Submission error: $e', context);
    }
  }

  void _showCelebrationModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF047857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: emeraldVerified.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.verified_rounded,
                    color: Colors.white, size: 52),
              ),
              const SizedBox(height: 20),
              const Text(
                'Application Registered!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your applicant profile and verified KYC have been recorded under RERA Title Allocation. Proceed to view and lock your unit allotment token.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [deepNavySlate, Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(item: ''),
                      ),
                      (Route<dynamic> route) => route.isFirst,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Proceed to Token & Payment',
                        style: TextStyle(
                          color: brightGold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded,
                          color: brightGold, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleBackNavigation() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          setState(() {
            _currentStep--;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: surfacePure,
        body: Stack(
          children: [
            Column(
              children: [
                // ---------------- LUXURY DYNAMIC HERO BAR & STEPPER ----------------
                _buildHeroHeader(),

                // ---------------- ACTIVE FORM STEP BODY ----------------
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_currentStep == 0) _buildStep0ApplicantIdentity(),
                        if (_currentStep == 1) _buildStep1ResidenceAddress(),
                        if (_currentStep == 2) _buildStep2BiometricKycVault(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ---------------- FLOATING BOTTOM ACTION DOCK ----------------
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildFloatingBottomDock(),
            ),

            // ---------------- ULTRA LOADING OVERLAY ----------------
            if (_isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // LUXURY HERO HEADER & STEP PROGRESSION
  // =========================================================================
  Widget _buildHeroHeader() {
    double progress = (_currentStep + 1) / 3.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            obsidianBlack,
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 22,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: _handleBackNavigation,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [brightGold, deepGold],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'VIP REGISTRY ALLOTMENT',
                            style: TextStyle(
                              color: obsidianBlack,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'STAGE ${_currentStep + 1} OF 3',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _currentStep == 0
                          ? 'Applicant Profile'
                          : _currentStep == 1
                              ? 'Residence Details'
                              : 'Biometric KYC Vault',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Percentage Badge
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: luxuryGold.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: brightGold.withOpacity(0.4)),
                ),
                child: Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: brightGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stepper Navigation Track
          Row(
            children: [
              _buildStepIndicator(
                index: 0,
                label: 'Identity',
                icon: Icons.person_rounded,
              ),
              _buildStepDivider(isDone: _currentStep > 0),
              _buildStepIndicator(
                index: 1,
                label: 'Residence',
                icon: Icons.location_on_rounded,
              ),
              _buildStepDivider(isDone: _currentStep > 1),
              _buildStepIndicator(
                index: 2,
                label: 'KYC Vault',
                icon: Icons.verified_user_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required int index,
    required String label,
    required IconData icon,
  }) {
    bool isCurrent = _currentStep == index;
    bool isDone = _currentStep > index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index < _currentStep) {
            setState(() {
              _currentStep = index;
            });
          }
        },
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isCurrent
                    ? const LinearGradient(
                        colors: [brightGold, deepGold],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isDone
                    ? emeraldVerified
                    : (!isCurrent ? Colors.white.withOpacity(0.1) : null),
                border: Border.all(
                  color: isCurrent
                      ? Colors.white
                      : (isDone ? Colors.transparent : Colors.white24),
                  width: isCurrent ? 2 : 1,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: brightGold.withOpacity(0.45),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isDone ? Icons.check_rounded : icon,
                color: isCurrent ? obsidianBlack : Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isCurrent
                    ? Colors.white
                    : (isDone ? emeraldVerified : Colors.white38),
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepDivider({required bool isDone}) {
    return Container(
      width: 24,
      height: 2.5,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDone ? emeraldVerified : Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // =========================================================================
  // STEP 0: APPLICANT IDENTITY (PROFILE, RELATION, CONTACT, DOB, CAREER)
  // =========================================================================
  Widget _buildStep0ApplicantIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------- VIP AVATAR STUDIO CARD ----------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: borderLight),
          ),
          child: Row(
            children: [
              // Avatar with Gold Frame
              GestureDetector(
                onTap: () {
                  _showImagePickerSheet((file) {
                    setState(() {
                      _avatarImage = file;
                    });
                  }, 'Upload Applicant Photo');
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [brightGold, deepGold],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: deepGold.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF1F5F9),
                        ),
                        child: _avatarImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _avatarImage!,
                                  width: 89,
                                  height: 89,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      size: 42,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [deepNavySlate, slateCard],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: brightGold,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _avatarImage != null
                                ? emeraldVerified.withOpacity(0.12)
                                : luxuryGold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _avatarImage != null
                                ? 'PHOTO ATTACHED ✓'
                                : 'PASSPORT PHOTO',
                            style: TextStyle(
                              color: _avatarImage != null
                                  ? emeraldVerified
                                  : deepGold,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _avatarImage != null
                          ? 'Ready for Title Deed'
                          : 'Applicant Photo',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Tap circle to take or select high-resolution front portrait',
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ---------------- FORM CONTAINER ----------------
        _buildLuxuryCard(
          title: 'Primary Applicant Details',
          subtitle: 'Official government credentials for property allotment',
          icon: Icons.badge_rounded,
          children: [
            // Full Legal Name
            _buildField(
              label: 'Full Legal Name',
              hintText: 'e.g. Abhishek Sharma',
              isRequired: true,
              controller: _fullNameController,
              icon: Icons.person_outline_rounded,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),

            // Segmented Relationship Selector
            _buildLabel('Relationship to Applicant', isRequired: true),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRelationCard('S/O', 'Son Of', Icons.boy_rounded),
                const SizedBox(width: 10),
                _buildRelationCard(
                    'W/O', 'Spouse Of', Icons.favorite_border_rounded),
                const SizedBox(width: 10),
                _buildRelationCard('D/O', 'Daughter Of', Icons.girl_rounded),
              ],
            ),
            const SizedBox(height: 14),

            // Dynamic Relative Name
            _buildField(
              label: _relationType == 'W/O'
                  ? 'Husband / Spouse Full Name'
                  : "Father's Full Name",
              hintText: 'Enter relative full name',
              isRequired: true,
              controller: _relativeNameController,
              icon: Icons.family_restroom_rounded,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),

            // Email Address
            _buildField(
              label: 'Email Address',
              hintText: 'e.g. abhishek@example.com',
              isRequired: true,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.alternate_email_rounded,
            ),
            const SizedBox(height: 18),

            // Primary Phone (Full width line for complete visibility)
            _buildField(
              label: 'Primary Phone',
              hintText: 'Enter 10-digit mobile number',
              isRequired: true,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefix: _buildCountryCode(),
              maxLength: 10,
            ),
            const SizedBox(height: 18),

            // Alternate Mobile (Full width line)
            _buildField(
              label: 'Alternate Mobile',
              hintText: 'Optional secondary contact number',
              isRequired: false,
              controller: _altPhoneController,
              keyboardType: TextInputType.phone,
              prefix: _buildCountryCode(),
              maxLength: 10,
            ),
            const SizedBox(height: 18),

            // Date of Birth (Full width line)
            _buildDateTile(
              label: 'Date of Birth',
              hintText: 'Select Date of Birth (DOB)',
              isRequired: true,
              controller: _dobController,
              trailingChip: _getAgeString().isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: luxuryGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: luxuryGold.withOpacity(0.35),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getAgeString(),
                        style: const TextStyle(
                          color: deepGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
              onTap: () {
                _pickDate(
                  title: 'Date of Birth',
                  isDob: true,
                  controller: _dobController,
                  initialDate: DateTime(1995, 1, 1),
                  firstDate: DateTime(1930),
                  lastDate: DateTime.now(),
                );
              },
            ),
            const SizedBox(height: 18),

            // Anniversary (Full width line)
            _buildDateTile(
              label: 'Anniversary Date',
              hintText: 'Select Anniversary Date (Optional)',
              isRequired: false,
              controller: _anniversaryController,
              onTap: () {
                _pickDate(
                  title: 'Anniversary Date',
                  isDob: false,
                  controller: _anniversaryController,
                  initialDate: DateTime(2020, 1, 1),
                  firstDate: DateTime(1960),
                  lastDate: DateTime.now(),
                );
              },
            ),
            const SizedBox(height: 18),

            // Profession / Career Selector & Chips
            _buildField(
              label: 'Profession / Occupation',
              hintText: 'e.g. Senior Software Architect',
              isRequired: true,
              controller: _occupationController,
              icon: Icons.work_outline_rounded,
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _quickOccupations.map((item) {
                  final String title = item['title'];
                  final IconData ic = item['icon'];
                  bool isSelected =
                      _occupationController.text.trim().toLowerCase() ==
                          title.toLowerCase();

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _occupationController.text = isSelected ? '' : title;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? deepNavySlate : inputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? brightGold : borderLight,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              ic,
                              size: 15,
                              color: isSelected ? brightGold : textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected ? Colors.white : textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // Nationality
            _buildField(
              label: 'Nationality',
              hintText: 'Indian',
              isRequired: true,
              controller: _nationalityController,
              icon: Icons.flag_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRelationCard(String tag, String label, IconData icon) {
    bool isSelected = _relationType == tag;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _relationType = tag;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [deepNavySlate, slateCard],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: !isSelected ? inputBg : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? brightGold : borderLight,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? brightGold : textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                tag,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // STEP 1: RESIDENCE & COMMUNICATION ADDRESS
  // =========================================================================
  Widget _buildStep1ResidenceAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Dispatch Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [obsidianBlack, deepNavySlate],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: luxuryGold.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.markunread_mailbox_rounded,
                    color: brightGold, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Official Document Dispatch',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Allotment deed, payment receipts, and registered possession notices will be dispatched here.',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        _buildLuxuryCard(
          title: 'Communication Address',
          subtitle: 'Verify postal address for registry couriers',
          icon: Icons.home_work_rounded,
          children: [
            // Address Category Chips
            _buildLabel('Address Type'),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildAddressTypeChip('Permanent Home', Icons.home_rounded),
                const SizedBox(width: 8),
                _buildAddressTypeChip('Office / Work', Icons.apartment_rounded),
                const SizedBox(width: 8),
                _buildAddressTypeChip('Current Rental', Icons.location_city_rounded),
              ],
            ),
            const SizedBox(height: 18),

            // Full House & Street Address
            _buildField(
              label: 'House / Flat No., Street, Colony',
              hintText: 'e.g. Villa 42, Palm Greens, Sector 65',
              isRequired: true,
              controller: _addressController,
              maxLines: 3,
              icon: Icons.edit_road_rounded,
            ),
            const SizedBox(height: 18),

            // State Selector
            _buildLabel('State / Union Territory', isRequired: true),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderLight),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedState,
                  isExpanded: true,
                  hint: Row(
                    children: const [
                      Icon(Icons.map_outlined, color: textSecondary, size: 20),
                      SizedBox(width: 10),
                      Text('Select Indian State',
                          style: TextStyle(color: textSecondary, fontSize: 14)),
                    ],
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: textDark),
                  items: _indianStates.map((st) {
                    return DropdownMenuItem<String>(
                      value: st,
                      child: Text(
                        st,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedState = val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // City Input & Quick Chips
            _buildField(
              label: 'City / District',
              hintText: 'Enter city name',
              isRequired: true,
              controller: _cityController,
              icon: Icons.location_city_rounded,
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _popularCities.map((c) {
                  bool isSelected =
                      _cityController.text.trim().toLowerCase() ==
                          c.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(c),
                      backgroundColor: isSelected ? deepNavySlate : inputBg,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? brightGold : textDark,
                      ),
                      side: BorderSide(
                        color: isSelected ? brightGold : borderLight,
                      ),
                      onPressed: () {
                        setState(() {
                          _cityController.text = c;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // Pin Code & Landmark
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildField(
                    label: 'Pin Code',
                    hintText: '6-digit PIN',
                    isRequired: true,
                    controller: _pinCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    icon: Icons.pin_drop_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: _buildField(
                    label: 'Prominent Landmark',
                    hintText: 'Near Metro, Park',
                    isRequired: false,
                    controller: _landmarkController,
                    icon: Icons.explore_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressTypeChip(String title, IconData icon) {
    bool isSelected = _addressType == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _addressType = title;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? deepNavySlate : inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? brightGold : borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? brightGold : textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // STEP 2: BIOMETRIC KYC VAULT (LIVE AADHAAR & PAN INTERACTIVE CARDS)
  // =========================================================================
  Widget _buildStep2BiometricKycVault() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Security Encryption Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF064E3B), Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: emeraldVerified.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'RERA Biometric Title Vault',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '256-bit AES cryptographic encryption. Documents are tokenized strictly for government title registry.',
                      style: TextStyle(
                        color: Color(0xFFD1FAE5),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ---------------- INTERACTIVE LIVE AADHAAR CARD ----------------
        _buildVirtualAadhaarCard(),

        const SizedBox(height: 18),

        _buildLuxuryCard(
          title: 'Aadhaar UIDAI Verification',
          subtitle: 'Enter 12-digit number and attach original photos',
          icon: Icons.fingerprint_rounded,
          children: [
            _buildField(
              label: 'Aadhaar Number (12 Digits)',
              hintText: '•••• •••• ••••',
              isRequired: true,
              controller: _aadhaarNumberController,
              keyboardType: TextInputType.number,
              maxLength: 12,
              icon: Icons.credit_card_rounded,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),

            // Aadhaar Front & Back Cards
            Row(
              children: [
                Expanded(
                  child: _buildKycDocSlot(
                    title: 'Aadhaar Front',
                    subtitle: 'Photo & UID Side',
                    file: _aadhaarFrontImage,
                    onTap: () {
                      _showImagePickerSheet((file) {
                        setState(() {
                          _aadhaarFrontImage = file;
                        });
                      }, 'Upload Aadhaar Front');
                    },
                    onClear: () {
                      setState(() {
                        _aadhaarFrontImage = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildKycDocSlot(
                    title: 'Aadhaar Back',
                    subtitle: 'Address & QR Side',
                    file: _aadhaarBackImage,
                    onTap: () {
                      _showImagePickerSheet((file) {
                        setState(() {
                          _aadhaarBackImage = file;
                        });
                      }, 'Upload Aadhaar Back');
                    },
                    onClear: () {
                      setState(() {
                        _aadhaarBackImage = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 22),

        // ---------------- INTERACTIVE LIVE PAN CARD ----------------
        _buildVirtualPanCard(),

        const SizedBox(height: 18),

        _buildLuxuryCard(
          title: 'Income Tax PAN Card',
          subtitle: 'Mandatory for property financial registration',
          icon: Icons.account_balance_rounded,
          children: [
            _buildField(
              label: 'PAN Number (10 Characters)',
              hintText: 'e.g. ABCDE1234F',
              isRequired: true,
              controller: _panNumberController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 10,
              icon: Icons.badge_rounded,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),

            _buildKycDocSlot(
              title: 'Upload Original PAN Card',
              subtitle: 'Clear front face showing name, photo & signature',
              file: _panCardImage,
              isFullWidth: true,
              onTap: () {
                _showImagePickerSheet((file) {
                  setState(() {
                    _panCardImage = file;
                  });
                }, 'Upload PAN Card');
              },
              onClear: () {
                setState(() {
                  _panCardImage = null;
                });
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Declaration Checkbox
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _declarationAccepted = !_declarationAccepted;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _declarationAccepted ? emeraldVerified : borderLight,
                width: _declarationAccepted ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _declarationAccepted
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  color: _declarationAccepted ? emeraldVerified : textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'I certify that the identity documents and KYC details submitted belong to me and are authentic under Indian Registration & IT Acts.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: textDark,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // VIRTUAL INTERACTIVE AADHAAR CARD WIDGET
  // =========================================================================
  Widget _buildVirtualAadhaarCard() {
    String aadhaarText = _aadhaarNumberController.text.trim();
    String formattedAadhaar = aadhaarText.isNotEmpty
        ? _formatAadhaarDisplay(aadhaarText)
        : 'XXXX  XXXX  XXXX';
    String applicantName = _fullNameController.text.trim().isNotEmpty
        ? _fullNameController.text.trim().toUpperCase()
        : 'APPLICANT LEGAL NAME';
    String dob = _dobController.text.trim().isNotEmpty
        ? _dobController.text.trim()
        : 'DD / MM / YYYY';

    return Container(
      width: double.infinity,
      height: 205,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // National Tricolor Accent Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF9933),
                    Colors.white,
                    Color(0xFF138808),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Top Banner
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.shield_rounded, color: brightGold, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'GOVERNMENT OF INDIA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AADHAAR',
                        style: TextStyle(
                          color: brightGold,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Middle Info Row with Avatar & Details
                Row(
                  children: [
                    // Photo Box
                    Container(
                      width: 54,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: _avatarImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.file(_avatarImage!,
                                  fit: BoxFit.cover),
                            )
                          : const Icon(Icons.person_rounded,
                              color: Colors.white38, size: 34),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            applicantName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'DOB: $dob',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'REL: $_relationType ${_relativeNameController.text.trim()}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 10.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Aadhaar 12-Digit Live Number
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      formattedAadhaar,
                      style: const TextStyle(
                        color: brightGold,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // VIRTUAL INTERACTIVE PAN CARD WIDGET
  // =========================================================================
  Widget _buildVirtualPanCard() {
    String panText = _panNumberController.text.trim();
    String formattedPan = panText.isNotEmpty
        ? panText.toUpperCase()
        : 'ABCDE1234F';
    String applicantName = _fullNameController.text.trim().isNotEmpty
        ? _fullNameController.text.trim().toUpperCase()
        : 'APPLICANT LEGAL NAME';
    String relativeName = _relativeNameController.text.trim().isNotEmpty
        ? _relativeNameController.text.trim().toUpperCase()
        : 'FATHER / SPOUSE NAME';

    return Container(
      width: double.infinity,
      height: 205,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF172554),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: sapphireAccent.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Holographic Seal Accent
          Positioned(
            right: 18,
            top: 18,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [brightGold, deepGold],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.star_rounded,
                  color: obsidianBlack, size: 22),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INCOME TAX DEPARTMENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'GOVT. OF INDIA / PERMANENT ACCOUNT CARD',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const Spacer(),

                // Chip & Details
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [brightGold, deepGold],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Icon(Icons.memory_rounded,
                            color: obsidianBlack.withOpacity(0.8), size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            applicantName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            relativeName,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Live PAN Number Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      formattedPan,
                      style: const TextStyle(
                        color: brightGold,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // REUSABLE MACROS & MODERN UI COMPONENTS
  // =========================================================================
  Widget _buildLuxuryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [deepNavySlate, slateCard],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: brightGold, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: borderLight),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: 0.1,
        ),
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ]
            : const [],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hintText,
    required bool isRequired,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
    int? maxLength,
    IconData? icon,
    Widget? prefix,
    Function(String)? onChanged,
  }) {
    bool hasText = controller.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: isRequired),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasText ? luxuryGold.withOpacity(0.5) : borderLight,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              if (prefix != null) prefix,
              if (icon != null && prefix == null) ...[
                Icon(icon, color: textSecondary, size: 20),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  textCapitalization: textCapitalization,
                  maxLines: maxLines,
                  maxLength: maxLength,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w400,
                    ),
                    counterText: '',
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    if (onChanged != null) onChanged(val);
                    setState(() {});
                  },
                ),
              ),
              if (hasText)
                const Icon(Icons.check_circle_rounded,
                    color: emeraldVerified, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountryCode({bool compact = false}) {
    return Container(
      padding: const EdgeInsets.only(right: 10),
      margin: const EdgeInsets.only(right: 10),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: borderLight, width: 1.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇮🇳', style: TextStyle(fontSize: 17)),
          const SizedBox(width: 4),
          Text(
            '+91',
            style: TextStyle(
              fontSize: compact ? 13 : 14,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile({
    required String label,
    required String hintText,
    required bool isRequired,
    required TextEditingController controller,
    required VoidCallback onTap,
    Widget? trailingChip,
  }) {
    bool hasValue = controller.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel(label, isRequired: isRequired),
            if (trailingChip != null) trailingChip,
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasValue
                    ? luxuryGold.withOpacity(0.55)
                    : borderLight,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: hasValue
                        ? luxuryGold.withOpacity(0.18)
                        : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: hasValue ? deepGold : textSecondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasValue ? controller.text : hintText,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight:
                          hasValue ? FontWeight.w600 : FontWeight.w400,
                      color: hasValue ? textDark : const Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasValue)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: emeraldVerified,
                    size: 18,
                  )
                else
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF94A3B8),
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKycDocSlot({
    required String title,
    required String subtitle,
    required File? file,
    required VoidCallback onTap,
    required VoidCallback onClear,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isFullWidth ? 175 : 160,
        decoration: BoxDecoration(
          color: inputBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: file != null ? emeraldVerified : borderLight,
            width: file != null ? 2 : 1.2,
          ),
          boxShadow: file != null
              ? [
                  BoxShadow(
                    color: emeraldVerified.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: file != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(file, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onClear,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: emeraldVerified, size: 15),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: deepNavySlate,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: deepNavySlate.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.cloud_upload_rounded,
                      color: brightGold,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderLight),
                    ),
                    child: const Text(
                      'Tap to Scan / Upload',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: deepGold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // =========================================================================
  // FLOATING BOTTOM DOCK WITH GLOW ACTION
  // =========================================================================
  Widget _buildFloatingBottomDock() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _handleBackNavigation,
              child: Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderLight),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: textDark,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: SizedBox(
              height: 54,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      obsidianBlack,
                      deepNavySlate,
                      Color(0xFF1E293B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentStep == 0) {
                      if (_validateStep0()) {
                        setState(() {
                          _currentStep = 1;
                        });
                      }
                    } else if (_currentStep == 1) {
                      if (_validateStep1()) {
                        setState(() {
                          _currentStep = 2;
                        });
                      }
                    } else {
                      _submitApplication();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentStep < 2
                            ? (_currentStep == 0
                                ? 'Proceed to Residence Details'
                                : 'Proceed to Biometric KYC')
                            : 'Submit Verified Application',
                        style: const TextStyle(
                          color: brightGold,
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentStep < 2
                            ? Icons.arrow_forward_rounded
                            : Icons.send_rounded,
                        color: brightGold,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Loading Overlay
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.65),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 26),
          margin: const EdgeInsets.symmetric(horizontal: 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(deepGold),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _loadingMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '256-Bit Cryptographic Vault Security',
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
