import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:property_project/Utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/colors.dart';
import '../Constants/reusable_widgets.dart';
import '../res/app_urls.dart';

class CreateVisitScreen extends StatefulWidget {
  const CreateVisitScreen({super.key});

  @override
  State<CreateVisitScreen> createState() => _CreateVisitScreenState();
}

class _CreateVisitScreenState extends State<CreateVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
    );

    if (pickedDate == null || !mounted) return;
    setState(() {
      _selectedDate = pickedDate;
      _dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;

    setState(() => _isSubmitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Please sign in again to book a site visit.');
      }

      final response = await http
          .post(
            Uri.parse(AppUrl.createSiteVisit),
            headers: {
              'Authorization': '******',
              'Accept': 'application/json',
            },
            body: {
              'visitor_name': _nameController.text.trim(),
              'visitor_mobile': _phoneController.text.trim(),
              'visit_date': _dateController.text,
            },
          )
          .timeout(const Duration(seconds: 15));

      final responseData = json.decode(response.body);
      if (!mounted) return;

      if (response.statusCode == 200 && responseData['success'] == true) {
        _nameController.clear();
        _phoneController.clear();
        _dateController.clear();
        setState(() => _selectedDate = null);
        Utils.flushBarSuccessMessage(
          'Site visit request submitted successfully.',
          context,
        );
      } else {
        final errors = responseData['errors'];
        final firstError =
            errors is List && errors.isNotEmpty ? errors.first : null;
        final message = firstError is List && firstError.isNotEmpty
            ? firstError.first.toString()
            : firstError?.toString() ?? 'Unable to submit the site visit request.';
        Utils.flushBarErrorMessage(message, context);
      }
    } catch (error) {
      if (mounted) {
        Utils.flushBarErrorMessage(
          error.toString().replaceFirst('Exception: ', ''),
          context,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Site Visit'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: appBarGradient),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: orangeC,
                      size: 56,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Book a Site Visit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your details and choose a convenient visit date.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                    const SizedBox(height: 26),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final digits =
                            (value ?? '').replaceAll(RegExp(r'\D'), '');
                        if (digits.length < 7 || digits.length > 15) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: const InputDecoration(
                        labelText: 'Visit Date',
                        hintText: 'Select a date',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_selectedDate == null ||
                            value == null ||
                            value.isEmpty) {
                          return 'Please select a visit date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangeC,
                          foregroundColor: whiteC,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: whiteC,
                                ),
                              )
                            : const Text('Submit Visit Request'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
