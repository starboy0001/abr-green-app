import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/colors.dart';
import '../res/app_urls.dart';
import 'Classes/lucky_draw.dart';

class LuckyDrawResult extends StatefulWidget {
  final List<LuckyDraw>? luckyDrawList;
  const LuckyDrawResult([this.luckyDrawList, Key? key]) : super(key: key);

  @override
  State<LuckyDrawResult> createState() => _LuckyDrawResultState();
}

class _LuckyDrawResultState extends State<LuckyDrawResult> {
  static const Color luxuryGold = Color(0xFFD4AF37);
  static const Color brightGold = Color(0xFFF3C759);
  static const Color deepNavy = Color(0xFF0F172A);
  static const Color cardNavy = Color(0xFF1E293B);
  static const Color emeraldDiscount = Color(0xFF10B981);
  static const Color orangeAccent = Color(0xFFF06326);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color surfaceBg = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  bool spinner = true;
  String searchQuery = '';
  List<LuckyDraw> allWinners = [];
  List<LuckyDraw> filteredLuckyDrawList = [];

  @override
  void initState() {
    super.initState();
    if (widget.luckyDrawList != null && widget.luckyDrawList!.isNotEmpty) {
      allWinners = List.from(widget.luckyDrawList!);
      filteredLuckyDrawList = allWinners;
      Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            spinner = false;
          });
        }
      });
    } else {
      _fetchDeclaredWinners();
    }
  }

  Future<void> _fetchDeclaredWinners() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';
      final response = await http.post(
        Uri.parse(AppUrl.luckyDrawResults),
        headers: {
          if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>) {
          final rawWinners = decoded['data']['luckyDraws'];
          if (rawWinners is List) {
            allWinners = rawWinners
                .whereType<Map<String, dynamic>>()
                .map(LuckyDraw.fromJson)
                .toList();
            filteredLuckyDrawList = allWinners;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching declared winners: $e');
    } finally {
      if (mounted) {
        setState(() {
          spinner = false;
        });
      }
    }
  }

  String formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      DateFormat format = DateFormat('dd MMM yyyy');
      return format.format(dateTime);
    } catch (e) {
      return dateTimeString.isNotEmpty ? dateTimeString : 'Recent';
    }
  }

  void filterLuckyDraws(String query) {
    setState(() {
      searchQuery = query;
      if (query.trim().isEmpty) {
        filteredLuckyDrawList = allWinners;
      } else {
        final q = query.toLowerCase().trim();
        filteredLuckyDrawList = allWinners.where((luckyDraw) {
          final fullName = luckyDraw.displayName.toLowerCase();
          final custom = luckyDraw.displayCustomText.toLowerCase();
          final ticket = luckyDraw.ticketNo.toLowerCase();
          final plot = luckyDraw.allottedPlot.toLowerCase();
          final proj = luckyDraw.projectName.toLowerCase();
          return fullName.contains(q) ||
              custom.contains(q) ||
              ticket.contains(q) ||
              plot.contains(q) ||
              proj.contains(q);
        }).toList();
      }
    });
  }

  Widget _buildUserImage(LuckyDraw item) {
    final hasNetworkImage = item.imageUrl.trim().isNotEmpty &&
        (item.imageUrl.startsWith('http://') ||
            item.imageUrl.startsWith('https://'));

    if (hasNetworkImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.network(
          item.imageUrl.trim(),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(item),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 56,
              height: 56,
              color: const Color(0xFFF1F5F9),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: orangeAccent),
                ),
              ),
            );
          },
        ),
      );
    }
    return _buildInitialsAvatar(item);
  }

  Widget _buildInitialsAvatar(LuckyDraw item) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: orangeAccent.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          item.initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.5,
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
        elevation: 0,
        title: const Text(
          'Draw Declared',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: appBarGradient,
          ),
        ),
      ),
      body: spinner
          ? const Center(
              child: CircularProgressIndicator(color: orangeAccent),
            )
          : Column(
              children: [
                // TOP BANNER: DRAW DECLARED STATUS & COUNT
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [deepNavy, cardNavy],
                    ),
                    border: Border(
                      bottom: BorderSide(color: luxuryGold, width: 1.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: luxuryGold.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: luxuryGold.withValues(alpha: 0.5)),
                        ),
                        child: const Icon(Icons.emoji_events_rounded, color: brightGold, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OFFICIAL LUCKY DRAW RESULTS',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: brightGold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Draw Declared (ड्रॉ डिक्लेयर्ड)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: emeraldDiscount.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: emeraldDiscount.withValues(alpha: 0.6)),
                        ),
                        child: Text(
                          '${allWinners.length} Winners',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF34D399),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: filterLuckyDraws,
                      style: const TextStyle(fontSize: 14, color: textDark),
                      decoration: InputDecoration(
                        hintText: 'Search by winner name or details...',
                        hintStyle: const TextStyle(fontSize: 13, color: textSecondary),
                        prefixIcon: const Icon(Icons.search_rounded, color: orangeAccent, size: 22),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: textSecondary),
                                onPressed: () => filterLuckyDraws(''),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ),

                // SUBTITLE COUNTER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: emeraldDiscount, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Declared Lucky Draw Winners (${filteredLuckyDrawList.length})',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // WINNERS LIST
                Expanded(
                  child: filteredLuckyDrawList.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7EA),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFF0D291), width: 1.5),
                                  ),
                                  child: Icon(
                                    searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.hourglass_top_rounded,
                                    size: 48,
                                    color: orangeAccent,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  searchQuery.isNotEmpty
                                      ? 'No winners found matching "$searchQuery"'
                                      : 'Draw Declared',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  searchQuery.isNotEmpty
                                      ? 'Try searching by a different name or details.'
                                      : 'The lucky draw results have been declared. Winner details will appear here as updated by the company.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: filteredLuckyDrawList.length,
                          itemBuilder: (context, i) {
                            final item = filteredLuckyDrawList[i];

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: borderLight, width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // SECTION 1: USER IMAGE + SECTION 2: USER NAME
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // 1. User Image
                                        _buildUserImage(item),
                                        const SizedBox(width: 14),

                                        // 2. User Name
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.displayName,
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight: FontWeight.w800,
                                                        color: textDark,
                                                        letterSpacing: 0.2,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFECFDF5),
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(color: const Color(0xFFA7F3D0)),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF059669)),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          'Winner',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.w700,
                                                            color: Color(0xFF059669),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              if (item.ticketNo.isNotEmpty)
                                                Row(
                                                  children: [
                                                    const Icon(Icons.confirmation_number_outlined, size: 13, color: textSecondary),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Ticket: ${item.ticketNo}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // SECTION 3: COMPANY CUSTOM EDITABLE TEXT (FILLED BY COMPANY)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0FDF4),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF86EFAC)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(top: 2),
                                            child: Icon(
                                              Icons.stars_rounded,
                                              color: Color(0xFF16A34A),
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              item.displayCustomText,
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF166534),
                                                height: 1.4,
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
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
