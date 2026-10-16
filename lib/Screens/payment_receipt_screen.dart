import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/colors.dart';
import '../Constants/constants.dart';
import '../res/app_urls.dart';

class PaymentReceiptScreen extends StatefulWidget {
  final int applicationId;
  final Map<String, dynamic> application;

  const PaymentReceiptScreen({
    super.key,
    required this.applicationId,
    this.application = const {},
  });

  @override
  State<PaymentReceiptScreen> createState() => _PaymentReceiptScreenState();
}

class _PaymentReceiptScreenState extends State<PaymentReceiptScreen> {
  static const _templateRatio = 768 / 1024;
  static const _customerCopyRatio = 582 / 746;
  static const _formBackground = Color(0xFFF8FAFC);
  static const _formInk = Color(0xFF17233F);
  static const _formMuted = Color(0xFF64748B);
  static const _formGold = Color(0xFF9B6513);

  Map<String, dynamic>? _receipt;
  bool _isLoading = true;
  String? _error;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  String? _paymentMethod;
  bool _isSavingDraft = false;
  bool _draftSaved = false;

  static const _formFields = <String, String>{
    'receipt_date': 'Date',
    'customer_name': 'Received with thanks from Mr./Mrs./Ms.',
    'address': 'Having address at',
    'phone': 'Phone',
    'mobile': 'Mobile',
    'amount': 'A sum of Rs.',
    'amount_words': 'Amount in words',
    'payment_for': 'On account of booking/part/payment of unit',
    'area': 'Area (Sq. yd.)',
    'at': 'At',
    'payment_on': 'On',
    'payment_date': 'Date',
    'drawn_on_bank': 'Drawn on Bank',
  };

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadLocalDraft();
    _loadReceipt();
  }

  void _initializeForm() {
    final rawName = (widget.application['applicant_name'] ??
            widget.application['name'] ??
            '')
        .toString()
        .trim();
    final rawAddress = (widget.application['applicant_address'] ??
            widget.application['address'] ??
            '')
        .toString()
        .trim();
    final city = (widget.application['applicant_city'] ??
            widget.application['city'] ??
            '')
        .toString()
        .trim();
    final state = (widget.application['applicant_state'] ??
            widget.application['state'] ??
            '')
        .toString()
        .trim();
    final address = [rawAddress, city, state]
        .where((part) => part.isNotEmpty)
        .toSet()
        .join(', ');
    final date = DateTime.now();
    final today =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    for (final key in _formFields.keys) {
      String initialValue = '';
      if (key == 'receipt_date') initialValue = today;
      if (key == 'customer_name') initialValue = rawName;
      if (key == 'address') initialValue = address;
      if (key == 'mobile') {
        initialValue = (widget.application['applicant_mobile'] ??
                widget.application['mobile'] ??
                '')
            .toString();
      }
      _controllers[key] = TextEditingController(text: initialValue);
    }
  }

  Future<void> _loadLocalDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawDraft =
          prefs.getString('payment_receipt_draft_${widget.applicationId}');
      if (rawDraft == null) return;

      final decoded = json.decode(rawDraft);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('The saved receipt draft is invalid.');
      }
      if (!mounted) return;

      setState(() {
        for (final entry in decoded.entries) {
          if (_controllers.containsKey(entry.key)) {
            _controllers[entry.key]!.text = entry.value.toString();
          }
        }
        _paymentMethod = decoded['payment_method']?.toString();
        _draftSaved = true;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load saved receipt draft: $error')),
      );
    }
  }

  Future<void> _saveLocalDraft() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSavingDraft = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = <String, String>{
        for (final entry in _controllers.entries)
          entry.key: entry.value.text.trim(),
        'payment_method': _paymentMethod ?? '',
      };
      await prefs.setString(
        'payment_receipt_draft_${widget.applicationId}',
        json.encode(draft),
      );
      if (!mounted) return;
      setState(() {
        _isSavingDraft = false;
        _draftSaved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt draft saved on this device only.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSavingDraft = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save receipt draft: $error')),
      );
    }
  }

  Future<void> _loadReceipt() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null || token.isEmpty) {
        throw StateError('Please sign in again to view your payment receipt.');
      }

      final response = await http
          .post(
            Uri.parse(AppUrl.applicationPaymentReceipt),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'application_id': widget.applicationId,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw StateError(
            'Payment receipts are not enabled on the current server yet. '
            'Please ask the developer to deploy the receipt update.',
          );
        }
        if (response.statusCode == 401) {
          throw StateError('Your session expired. Please sign in again.');
        }
        throw Exception(
          'Payment receipt could not be loaded (${response.statusCode}).',
        );
      }

      final decoded = json.decode(response.body);
      final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
      final receipt = data is Map<String, dynamic> ? data['receipt'] : null;
      if (decoded is! Map<String, dynamic> ||
          decoded['success'] != true ||
          receipt is! Map<String, dynamic>) {
        throw const FormatException(
            'The payment receipt response was invalid.');
      }

      if (!mounted) return;
      setState(() {
        _receipt = receipt;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('Bad state: ', '');
        _isLoading = false;
      });
    }
  }

  bool get _isRejected =>
      (_receipt?['application_status']?.toString().toLowerCase() ?? '')
          .contains('reject');

  Widget _buildReceipt() {
    final width = MediaQuery.sizeOf(context).width - 32;
    return InteractiveViewer(
      constrained: false,
      minScale: 1,
      maxScale: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/payment_receipt_template.png',
          width: width,
          height: width / _templateRatio,
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) => const SizedBox(
            width: 280,
            height: 180,
            child: Center(
              child: Text('Payment receipt form image could not be loaded.'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCopyImage() {
    final width = MediaQuery.sizeOf(context).width - 32;
    return InteractiveViewer(
      constrained: false,
      minScale: 1,
      maxScale: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/customer_copy_receipt_form.png',
          width: width,
          height: width / _customerCopyRatio,
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) => const SizedBox(
            width: 280,
            height: 180,
            child: Center(
              child: Text('Customer copy form image could not be loaded.'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    final message = _isLoading
        ? 'Loading receipt details...'
        : _error ??
            (_isRejected
                ? 'Your application was rejected. Please contact your agent.'
                : 'Your receipt details will be available after the server update.');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF3D49B)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF925B0A),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String key, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: keyboardType,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: _formFields[key],
          hintText: hint,
          alignLabelWithHint: maxLines > 1,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD8DEE9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD8DEE9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _formGold, width: 1.5),
          ),
        ),
        validator: required
            ? (value) => value == null || value.trim().isEmpty
                ? 'Please enter ${_formFields[key]!.toLowerCase()}.'
                : null
            : null,
        onChanged: (_) {
          if (_draftSaved) setState(() => _draftSaved = false);
        },
      ),
    );
  }

  Widget _buildCustomerCopyForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7D7AF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F172A),
              blurRadius: 16,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'CUSTOMER COPY',
                style: TextStyle(
                  color: _formInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 22),
            _buildTextField(
              'receipt_date',
              hint: 'DD/MM/YYYY',
              required: true,
            ),
            _buildTextField('customer_name', required: true),
            _buildTextField(
              'address',
              maxLines: 2,
              required: true,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'phone',
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    'mobile',
                    keyboardType: TextInputType.phone,
                    required: true,
                  ),
                ),
              ],
            ),
            _buildTextField(
              'amount',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              required: true,
            ),
            _buildTextField('amount_words', required: true),
            _buildTextField(
              'payment_for',
              maxLines: 2,
              required: true,
            ),
            _buildTextField(
              'area',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            Row(
              children: [
                Expanded(child: _buildTextField('at')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('payment_on')),
              ],
            ),
            DropdownButtonFormField<String>(
              key: ValueKey(_paymentMethod ?? ''),
              initialValue: _paymentMethod,
              decoration: InputDecoration(
                labelText: 'By Cash / Cheque / DD / NEFT',
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFD8DEE9)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFD8DEE9)),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                DropdownMenuItem(value: 'DD', child: Text('DD')),
                DropdownMenuItem(value: 'NEFT', child: Text('NEFT')),
              ],
              onChanged: (value) => setState(() {
                _paymentMethod = value;
                _draftSaved = false;
              }),
              validator: (value) =>
                  value == null ? 'Please select a payment method.' : null,
            ),
            const SizedBox(height: 14),
            _buildTextField('payment_date', hint: 'DD/MM/YYYY'),
            _buildTextField('drawn_on_bank'),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _buildSignatureSpace("Customer's Signature"),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSignatureSpace("Manager's Signature"),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Note: A system-generated invoice will be later mailed to your registered E-mail address and registered communication address by post.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _formMuted,
                fontSize: 10,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSavingDraft ? null : _saveLocalDraft,
                icon: _isSavingDraft
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSavingDraft
                    ? 'Saving...'
                    : _draftSaved
                        ? 'Saved on this device'
                        : 'Save receipt on this device'),
                style: FilledButton.styleFrom(
                  backgroundColor: _formGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This draft is stored only on this device. It is not sent to or saved on the company server.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _formMuted,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureSpace(String label) {
    return Column(
      children: [
        const SizedBox(height: 54),
        Container(height: 1, color: const Color(0xFF94A3B8)),
        const SizedBox(height: 7),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _formInk, fontSize: 11),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _formBackground,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Payment Receipt', style: appThemeTextWhiteC),
          flexibleSpace: const DecoratedBox(
            decoration: BoxDecoration(gradient: appBarGradient),
          ),
          actions: [
            IconButton(
              onPressed: _loadReceipt,
              tooltip: 'Refresh receipt details',
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFFDCE3F1),
            tabs: [
              Tab(text: 'Lucky Draw Receipt'),
              Tab(text: 'Customer Copy Form'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: _loadReceipt,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                children: [
                  if (_isLoading || _error != null || _isRejected) ...[
                    _buildStatusMessage(),
                    const SizedBox(height: 12),
                  ],
                  _buildReceipt(),
                ],
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                const Text(
                  'Customer copy form image',
                  style: TextStyle(
                    color: _formMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCustomerCopyImage(),
                const SizedBox(height: 18),
                const Text(
                  'Enter receipt details below. The fields are saved only on this device.',
                  style: TextStyle(
                    color: _formMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCustomerCopyForm(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
