import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/colors.dart';
import '../Constants/constants.dart';
import '../Constants/reusable_widgets.dart';
import 'payment_receipt_screen.dart';
import '../res/app_urls.dart';

class ClientApplicationDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> application;

  const ClientApplicationDetailsScreen({
    super.key,
    required this.application,
  });

  @override
  State<ClientApplicationDetailsScreen> createState() =>
      _ClientApplicationDetailsScreenState();
}

class _ClientApplicationDetailsScreenState
    extends State<ClientApplicationDetailsScreen> {
  static const _ink = Color(0xFF17233F);
  static const _muted = Color(0xFF707787);
  static const _gold = Color(0xFFB67612);
  static const _line = Color(0xFFE7E5E0);

  late String _name;
  late String _mobile;
  late String _address;
  String? _profileError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _name = (widget.application['applicant_name'] ??
            widget.application['name'] ??
            '')
        .toString();
    _mobile = (widget.application['applicant_mobile'] ??
            widget.application['mobile'] ??
            '')
        .toString();
    _address = _joinAddress([
      widget.application['applicant_address'] ?? widget.application['address'],
      widget.application['applicant_city'] ?? widget.application['city'],
      widget.application['applicant_state'] ?? widget.application['state'],
    ]);
    _fetchClientProfile();
  }

  String _joinAddress(Iterable<dynamic> parts) {
    return parts
        .map((part) => part?.toString().trim() ?? '')
        .where((part) => part.isNotEmpty)
        .toSet()
        .join(', ');
  }

  Future<void> _fetchClientProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw StateError('Please sign in again to view your details.');
      }

      final response = await http.post(
        Uri.parse(AppUrl.getProfile),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception('Client details could not be loaded.');
      }

      final decoded = json.decode(response.body);
      final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
      if (decoded is! Map<String, dynamic> ||
          decoded['success'] != true ||
          data is! Map<String, dynamic>) {
        throw const FormatException('The client details response was invalid.');
      }

      final name = '${data['name'] ?? ''} ${data['surname'] ?? ''}'.trim();
      final address = _joinAddress([
        data['address'],
        data['city'],
        data['state'],
      ]);

      if (!mounted) return;
      setState(() {
        if (name.isNotEmpty) _name = name;
        if (data['mobile']?.toString().trim().isNotEmpty == true) {
          _mobile = data['mobile'].toString().trim();
        }
        if (address.isNotEmpty) _address = address;
        _isLoading = false;
        _profileError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _profileError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _showAgentContactMessage() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.support_agent_rounded,
          color: Color(0xFFE51F35),
          size: 34,
        ),
        title: const Text('Contact Us'),
        content: const Text(
          'Please contact your agent.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF4DF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _gold, size: 24),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? 'Not available' : value,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactAction() {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _showAgentContactMessage,
          child: Ink(
            height: 174,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6F4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF2C9C7)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFFFE5E3),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: Color(0xFFE51F35),
                    size: 48,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Contact Us',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptAction() {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            final applicationId =
                int.tryParse(widget.application['id']?.toString() ?? '');
            if (applicationId == null || applicationId <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application ID is unavailable.')),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => PaymentReceiptScreen(
                  applicationId: applicationId,
                  application: widget.application,
                ),
              ),
            );
          },
          child: Ink(
            height: 174,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFAEF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _line),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFFFF0D4),
                  child: Icon(
                    Icons.description_outlined,
                    color: _gold,
                    size: 45,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Payment Receipt',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientCard() {
    final imagePath = widget.application['project_image']?.toString().trim();
    final imageUri = imagePath == null ? null : Uri.tryParse(imagePath);
    final imageUrl = imagePath == null || imagePath.isEmpty
        ? null
        : imageUri != null && imageUri.hasScheme
            ? imagePath
            : Uri.parse(AppUrl.imageBaseUrl).resolve(imagePath).toString();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8D69D), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14765C1B),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF0D898), width: 4),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: imageUrl == null
                    ? Image.asset(
                        'assets/images/unnati_greens_thumbnail.jpg',
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/images/unnati_greens_thumbnail.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Name',
                  value: _name,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 11),
                  child: Divider(height: 1, color: _line),
                ),
                _buildDetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Mobile Number',
                  value: _mobile,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 11),
                  child: Divider(height: 1, color: _line),
                ),
                _buildDetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: _address,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFC),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Details', style: appThemeTextWhiteC),
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(gradient: appBarGradient),
        ),
        actions: [
          IconButton(
            onPressed: _fetchClientProfile,
            tooltip: 'Refresh details',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _DetailsBackgroundPainter(),
                ),
              ),
            ),
            RefreshIndicator(
              color: const Color(0xFFE51F35),
              onRefresh: _fetchClientProfile,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 112, 18, 150),
                children: [
                  if (_profileError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _profileError!,
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  _buildClientCard(),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContactAction(),
                      const SizedBox(width: 16),
                      _buildReceiptAction(),
                    ],
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFFE51F35),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsBackgroundPainter extends CustomPainter {
  const _DetailsBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFF1D8);
    final topWave = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 58)
      ..cubicTo(size.width * 0.7, 88, size.width * 0.3, 36, 0, 70)
      ..close();
    canvas.drawPath(topWave, paint);

    final bottomWave = Path()
      ..moveTo(0, size.height - 178)
      ..cubicTo(
        size.width * 0.32,
        size.height - 222,
        size.width * 0.64,
        size.height - 122,
        size.width,
        size.height - 174,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(bottomWave, paint);

    final lowerWave = Path()
      ..moveTo(0, size.height - 136)
      ..cubicTo(
        size.width * 0.32,
        size.height - 180,
        size.width * 0.64,
        size.height - 80,
        size.width,
        size.height - 132,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      lowerWave,
      Paint()..color = const Color(0xFFFFF7EA),
    );
  }

  @override
  bool shouldRepaint(covariant _DetailsBackgroundPainter oldDelegate) => false;
}
