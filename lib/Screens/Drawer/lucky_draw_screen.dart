import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constants/colors.dart';
import '../../Constants/constants.dart';
import '../../Constants/reusable_widgets.dart';
import '../../res/app_urls.dart';
import '../Classes/lucky_draw.dart';
import '../lucky_draw_results.dart';

class LuckyDrawScreen extends StatefulWidget {
  final String? item;

  const LuckyDrawScreen({super.key, this.item});

  @override
  State<LuckyDrawScreen> createState() => _LuckyDrawScreenState();
}

class _LuckyDrawScreenState extends State<LuckyDrawScreen> {
  static const _gold = Color(0xFFE7AA33);
  static const _darkGold = Color(0xFF9B5A13);
  static const _navy = Color(0xFF1D2B38);
  static const _muted = Color(0xFF737B83);
  static const _paleGold = Color(0xFFFFF8EA);

  Timer? _timer;
  int _remainingSeconds = 0;
  String nextDrawDate = '22 October 2026 5:00 PM';
  List<LuckyDraw> luckyDrawList = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Sign in to load live Lucky Draw details and winners.');
      }

      final response = await http
          .post(
            Uri.parse(AppUrl.luckyDrawResults),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw Exception('Sign in again to load live Lucky Draw details.');
        }
        throw Exception(
          'Could not load live Lucky Draw details (HTTP ${response.statusCode}).',
        );
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic> ||
          decoded['success'] != true ||
          decoded['data'] is! Map<String, dynamic>) {
        throw Exception('The lucky draw response was invalid.');
      }

      final data = decoded['data'] as Map<String, dynamic>;
      final timerValue = data['drawTimer'];
      final rawWinners = data['luckyDraws'];
      final winners = rawWinners is List
          ? rawWinners
              .whereType<Map<String, dynamic>>()
              .map(LuckyDraw.fromJson)
              .toList()
          : <LuckyDraw>[];

      if (!mounted) return;
      setState(() {
        _remainingSeconds = timerValue is int
            ? timerValue
            : int.tryParse(timerValue?.toString() ?? '') ?? 0;
        nextDrawDate =
            data['next_draw_date']?.toString() ?? '22 October 2026 5:00 PM';
        luckyDrawList = winners;
        _isLoading = false;
      });
      _startCountdown();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        final drawDate = DateTime.parse('2026-10-22T17:00:00+05:30').toLocal();
        _remainingSeconds = drawDate.isAfter(DateTime.now())
            ? drawDate.difference(DateTime.now()).inSeconds
            : 0;
        _isLoading = false;
        _loadError = error.toString().replaceFirst('Exception: ', '');
      });
      _startCountdown();
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    if (_remainingSeconds <= 0) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _remainingSeconds <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  Widget _buildCountdownTile(int value, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 78),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: _paleGold,
              border: Border.all(color: const Color(0xFFF1CF85), width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value.toString().padLeft(2, '0'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _navy,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    final days = _remainingSeconds ~/ Duration.secondsPerDay;
    final hours = (_remainingSeconds % Duration.secondsPerDay) ~/
        Duration.secondsPerHour;
    final minutes = (_remainingSeconds % Duration.secondsPerHour) ~/
        Duration.secondsPerMinute;
    final seconds = _remainingSeconds % Duration.secondsPerMinute;
    final values = [days, hours, minutes, seconds];
    const labels = ['DAYS', 'HOURS', 'MINS', 'SECS'];

    return Row(
      children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                ':',
                style: TextStyle(
                  color: _gold,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          _buildCountdownTile(values[i], labels[i]),
        ],
      ],
    );
  }

  Widget _buildGiftIllustration() {
    return SizedBox(
      height: 204,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SunburstPainter(),
            ),
          ),
          const Positioned(
            top: 22,
            left: 30,
            child: Icon(Icons.auto_awesome, color: _gold, size: 20),
          ),
          const Positioned(
            top: 46,
            right: 32,
            child: Icon(Icons.auto_awesome, color: _gold, size: 17),
          ),
          const Positioned(
            top: 74,
            left: 66,
            child: Icon(Icons.star_rounded, color: Color(0xFFF4D791), size: 17),
          ),
          const Positioned(
            top: 32,
            right: 76,
            child: Icon(Icons.star_rounded, color: Color(0xFFF4D791), size: 15),
          ),
          Positioned(
            bottom: 17,
            child: Container(
              width: 174,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE3A2), Color(0xFFD68B20)],
                ),
                borderRadius: BorderRadius.circular(80),
              ),
            ),
          ),
          Positioned(
            bottom: 42,
            child: Container(
              width: 128,
              height: 91,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEBD4A8), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F75450A),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(width: 18, color: _gold),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Container(height: 12, color: _gold),
                  ),
                  const Positioned(
                    top: -25,
                    child: Icon(
                      Icons.card_giftcard_rounded,
                      color: Color(0xFFBC7619),
                      size: 56,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 122,
            child: Container(
              width: 142,
              height: 22,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE9BD), Color(0xFFD89027)],
                ),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFC17D22)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyDrawCard() {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 16, 18, 28),
          padding: EdgeInsets.all(screenWidth < 380 ? 16 : 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFF0D291), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14A86E16),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGiftIllustration(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C5A09), Color(0xFFC98918)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x248D570B),
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars_rounded, color: Color(0xFFFFD977), size: 19),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'NEXT MEGA LUCKY DRAW',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFFE19A),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_available, color: _navy, size: 23),
                  const SizedBox(width: 9),
                  Flexible(
                    child: Text(
                      nextDrawDate,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 27),
              _buildCountdown(),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 17),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7EA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_florist, color: _gold, size: 28),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'Best of Luck',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _darkGold,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(width: 7),
                        Icon(Icons.auto_awesome, color: _gold, size: 24),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      'May this lucky draw bring you a big surprise!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadErrorNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0D291)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: _darkGold, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              _loadError!,
              style: const TextStyle(color: _darkGold, fontSize: 12),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Retry',
            onPressed: fetchData,
            icon: const Icon(Icons.refresh, color: _darkGold, size: 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Lucky Draw', style: appThemeTextWhiteC),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: appBarGradient),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Lucky Draw',
            onPressed: fetchData,
          ),
          IconButton(
            icon: const Icon(Icons.view_list_rounded, color: Colors.white),
            tooltip: 'View Winners',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LuckyDrawResult(luckyDrawList),
                ),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(
              painter: _BottomWavesPainter(),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: _gold),
            )
          else
            RefreshIndicator(
              color: _gold,
              onRefresh: fetchData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 180),
                children: [
                  if (_loadError != null) _buildLoadErrorNotice(),
                  _buildLuckyDrawCard(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SunburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.55);
    final paint = Paint()
      ..color = const Color(0xFFFFF8EA)
      ..style = PaintingStyle.fill;
    const rays = 24;
    for (var i = 0; i < rays; i++) {
      final startAngle = (i * 2 * 3.141592653589793 / rays) - 0.07;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + size.width * 0.54 * math.cos(startAngle),
          center.dy + size.height * math.sin(startAngle),
        )
        ..lineTo(
          center.dx + size.width * 0.54 * math.cos(startAngle + 0.07),
          center.dy + size.height * math.sin(startAngle + 0.07),
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) => false;
}

class _BottomWavesPainter extends CustomPainter {
  const _BottomWavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.91)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.85,
        size.width * 0.38,
        size.height * 0.98,
        size.width * 0.64,
        size.height * 0.92,
      )
      ..cubicTo(
        size.width * 0.79,
        size.height * 0.89,
        size.width * 0.89,
        size.height * 0.86,
        size.width,
        size.height * 0.90,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFF4DF));

    final secondWave = Path()
      ..moveTo(0, size.height * 0.96)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.90,
        size.width * 0.48,
        size.height,
        size.width * 0.73,
        size.height * 0.95,
      )
      ..cubicTo(
        size.width * 0.85,
        size.height * 0.93,
        size.width * 0.93,
        size.height * 0.91,
        size.width,
        size.height * 0.94,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(secondWave, Paint()..color = const Color(0xFFFFE8BE));
  }

  @override
  bool shouldRepaint(covariant _BottomWavesPainter oldDelegate) => false;
}
