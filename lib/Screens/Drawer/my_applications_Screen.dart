import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../Constants/colors.dart';
import '../../Constants/constants.dart';
import '../../Constants/reusable_widgets.dart';
import '../../res/app_urls.dart';
import '../single_application_screen.dart';
import 'receipt_screen.dart';

class MyApplicationScreen extends StatefulWidget {
  final String item;
  const MyApplicationScreen({super.key, required this.item});

  @override
  State<MyApplicationScreen> createState() => _MyApplicationScreenState();
}

class _MyApplicationScreenState extends State<MyApplicationScreen> {
  // Theme palette
  static const Color luxuryGold = Color(0xFFD4AF37);
  static const Color brightGold = Color(0xFFF3C759);
  static const Color deepGold = Color(0xFFAA8012);
  static const Color deepNavySlate = Color(0xFF0F172A);
  static const Color surfaceBg = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color emeraldVerified = Color(0xFF10B981);
  static const Color amberPending = Color(0xFFF59E0B);
  static const Color redRejected = Color(0xFFEF4444);

  List<dynamic> _applicationsList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCustomerApplications();
  }

  Future<void> fetchCustomerApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final response = await http.post(
        Uri.parse(AppUrl.customerApplications),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 12));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> apps = decoded['data']?['applications'] ?? [];
        setState(() {
          _applicationsList = apps;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Server error (${response.statusCode})';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network connection error: $e';
        });
      }
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color textColor;
    Color borderColor;
    IconData icon;
    String label;

    final s = status.toLowerCase().trim();
    if (s.contains('accept') || s.contains('approve') || s == '1' || s == 'verified') {
      bg = emeraldVerified.withOpacity(0.12);
      textColor = const Color(0xFF059669);
      borderColor = emeraldVerified.withOpacity(0.4);
      icon = Icons.check_circle_rounded;
      label = 'Accepted / Approved';
    } else if (s.contains('reject') || s == '3') {
      bg = redRejected.withOpacity(0.12);
      textColor = const Color(0xFFDC2626);
      borderColor = redRejected.withOpacity(0.4);
      icon = Icons.cancel_rounded;
      label = 'Rejected';
    } else {
      bg = amberPending.withOpacity(0.14);
      textColor = const Color(0xFFB45309);
      borderColor = amberPending.withOpacity(0.45);
      icon = Icons.hourglass_top_rounded;
      label = 'Pending Review';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app) {
    final status = (app['status'] ?? 'Pending').toString();
    final isAccepted = status.toLowerCase().contains('accept') ||
        status.toLowerCase().contains('approve') ||
        status == '1';
    final isRejected = status.toLowerCase().contains('reject') || status == '3';
    final isPending = !isAccepted && !isRejected;

    final projectName = app['project_name']?.toString() ?? 'ABR Green Meadows Phase 1';
    final applicantName = (app['applicant_name'] ?? app['name'] ?? 'Applicant').toString();
    final appNumber = app['application_no']?.toString() ?? '#ABR-APP-${app['id']}';
    final paymentAmount = app['payment_plan_amount']?.toString() ?? '₹ 51,000 (Booking Token)';
    final refId = app['ref_id']?.toString() ?? 'ABR-${app['id']}';
    final date = app['created_at'] != null
        ? app['created_at'].toString().split('T')[0]
        : 'Recent Application';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAccepted
              ? emeraldVerified.withOpacity(0.3)
              : isPending
                  ? luxuryGold.withOpacity(0.35)
                  : borderLight,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleApplicationScreen(app['id'].toString()),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner: Project Applied For & Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isAccepted
                      ? emeraldVerified.withOpacity(0.04)
                      : isPending
                          ? luxuryGold.withOpacity(0.06)
                          : const Color(0xFFF1F5F9),
                  border: const Border(
                    bottom: BorderSide(color: borderLight, width: 1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: appBarGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'APPLIED PROPERTY',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: deepGold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            projectName,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(status),
                  ],
                ),
              ),

              // Details Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Applicant & Ref Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Applicant Name',
                              style: TextStyle(fontSize: 12, color: textSecondary),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              applicantName,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Application ID',
                              style: TextStyle(fontSize: 12, color: textSecondary),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: deepNavySlate.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                appNumber,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: deepNavySlate,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1, color: borderLight),
                    const SizedBox(height: 12),

                    // Payment & Verification Details
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: surfaceBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderLight),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 20,
                            color: isAccepted ? emeraldVerified : isPending ? deepGold : textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  paymentAmount,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Receipt Ref: $refId • $date',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isAccepted
                                  ? emeraldVerified.withOpacity(0.12)
                                  : isPending
                                      ? amberPending.withOpacity(0.14)
                                      : redRejected.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isAccepted
                                  ? 'Verified'
                                  : isPending
                                      ? 'Payment Verification'
                                      : 'Rejected',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isAccepted
                                    ? const Color(0xFF059669)
                                    : isPending
                                        ? const Color(0xFFB45309)
                                        : const Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Dynamic Status Notice & Actions
                    if (isPending) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Application & payment under developer verification. Once approved, status changes to Accepted.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF92400E),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (isAccepted) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReceiptScreen(item: 'RECEIPT'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.receipt_rounded, size: 16),
                              label: const Text('View Receipt'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: deepNavySlate,
                                foregroundColor: brightGold,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SingleApplicationScreen(app['id'].toString()),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.file_download_outlined, size: 16),
                              label: const Text('Allotment'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF059669),
                                side: const BorderSide(color: Color(0xFF059669)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (isRejected) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This application was rejected during verification. Please contact support.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF991B1B),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        centerTitle: false,
        title: Text('My Applications', style: appThemeTextWhiteC),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appBarGradient),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Applications',
            onPressed: fetchCustomerApplications,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF06326)),
            )
          : RefreshIndicator(
              color: const Color(0xFFF06326),
              onRefresh: fetchCustomerApplications,
              child: _applicationsList.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: luxuryGold.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.assignment_outlined,
                                  size: 48,
                                  color: deepGold,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                _errorMessage.isNotEmpty ? 'Unable to Load Applications' : 'No Applications Found',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  _errorMessage.isNotEmpty
                                      ? _errorMessage
                                      : 'You have not submitted any property allotment applications yet.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: deepNavySlate,
                                  foregroundColor: brightGold,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text(
                                  'Explore Projects & Apply',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _applicationsList.length,
                      itemBuilder: (context, index) {
                        return _buildApplicationCard(
                          _applicationsList[index] as Map<String, dynamic>,
                        );
                      },
                    ),
            ),
    );
  }
}
