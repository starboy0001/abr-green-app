import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/colors.dart';
import '../Constants/constants.dart';
import '../Utils/utils.dart';
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
  // Upper section blanks (written and verified by company/developer side)
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _txnRefController = TextEditingController();
  final TextEditingController _resultDateController = TextEditingController();
  String _paymentMode = 'UPI / Online';

  // 5 Recipient parameters
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ticketIdController = TextEditingController();
  final TextEditingController _relationshipManagerController =
      TextEditingController();

  bool _isLoading = true;
  bool _isDownloading = false;

  static const _navy = Color(0xFF0F172A);
  static const _gold = Color(0xFFD4AF37);
  static const _goldDark = Color(0xFF996515);
  static const _bg = Color(0xFFF1F5F9);

  final List<String> _paymentModeOptions = [
    'UPI / Online',
    'Cash',
    'Paytm',
    'Cheque',
    'NEFT / RTGS',
    'Bank Transfer'
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _fetchReceiptData();
  }

  void _initializeFields() {
    final app = widget.application;

    // Prefill name
    final name = (app['applicant_name'] ??
            app['name'] ??
            app['customer_name'] ??
            'Customer Member')
        .toString()
        .trim();
    _nameController.text = name.isNotEmpty ? name : 'Customer Member';

    // Prefill contact number
    final mobile = (app['applicant_mobile'] ??
            app['mobile'] ??
            app['contact_no'] ??
            '9876543210')
        .toString()
        .trim();
    _contactNoController.text = mobile;

    // Prefill email
    final email = (app['applicant_email'] ??
            app['email'] ??
            'investor@abrgreens.com')
        .toString()
        .trim();
    _emailController.text = email;

    // Prefill ticket ID
    final rawTicket = (app['ticket_id'] ??
            app['ticket_no'] ??
            app['ref_id'] ??
            '')
        .toString()
        .trim();
    _ticketIdController.text = rawTicket.isNotEmpty
        ? rawTicket
        : 'ISCDP-TK-${widget.applicationId.toString().padLeft(4, '0')}';

    // Prefill 5th parameter: Relationship Manager
    _relationshipManagerController.text =
        (app['relationship_manager'] ?? 'Amit Sharma (Senior Manager)')
            .toString();

    // Prefill Upper Blanks
    final rawAmount = (app['payment_amount'] ??
            app['payment_plan_amount'] ??
            app['amount'] ??
            '51,000')
        .toString()
        .replaceAll(RegExp(r'[^\d.,]'), '')
        .trim();
    _amountController.text = rawAmount.isNotEmpty ? rawAmount : '51,000';

    _paymentMode = (app['payment_mode'] ?? 'UPI / Online').toString();
    if (!_paymentModeOptions.contains(_paymentMode)) {
      _paymentMode = 'UPI / Online';
    }

    _txnRefController.text = (app['transaction_ref_no'] ??
            app['txn_id'] ??
            'TXN-ISCDP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}')
        .toString();

    _resultDateController.text =
        (app['result_date'] ?? '22 October 2026').toString();
  }

  Future<void> _fetchReceiptData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      // First check local draft in SharedPreferences
      final localDraft =
          prefs.getString('payment_receipt_${widget.applicationId}');
      if (localDraft != null) {
        final decoded = json.decode(localDraft);
        if (decoded is Map<String, dynamic>) {
          _applyDataToControllers(decoded);
        }
      }

      // Sync verified company details from server
      if (token != null && token.isNotEmpty) {
        final response = await http.post(
          Uri.parse(AppUrl.applicationPaymentReceipt),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'application_id': widget.applicationId,
          }),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final resJson = json.decode(response.body);
          if (resJson['success'] == true && resJson['data'] != null) {
            final receipt = resJson['data']['receipt'];
            if (receipt is Map<String, dynamic>) {
              _applyDataToControllers(receipt);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Receipt sync error (using cached company data): $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyDataToControllers(Map<String, dynamic> data) {
    if (data['amount'] != null && data['amount'].toString().isNotEmpty) {
      _amountController.text =
          data['amount'].toString().replaceAll(RegExp(r'[^\d.,]'), '');
    }
    if (data['payment_mode'] != null &&
        data['payment_mode'].toString().isNotEmpty) {
      final mode = data['payment_mode'].toString();
      if (_paymentModeOptions.contains(mode)) {
        _paymentMode = mode;
      }
    }
    if (data['transaction_ref_no'] != null &&
        data['transaction_ref_no'].toString().isNotEmpty) {
      _txnRefController.text = data['transaction_ref_no'].toString();
    }
    if (data['result_date'] != null &&
        data['result_date'].toString().isNotEmpty) {
      _resultDateController.text = data['result_date'].toString();
    }
    if (data['name'] != null && data['name'].toString().isNotEmpty) {
      _nameController.text = data['name'].toString();
    }
    if (data['contact_no'] != null &&
        data['contact_no'].toString().isNotEmpty) {
      _contactNoController.text = data['contact_no'].toString();
    }
    if (data['email'] != null && data['email'].toString().isNotEmpty) {
      _emailController.text = data['email'].toString();
    }
    if (data['ticket_id'] != null && data['ticket_id'].toString().isNotEmpty) {
      _ticketIdController.text = data['ticket_id'].toString();
    }
    if (data['relationship_manager'] != null &&
        data['relationship_manager'].toString().isNotEmpty) {
      _relationshipManagerController.text =
          data['relationship_manager'].toString();
    }
  }

  Future<void> _downloadReceiptPdf() async {
    setState(() {
      _isDownloading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: const [
              CircularProgressIndicator(color: _gold),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Generating official PDF receipt...',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final queryParams = {
        'application_id': widget.applicationId.toString(),
        'amount': _amountController.text.trim(),
        'payment_mode': _paymentMode,
        'transaction_ref_no': _txnRefController.text.trim(),
        'result_date': _resultDateController.text.trim(),
        'name': _nameController.text.trim(),
        'contact_no': _contactNoController.text.trim(),
        'email': _emailController.text.trim(),
        'ticket_id': _ticketIdController.text.trim(),
        'relationship_manager': _relationshipManagerController.text.trim(),
      };

      final uri = Uri.parse(AppUrl.downloadPaymentReceipt)
          .replace(queryParameters: queryParams);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final response = await http.get(
        uri,
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      ).timeout(const Duration(seconds: 20));

      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close downloading dialog
      }

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final dir = await getApplicationDocumentsDirectory();
        final cleanTicket = _ticketIdController.text
            .trim()
            .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
        final filePath =
            '${dir.path}/ABR_Greens_Receipt_${cleanTicket.isNotEmpty ? cleanTicket : widget.applicationId}.pdf';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (!mounted) return;
        Utils.flushBarSuccessMessage(
            'Official receipt downloaded successfully!', context);

        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          debugPrint('OpenFilex status: ${result.message}');
        }
      } else {
        throw Exception('Server returned status ${response.statusCode}');
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (!mounted) return;
      Utils.flushBarErrorMessage(
          'Could not download PDF from server. Please check your connection.',
          context);
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _txnRefController.dispose();
    _resultDateController.dispose();
    _nameController.dispose();
    _contactNoController.dispose();
    _emailController.dispose();
    _ticketIdController.dispose();
    _relationshipManagerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Official Payment Receipt', style: appThemeTextWhiteC),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: appBarGradient),
        ),
        actions: [
          IconButton(
            tooltip: 'Download Receipt (PDF)',
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: _isDownloading ? null : _downloadReceiptPdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _gold),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
              child: Column(
                children: [
                  _buildActionBanner(),
                  const SizedBox(height: 16),
                  _buildOfficialPaperDocument(),
                  const SizedBox(height: 24),
                  _buildDownloadFooterButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildActionBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: _goldDark, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Official verified receipt issued by ABR Greens Infrastructure for ISCDP. Authorized and signed by company management.',
              style: TextStyle(
                color: Colors.brown[900],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficialPaperDocument() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Stack(
        children: [
          // Corner crop marks
          const Positioned(
              top: 10, left: 10, child: _CropMark(corner: _Corner.topLeft)),
          const Positioned(
              top: 10, right: 10, child: _CropMark(corner: _Corner.topRight)),
          const Positioned(
              bottom: 10,
              left: 10,
              child: _CropMark(corner: _Corner.bottomLeft)),
          const Positioned(
              bottom: 10,
              right: 10,
              child: _CropMark(corner: _Corner.bottomRight)),

          // Paper Document Content
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 36, 26, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Greetings
                const Text(
                  'Greetings from ABR Greens Infrastructure,',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Main Receipt Paragraph with Company Filled Blanks
                RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 13,
                      height: 1.6,
                      color: Color(0xFF1E293B),
                    ),
                    children: [
                      const TextSpan(text: 'Received with thanks Rs. '),
                      TextSpan(
                        text: _amountController.text.trim().isNotEmpty
                            ? '₹ ${_amountController.text.trim()}'
                            : '₹ 51,000',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: Colors.black,
                        ),
                      ),
                      const TextSpan(text: ' /- via (Cash/ UPI/Online/Paytm) '),
                      TextSpan(
                        text: _paymentMode,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: Colors.black,
                        ),
                      ),
                      const TextSpan(
                          text: ' Transaction / Reference No. /Cheque No. '),
                      TextSpan(
                        text: _txnRefController.text.trim().isNotEmpty
                            ? _txnRefController.text.trim()
                            : 'TXN-ISCDP-98214',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: Colors.black,
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' For participating in Industrial Smart City Development Plan (ISCDP), to avail special benefits on your investment with ABR Greens Infrastructure.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. The 5 Recipient Parameters
                _buildParameterRow('Name:', _nameController.text.trim()),
                _buildParameterRow(
                    'Contact No:', _contactNoController.text.trim()),
                _buildParameterRow('Email:', _emailController.text.trim()),
                _buildParameterRow(
                    'Ticket ID:', _ticketIdController.text.trim()),
                _buildParameterRow(
                  'Relationship Manager:',
                  _relationshipManagerController.text.trim(),
                  isFifth: true,
                ),
                const SizedBox(height: 22),

                // 4. Selection Wish & Result Date
                RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF1E293B),
                    ),
                    children: [
                      const TextSpan(
                        text:
                            'Our team wishes you good luck for selection under Industrial Smart City Development Plan (ISCDP). The results will be declared on ',
                      ),
                      TextSpan(
                        text: _resultDateController.text.trim().isNotEmpty
                            ? _resultDateController.text.trim()
                            : '22 October 2026',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: Colors.black,
                        ),
                      ),
                      const TextSpan(
                        text: ' between 5:00 PM to 6:00 PM.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 52),

                // 5. Signatures Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "(Customer's Signature)",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      "(Manager's Signature)",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 6. Note Box
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFFCBD5E1),
                        width: 0.8,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Note: [In case of no allotment in the scheme, the registration amount is completely refundable. However, in case participant wants to withdraw from scheme after allotment in the scheme, the company is not liable for refund of registration fees. A system generated invoice will be later mailed to your registered E-mail ID and by post to your communication address.]',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 8.5,
                      height: 1.35,
                      color: Color(0xFF64748B),
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

  Widget _buildParameterRow(String label, String value, {bool isFifth = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 165,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: isFifth ? _goldDark : const Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color:
                    isFifth ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadFooterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isDownloading ? null : _downloadReceiptPdf,
        style: ElevatedButton.styleFrom(
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: _isDownloading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.picture_as_pdf_rounded, color: _gold),
        label: Text(
          _isDownloading
              ? 'Downloading PDF...'
              : 'Download Official Receipt (PDF)',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// Corner Crop Mark Widget for authentic document feel
enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

class _CropMark extends StatelessWidget {
  final _Corner corner;
  const _CropMark({required this.corner});

  @override
  Widget build(BuildContext context) {
    const size = 16.0;
    const thickness = 1.4;
    const color = Color(0xFF888888);

    Border border;
    switch (corner) {
      case _Corner.topLeft:
        border = const Border(
          top: BorderSide(color: color, width: thickness),
          left: BorderSide(color: color, width: thickness),
        );
        break;
      case _Corner.topRight:
        border = const Border(
          top: BorderSide(color: color, width: thickness),
          right: BorderSide(color: color, width: thickness),
        );
        break;
      case _Corner.bottomLeft:
        border = const Border(
          bottom: BorderSide(color: color, width: thickness),
          left: BorderSide(color: color, width: thickness),
        );
        break;
      case _Corner.bottomRight:
        border = const Border(
          bottom: BorderSide(color: color, width: thickness),
          right: BorderSide(color: color, width: thickness),
        );
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(border: border),
    );
  }
}
