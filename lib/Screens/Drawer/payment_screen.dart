import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants/colors.dart';
import '../../Constants/constants.dart';
import '../../Constants/reusable_widgets.dart';
import '../../res/app_urls.dart';

class PaymentScreen extends StatefulWidget {
  final String item;

  const PaymentScreen({super.key, required this.item});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const _yesBankScreenshot = 'assets/images/payment_yesbank.png';
  static const _kotakScreenshot = 'assets/images/payment_kotak.png';

  String? _yesBankImageUrl;
  String? _kotakImageUrl;

  @override
  void initState() {
    super.initState();
    _loadPaymentImages();
  }

  Future<void> _loadPaymentImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null || token.isEmpty) return;

      final response = await http.post(
        Uri.parse(AppUrl.appSettings),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw Exception(
          'Payment image settings request failed (${response.statusCode}).',
        );
      }

      final decoded = json.decode(response.body);
      final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
      final settings =
          data is Map<String, dynamic> ? data['app_settings'] : null;
      if (!mounted || settings is! Map<String, dynamic>) return;
      setState(() {
        _yesBankImageUrl = settings['payment_yesbank_image_url']?.toString();
        _kotakImageUrl = settings['payment_kotak_image_url']?.toString();
      });
    } catch (error) {
      debugPrint('Payment image settings could not be loaded: $error');
    }
  }

  Widget _paymentImage(String? url, String fallbackAsset, double width) {
    if (url == null || url.trim().isEmpty) {
      return Image.asset(fallbackAsset, width: width, fit: BoxFit.fitWidth);
    }
    return Image.network(
      url,
      width: width,
      fit: BoxFit.fitWidth,
      errorBuilder: (context, error, stackTrace) =>
          Image.asset(fallbackAsset, width: width, fit: BoxFit.fitWidth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Payment Details', style: appThemeTextWhiteC),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: appBarGradient),
        ),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: 1285 / 1365,
                child: _paymentImage(
                  _yesBankImageUrl,
                  _yesBankScreenshot,
                  screenWidth,
                ),
              ),
            ),
            SizedBox(
              width: screenWidth,
              child: _paymentImage(
                _kotakImageUrl,
                _kotakScreenshot,
                screenWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
