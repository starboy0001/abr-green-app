import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Constants/colors.dart';
import '../Constants/constants.dart';
import 'Classes/lucky_draw.dart';

class LuckyDrawResult extends StatefulWidget {
  final List<LuckyDraw> luckyDrawList;
  const LuckyDrawResult(this.luckyDrawList, {super.key});

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
  List<LuckyDraw> filteredLuckyDrawList = [];

  @override
  void initState() {
    super.initState();
    filteredLuckyDrawList = widget.luckyDrawList;
    Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          spinner = false;
        });
      }
    });
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
        filteredLuckyDrawList = widget.luckyDrawList;
      } else {
        final q = query.toLowerCase().trim();
        filteredLuckyDrawList = widget.luckyDrawList.where((luckyDraw) {
          final fullName = '${luckyDraw.name} ${luckyDraw.surname}'.toLowerCase();
          final plot = luckyDraw.allottedPlot.toLowerCase();
          final ticket = luckyDraw.ticketNo.toLowerCase();
          final proj = luckyDraw.projectName.toLowerCase();
          final disc = luckyDraw.discountAmount.toLowerCase();
          return fullName.contains(q) || plot.contains(q) || ticket.contains(q) || proj.contains(q) || disc.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        title: Text(
          'Plot Discount Winners',
          style: appThemeTextWhiteC,
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
                // Top Banner: Next Draw Date
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: luxuryGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: luxuryGold.withValues(alpha: 0.5)),
                        ),
                        child: const Icon(Icons.event_available_rounded, color: brightGold, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NEXT LUCKY DRAW DATE & TIME',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: brightGold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '22 October 2026 5:00 PM',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: emeraldDiscount.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: emeraldDiscount.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          '${widget.luckyDrawList.length} Winners',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF34D399),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Box
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
                        hintText: 'Search by winner name, plot, or ticket...',
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

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.discount_rounded, color: emeraldDiscount, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        'Users Awarded Plot Allotment Discounts (${filteredLuckyDrawList.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Winners List
                Expanded(
                  child: filteredLuckyDrawList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 10),
                              Text(
                                'No winners found matching "$searchQuery"',
                                style: const TextStyle(fontSize: 14, color: textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: filteredLuckyDrawList.length,
                          itemBuilder: (context, i) {
                            final item = filteredLuckyDrawList[i];
                            final initials = item.name.isNotEmpty
                                ? (item.name[0] + (item.surname.isNotEmpty ? item.surname[0] : '')).toUpperCase()
                                : 'AW';

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderLight, width: 1.1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Avatar
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF9951C9), Color(0xFFF06326)],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: orangeAccent.withValues(alpha: 0.2),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              initials,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Name & Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${item.name} ${item.surname}'.trim(),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: textDark,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on_rounded, size: 14, color: orangeAccent),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      '${item.allottedPlot} • ${item.projectName}',
                                                      style: const TextStyle(
                                                        fontSize: 12.5,
                                                        color: textSecondary,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Full Width Allotment Discount Ribbon
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: emeraldDiscount.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: emeraldDiscount.withValues(alpha: 0.35)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.discount_rounded, color: emeraldDiscount, size: 18),
                                              SizedBox(width: 8),
                                              Text(
                                                'Plot Allotment Discount',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF065F46),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            RegExp(r'₹\s*[\d,]+').firstMatch(item.discountAmount)?.group(0) ?? item.discountAmount,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF047857),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 10),
                                    const Divider(height: 1, color: borderLight),
                                    const SizedBox(height: 8),

                                    // Ticket & Status Footer
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.confirmation_number_outlined, size: 14, color: textSecondary),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Ticket: ${item.ticketNo}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: borderLight),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.verified_rounded, size: 12, color: emeraldDiscount),
                                              SizedBox(width: 4),
                                              Text(
                                                'Discount Awarded',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF334155),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
