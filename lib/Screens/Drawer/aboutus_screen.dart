import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants/colors.dart';
import '../../Constants/constants.dart';
import '../../Constants/reusable_widgets.dart';
import '../../res/app_urls.dart';

class AboutUsScreen extends StatefulWidget {
  final String item;

  const AboutUsScreen({super.key, required this.item});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  static const _navy = Color(0xFF101A35);
  static const _muted = Color(0xFF68758A);
  static const _orange = Color(0xFFEF5B24);

  String _aboutText =
      'ABR Greens Infrastructure is a real estate investment and property development company with 10+ years of industry experience, creating high-value, low-investment opportunities across India and emerging states.';

  @override
  void initState() {
    super.initState();
    _loadAboutText();
  }

  Future<void> _loadAboutText() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null || token.isEmpty) return;

      final response = await http.post(
        Uri.parse(AppUrl.about),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw Exception('About Us request failed (${response.statusCode}).');
      }

      final decoded = json.decode(response.body);
      final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
      final settings =
          data is Map<String, dynamic> ? data['app_settings'] : null;
      final aboutText =
          settings is Map<String, dynamic> ? settings['about_us'] : null;
      if (!mounted || aboutText is! String || aboutText.trim().isEmpty) return;
      setState(() => _aboutText = aboutText);
    } catch (error) {
      debugPrint('About Us content could not be loaded: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('About Us', style: appThemeTextWhiteC),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: appBarGradient),
        ),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroduction(),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                'assets/images/property.jpeg',
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
                semanticLabel: 'ABR Greens real estate and property',
              ),
            ),
            const SizedBox(height: 14),
            _buildFeatureCard(
              icon: Icons.apartment_rounded,
              title: 'REAL ESTATE',
              subtitle: 'Investment & Development',
              description:
                  'We focus on well-planned, strategically located residential and commercial plots.',
              background: const Color(0xFFFFF3F0),
              iconBackground: const Color(0xFFFFE5DE),
              iconColor: _orange,
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.emoji_events_rounded,
              title: '10+ YEARS',
              subtitle: 'Management Experience',
              description:
                  'Backed by industry experience and a dedicated team.',
              background: const Color(0xFFF5F0FC),
              iconBackground: const Color(0xFFEDE1FA),
              iconColor: const Color(0xFFAA69DB),
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.handshake_rounded,
              title: 'CUSTOMER FIRST',
              subtitle: 'Trust & Long-Term Relationships',
              description:
                  'We believe in transparent deals, clear information and lasting value.',
              background: const Color(0xFFFFF6EB),
              iconBackground: const Color(0xFFFFEAD4),
              iconColor: const Color(0xFFF17C25),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_orange, Color(0xFFFFC6B4)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              const Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: _navy,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                  children: [
                    TextSpan(text: 'WHO ARE '),
                    TextSpan(
                      text: 'WE?',
                      style: TextStyle(color: _orange),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _aboutText,
                style: TextStyle(
                  color: _muted,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 190,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 116,
                    height: 116,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF4EE),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    _Building(width: 28, height: 76),
                    SizedBox(width: 5),
                    _Building(width: 34, height: 130),
                    SizedBox(width: 5),
                    _Building(width: 27, height: 96),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color background,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 40),
          ),
          const SizedBox(width: 14),
          Container(
            width: 3,
            height: 78,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Building extends StatelessWidget {
  final double width;
  final double height;

  const _Building({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF9D9CD),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        border: Border.all(color: const Color(0xFFF3C7B7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: List.generate(
            (height / 17).floor(),
            (_) => Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(1.5),
                      color: const Color(0xFFFFF8F4),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(1.5),
                      color: const Color(0xFFFFF8F4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
