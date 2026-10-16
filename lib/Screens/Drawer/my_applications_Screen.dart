import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants/colors.dart';
import '../../Constants/constants.dart';
import '../../Constants/reusable_widgets.dart';
import '../../res/app_urls.dart';
import '../client_application_details_screen.dart';
import '../single_application_screen.dart';
import 'receipt_screen.dart';

class MyApplicationScreen extends StatefulWidget {
  final String item;

  const MyApplicationScreen({super.key, required this.item});

  @override
  State<MyApplicationScreen> createState() => _MyApplicationScreenState();
}

class _MyApplicationScreenState extends State<MyApplicationScreen> {
  static const _surface = Color(0xFFFFFEFC);
  static const _gold = Color(0xFFD4AF37);
  static const _deepGold = Color(0xFFAA8012);
  static const _navy = Color(0xFF0F172A);
  static const _secondaryText = Color(0xFF64748B);
  static const _border = Color(0xFFE8D69D);
  static const _green = Color(0xFF059669);
  static const _red = Color(0xFFDC2626);

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
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw StateError('Please sign in to view your applications.');
      }

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
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network connection error: $error';
      });
    }
  }

  bool _isAccepted(String status) {
    final value = status.toLowerCase().trim();
    return value.contains('accept') ||
        value.contains('approve') ||
        value == '1' ||
        value == 'verified';
  }

  bool _isRejected(String status) {
    final value = status.toLowerCase().trim();
    return value.contains('reject') || value == '3';
  }

  Widget _buildStatusBadge(String status) {
    final accepted = _isAccepted(status);
    final rejected = _isRejected(status);
    final color = accepted
        ? _green
        : rejected
            ? _red
            : const Color(0xFFB45309);
    final label = accepted
        ? 'Approved'
        : rejected
            ? 'Rejected'
            : 'Pending Review';
    final icon = accepted
        ? Icons.check_circle_outline_rounded
        : rejected
            ? Icons.cancel_outlined
            : Icons.hourglass_empty_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String? _projectImageUrl(dynamic rawPath) {
    final imagePath = rawPath?.toString().trim() ?? '';
    if (imagePath.isEmpty) return null;

    final uri = Uri.tryParse(imagePath);
    if (uri != null && uri.hasScheme) return imagePath;
    return Uri.parse(AppUrl.imageBaseUrl).resolve(imagePath).toString();
  }

  Widget _buildProjectImage(Map<String, dynamic> app) {
    final imageUrl = _projectImageUrl(app['project_image']);
    final fallback = Image.asset(
      'assets/images/unnati_greens_thumbnail.jpg',
      width: 68,
      height: 68,
      fit: BoxFit.cover,
    );

    return ClipOval(
      child: SizedBox(
        width: 68,
        height: 68,
        child: imageUrl == null
            ? fallback
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app) {
    final status = (app['status'] ?? 'Pending').toString();
    final accepted = _isAccepted(status);
    final rejected = _isRejected(status);
    final applicantName =
        (app['applicant_name'] ?? app['name'] ?? 'Applicant').toString();
    final appNumber =
        app['application_no']?.toString() ?? '#ABR-APP-${app['id']}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14765C1B),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ClientApplicationDetailsScreen(application: app),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.apartment_rounded,
                      color: _deepGold,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'UNNATI GREENS',
                      style: TextStyle(
                        color: _deepGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    _buildProjectImage(app),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            applicantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Application ID  $appNumber',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _secondaryText,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(status),
                  ],
                ),
                if (accepted) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ReceiptScreen(item: 'RECEIPT'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_rounded, size: 16),
                          label: const Text('View Receipt'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _navy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                builder: (context) => SingleApplicationScreen(
                                    app['id'].toString()),
                              ),
                            );
                          },
                          icon: const Icon(Icons.file_download_outlined,
                              size: 16),
                          label: const Text('Allotment'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _green,
                            side: const BorderSide(color: _green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (rejected) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'This application was rejected. Please contact support.',
                    style: TextStyle(
                      color: _red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasError = _errorMessage.isNotEmpty;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: _deepGold,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                hasError
                    ? 'Unable to Load Applications'
                    : 'No Applications Yet',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  hasError
                      ? _errorMessage
                      : 'Your applications for Unnati Greens will appear here.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: _secondaryText,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text('My Applications', style: appThemeTextWhiteC),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: appBarGradient),
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
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 38, 16, 24),
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
