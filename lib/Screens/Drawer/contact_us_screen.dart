import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Constants/colors.dart';
import '../../Constants/constants.dart';
import '../../Constants/reusable_widgets.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static const _titleColor = Color(0xFF101A35);
  static const _labelColor = Color(0xFFE75325);
  static const _iconBackground = Color(0xFFFFF3E9);

  Future<void> _launch(Uri uri, BuildContext context) async {
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open this link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Contact Us', style: appThemeTextWhiteC),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: appBarGradient),
        ),
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/icon.png',
                          width: 104,
                          height: 104,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        const Flexible(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                              children: [
                                TextSpan(
                                  text: 'ABR GREENS\n',
                                  style: TextStyle(fontSize: 24),
                                ),
                                TextSpan(
                                  text: 'INFRASTRUCTURE',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: 88,
                      height: 78,
                      decoration: BoxDecoration(
                        color: _labelColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.contact_phone,
                        color: Colors.white,
                        size: 54,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Contact Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _titleColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _contactRow(
                      icon: Icons.location_on,
                      label: 'Address:',
                      value:
                          'C18, Sector 13, Vasundhara, Ghaziabad, Uttar Pradesh 201012',
                    ),
                    const SizedBox(height: 22),
                    _contactRow(
                      icon: Icons.email,
                      label: 'Email:',
                      value: 'crm.abrgreens@gmail.com',
                      onTap: () => _launch(
                        Uri(scheme: 'mailto', path: 'crm.abrgreens@gmail.com'),
                        context,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _contactRow(
                      icon: Icons.call,
                      label: 'Phone:',
                      value: '7428502666',
                      onTap: () => _launch(
                        Uri(scheme: 'tel', path: '7428502666'),
                        context,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _contactRow(
                      icon: Icons.camera_alt,
                      label: 'Instagram:',
                      value: 'abrgreensofficial',
                      iconColor: const Color(0xFFC52E9B),
                      onTap: () => _launch(
                        Uri.parse(
                          'https://www.instagram.com/abrgreensofficial/',
                        ),
                        context,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _contactRow(
                      icon: Icons.facebook,
                      label: 'Facebook:',
                      value: 'ABR Greens Infrastructure',
                      iconColor: const Color(0xFF1877F2),
                      onTap: () => _launch(
                        Uri.parse('https://www.facebook.com/'),
                        context,
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

  Widget _contactRow({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = _labelColor,
    VoidCallback? onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            color: _iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _labelColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: _titleColor,
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
