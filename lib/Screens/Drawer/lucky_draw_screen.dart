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
  static const _emerald = Color(0xFF10B981);

  Timer? _timer;
  int _remainingSeconds = 0;
  String nextDrawDate = '22 October 2026 5:00 PM';
  List<LuckyDraw> luckyDrawList = [];
  bool _isLoading = true;
  String? _loadError;

  String _drawStatus = 'open'; // 'open', 'closed', 'declared'
  bool _resultsDeclared = false;
  bool _isClosed = false;
  String _flashMsg = '';
  String _prizeTitle = 'Up to ₹ 2,50,000 Special Discount on Plot Allotment';
  String _drawTitle = 'Plot Allotment Discount Mega Draw';

  final TextEditingController _checkTicketController = TextEditingController();
  LuckyDraw? _checkedWinner;
  bool _ticketChecked = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _checkTicketController.dispose();
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

      final statusVal = data['draw_status']?.toString() ?? data['status']?.toString() ?? 'open';
      final isDeclared = data['results_declared'] == true || statusVal == 'declared';
      final isClosedVal = data['is_closed'] == true || statusVal == 'closed' || isDeclared;

      if (!mounted) return;
      setState(() {
        _remainingSeconds = timerValue is int
            ? timerValue
            : int.tryParse(timerValue?.toString() ?? '') ?? 0;
        nextDrawDate =
            data['next_draw_date']?.toString() ?? '22 October 2026 5:00 PM';
        _drawTitle = data['next_draw_title']?.toString() ?? 'Plot Allotment Discount Mega Draw';
        _prizeTitle = data['prize_title']?.toString() ?? 'Up to ₹ 2,50,000 Special Discount on Plot Allotment';
        _flashMsg = data['flash_msg']?.toString() ?? '';
        _drawStatus = isDeclared ? 'declared' : (isClosedVal ? 'closed' : 'open');
        _resultsDeclared = isDeclared;
        _isClosed = isClosedVal;
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

  Widget _buildDrawDeclaredOption() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2ECCA033),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: _gold.withValues(alpha: 0.6)),
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    color: Color(0xFFFFD700), size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LUCKY DRAW RESULTS',
                      style: TextStyle(
                        color: Color(0xFFFFD977),
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Draw Declared (ड्रॉ डिक्लेयर्ड)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: _navy,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LuckyDrawResult(luckyDrawList),
                  ),
                );
              },
              icon: const Icon(Icons.people_alt_rounded, size: 18),
              label: Text(
                'View Declared Winners (${luckyDrawList.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkTicket() {
    final query = _checkTicketController.text.trim().toLowerCase();
    if (query.isEmpty) return;
    setState(() {
      _ticketChecked = true;
      _checkedWinner = null;
      for (final w in luckyDrawList) {
        if (w.ticketNo.toLowerCase() == query ||
            w.name.toLowerCase().contains(query) ||
            ('${w.name} ${w.surname}').toLowerCase().contains(query)) {
          _checkedWinner = w;
          break;
        }
      }
    });
  }

  Widget _buildDeclaredWinnersView() {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // GRAND CELEBRATION HERO BANNER
              Container(
                padding: EdgeInsets.all(screenWidth < 380 ? 18 : 22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_navy, Color(0xFF131D27)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _gold, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3DCCA033),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: _gold.withValues(alpha: 0.6)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 16),
                          SizedBox(width: 6),
                          Text(
                            'RESULTS DECLARED BY COMPANY COMMITTEE',
                            style: TextStyle(
                              color: Color(0xFFFFE8B2),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 54),
                    const SizedBox(height: 10),
                    Text(
                      _drawTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _prizeTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _flashMsg.isNotEmpty
                          ? _flashMsg
                          : 'Congratulations to all applicants who won direct discounts on their plot allotments!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // PRIMARY CTA: VIEW ALL WINNERS
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: _navy,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LuckyDrawResult(luckyDrawList),
                            ),
                          );
                        },
                        icon: const Icon(Icons.people_alt_rounded, size: 20),
                        label: Text(
                          '🏆 Draw Declared - View Winners (${luckyDrawList.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // TICKET CHECKER CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_rounded, color: _emerald, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Check My Plot Discount Status',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _navy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Enter your Ticket ID or Applicant Name to check your plot discount allocation:',
                      style: TextStyle(fontSize: 12, color: _muted),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _checkTicketController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'e.g. ABR-LUCKY-7821',
                              hintStyle: const TextStyle(fontSize: 13, color: _muted),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: _gold, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _navy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _checkTicket,
                          child: const Text('Check', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    if (_ticketChecked) ...[
                      const SizedBox(height: 14),
                      if (_checkedWinner != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF6EE7B7)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: _emerald, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '🎉 Congratulations! ${_checkedWinner!.name} ${_checkedWinner!.surname}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF065F46),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '• Allotted: ${_checkedWinner!.allottedPlot} (${_checkedWinner!.projectName})\n• Plot Discount: ${_checkedWinner!.discountAmount}\n• Ticket: ${_checkedWinner!.ticketNo}',
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF047857), height: 1.4),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF065F46),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LuckyDrawResult(luckyDrawList),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.people_alt_rounded, size: 16),
                                  label: const Text(
                                    '🏆 View Declared Winners List',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFCD34D)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_rounded, color: Color(0xFFD97706), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No winning plot discount recorded for "${_checkTicketController.text}". Please check your ticket number or contact your relationship manager.',
                                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF92400E)),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // RECENT WINNERS LIST TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Users Awarded Plot Discounts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _navy,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LuckyDrawResult(luckyDrawList),
                        ),
                      );
                    },
                    child: const Text('See All →', style: TextStyle(color: _darkGold, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // WINNER TILES
              for (final winner in luckyDrawList.take(5)) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LuckyDrawResult(luckyDrawList),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFE7AA33), Color(0xFF9B5A13)],
                                ),
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              alignment: Alignment.center,
                              child: winner.imageUrl.isNotEmpty
                                  ? Image.network(
                                      winner.imageUrl,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Text(
                                        winner.name.isNotEmpty ? winner.name[0].toUpperCase() : 'W',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    )
                                  : Text(
                                      winner.name.isNotEmpty ? winner.name[0].toUpperCase() : 'W',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    winner.displayName,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: _navy),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFA7F3D0)),
                                    ),
                                    child: Text(
                                      winner.displayCustomText,
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF047857), height: 1.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  winner.ticketNo,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _navy),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '✓ Awarded',
                                  style: TextStyle(fontSize: 10, color: _emerald, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawClosedUnderReviewView() {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 16, 18, 28),
          padding: EdgeInsets.all(screenWidth < 380 ? 18 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HOURGLASS / IN REVIEW ILLUSTRATION
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8EA), Color(0xFFFFEDCB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF1CF85), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1EA86E16),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.hourglass_bottom_rounded,
                  color: Color(0xFFBC7619),
                  size: 44,
                ),
              ),
              const SizedBox(height: 18),

              // STATUS BADGE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7EA),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFF0D291)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pending_actions_rounded, color: _darkGold, size: 16),
                    SizedBox(width: 7),
                    Text(
                      'DRAW CLOSED • ALLOCATIONS IN PROGRESS',
                      style: TextStyle(
                        color: _darkGold,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                _drawTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'The mega lucky draw has closed. The company allotment committee is currently evaluating registered applicants to allocate plot discounts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _muted,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),

              // COMMITTEE TIMELINE STEPPER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildTimelineRow(
                      Icons.check_circle_rounded,
                      _emerald,
                      'Draw Closed',
                      'Lucky draw entry closed on scheduled time',
                      isCompleted: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 11),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 16,
                          child: VerticalDivider(color: Color(0xFFCBD5E1), thickness: 2),
                        ),
                      ),
                    ),
                    _buildTimelineRow(
                      Icons.hourglass_top_rounded,
                      _gold,
                      'Company Committee Review',
                      'Company team is deciding and allocating plot discounts',
                      isActive: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 11),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 16,
                          child: VerticalDivider(color: Color(0xFFCBD5E1), thickness: 2),
                        ),
                      ),
                    ),
                    _buildTimelineRow(
                      Icons.circle_outlined,
                      _muted,
                      'Plot Discount Winners Announced',
                      'Winners list will be published here once approved',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // COMPANY ALLOCATION POLICY NOTE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, color: _darkGold, size: 18),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'The list of winners who receive a discount in their plot depends strictly on the company management team. Results will appear automatically here once declared.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // REFRESH STATUS BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: fetchData,
                  icon: const Icon(Icons.refresh_rounded, size: 19),
                  label: const Text(
                    'Check for Declared Winners',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineRow(IconData icon, Color color, String title, String subtitle, {bool isCompleted = false, bool isActive = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isActive ? _darkGold : (isCompleted ? _navy : _muted),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11.5, color: _muted),
              ),
            ],
          ),
        ),
      ],
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
        title: Text(
          'Lucky Draw',
          style: appThemeTextWhiteC,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: appBarGradient),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh Lucky Draw',
            onPressed: fetchData,
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
