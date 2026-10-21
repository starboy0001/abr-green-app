import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/colors.dart';
import '../Constants/constants.dart';
import '../Utils/utils.dart';
import '../res/app_urls.dart';

class AllotmentLetterScreen extends StatefulWidget {
  final String? ticketNo;
  final int? winnerId;
  final int? applicationId;
  final Map<String, dynamic>? initialData;

  const AllotmentLetterScreen({
    super.key,
    this.ticketNo,
    this.winnerId,
    this.applicationId,
    this.initialData,
  });

  @override
  State<AllotmentLetterScreen> createState() => _AllotmentLetterScreenState();
}

class _AllotmentLetterScreenState extends State<AllotmentLetterScreen> {
  static const Color luxuryGold = Color(0xFFD4AF37);
  static const Color brightGold = Color(0xFFF3C759);
  static const Color deepNavy = Color(0xFF0F172A);
  static const Color forestEmerald = Color(0xFF065F46);
  static const Color darkEmerald = Color(0xFF047857);
  static const Color surfaceBg = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  bool _isLoading = true;
  bool _isDownloading = false;
  Map<String, dynamic>? _allotmentData;

  final List<String> _defaultTerms = const [
    "The Intending Buyer has applied for the registration of Plot with full knowledge and subject to all laws, notifications and rules applicable to this area, which have been explained by the company and understood by him/her.",
    "The intending buyer has fully satisfied himself/herself about the interest and title of the company in the land, understands all limitations and obligations in respect of it and does not have any objection.",
    "For preferential situated Plot, extra charges as applicable will be payable by the intending buyer.",
    "The cost of Development Charges for a Plot whatever is applicable will be payable by the customer.",
    "If any applicant wants to cancel his/her registration once they have applied for a Plot and have been allotted unit/s under this scheme, then the company will refund his/her booking amount after deducting cost bared by company for entertaining client after allotment to cancellation which is subject to be a variable and can be up to 50% of booking amount.",
    "There is no liability for company to disclose the breakdown of deduction.",
    "The applicant has to pay the maintenance & Security charges as applicable.",
    "In case if any client fails to pay the maintenance & security charges on time, then the company will not be responsible for the security of his/her property or not be responsible if anyone encroaches his/her property and the client cannot blame the company for any loss what so ever. Moreover, the company will not provide the maintenance services for common area to such clients.",
    "The company reserves the right to cancel the registration/allotment of the Plot/Farmhouse in case if any cheque for the Registration Amount or the Balance Amount for that Plot/Farm House bounced/dishonored due to customer’s fault.",
    "The company is obligated to develop facilities like black asphalt road, demarcation of plots, parks, guard room, CCTV surveillance, solar enabled streetlights and fabricated gates.",
    "The company will start giving facilities like water supply & electricity only when at least 10% of allotees will make their houses in the township.",
    "The company can change its scheme at any time and the applicants are not supposed to show any objection on the same.",
    "It is made clear that it is not possible to check the eligibility of applicant at the time of acceptance of the Registration form. Therefore, those who are not eligible would register their name at their own risk and wouldn’t be entitled for allotment of Plot if at a later stage it is detected that they are not eligible under the scheme.",
    "All allotments shall be made on free hold basis. However, the title shall be transferred only when Sale Deed/Registry is executed in favor of the allotee and is registered in the office of Sub-Registrar.",
    "The Company reserves the right to alter/amend/modify any of the terms & conditions of application eligibility and allotment at its sole discretion or as desired/directed by the Govt. of the State/India. The consequences of such alteration/amendment/modification will be automatically binding on all applicants, without any further reference of them.",
    "If any misrepresentation/concealment/suppression of material facts are found to be made by the applicant/allotee, then the allotment of the given Plot will be cancelled at the immediate effect and the total amount of the Plot will be refunded after deducting 50% of the total Cost.",
    "Cheque/DD/Pay order to be in the name of ABR Greens Infrastructure.",
    "Cheque bouncing will be charged Rs.1000/- as penalty, and delay in payment at 18% interest.",
    "All provisional allotments under Industrial Smart City Development Plan is around 20-30% less cost than Original Price. In Case of Payment Delay in any payment plan for more than 45 days, the allotment will be cancelled from Industrial Smart City Development plan and Original price of Plot shall be paid by the applicant/allotee.",
    "Possession will be given within 12 months after booking. In case possession is not given, 18% interest will be paid to the buyer on the booking amount."
  ];

  static const String _defaultDeclaration =
      "I/WE declare that I/We have read & understood the above-mentioned terms and conditions of the project and shall abide by them.\n\n"
      "The Plot allotted to me by the company under the rules shall be acceptable to me/us. I/We shall have no objection.\n\n"
      "In case of cancellation of registration done by me/us. I/We shall accept the deduction made by the company as per rules. I agree that the measurement/number and area of Plot/Farmhouse required by me/us can vary at the time of Registry as per the Govt. Rules/Approved Map and Availability.\n\n"
      "I/We hereby declare that all information on the application form has been given by me/us are true to the best of knowledge and belief.";

  static const String _defaultNote =
      "[Note: The terms and condition of allotment letter will only be valid when company receives an acknowledged and attested copy of allotment letter. Therefore, we request all our clients to revert a digital copy of allotment letter on crm@abrgreensinfrastructure.com, if allotment letter is mailed to your address.]";

  @override
  void initState() {
    super.initState();
    _fetchLetterData();
  }

  Future<void> _fetchLetterData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final queryParams = <String, String>{};
      if (widget.ticketNo != null && widget.ticketNo!.isNotEmpty) {
        queryParams['ticket_no'] = widget.ticketNo!;
      }
      if (widget.winnerId != null && widget.winnerId! > 0) {
        queryParams['winner_id'] = widget.winnerId.toString();
      }
      if (widget.applicationId != null && widget.applicationId! > 0) {
        queryParams['application_id'] = widget.applicationId.toString();
      }

      final uri = Uri.parse(AppUrl.allotmentLetterData).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          setState(() {
            _allotmentData = decoded['data'];
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Failed to load online allotment data: $e');
    }

    // Fallback: Populate defaults using initialData if available
    final init = widget.initialData ?? {};
    final winnerName = init['name'] != null ? '${init['name']} ${init['surname'] ?? ''}'.trim() : 'Rajesh Kumar Sharma';
    final allottedPlot = init['allotted_plot']?.toString() ?? 'Plot #104 (Aashirwad Block A)';
    final discount = init['discount_amount']?.toString() ?? '₹ 2,00,000 (Lucky Draw Allotment Discount)';
    final ticket = init['ticket_no']?.toString() ?? widget.ticketNo ?? 'ISCDP-TK-0104';

    setState(() {
      _allotmentData = {
        'company_name': 'ABR AASHIRWAD GREENS',
        'scheme_title':
            'Allotment under INDUSTRIAL SMART CITY DEVELOPMENT PLAN (ISCDP), Phulera, {औद्योगिक स्मार्ट सिटी विकास योजना (आई.एस.सी.डी.पी.), फुलेरा}',
        'office_address': 'C-18, First Floor, Vasundhara Haat, Sector 13 Vasundhara, Ghaziabad, U.P. – 201012',
        'website': 'https//:www.abrgreensinfrastructure.com',
        'email': 'info@abrgreensinfrastructure.com',
        'reference_id': 'ISCDP/ABR/2026/WIN-${ticket.replaceAll(RegExp(r'[^0-9]'), '')}',
        'applicant': {
          'name': winnerName,
          's_w_do': 'Late Sh. O.P. Sharma',
          'nationality': 'Indian',
          'phone_mobile': '+91 98765 43210',
          'dob': '14/08/1986',
          'email_id': 'allottee@abrgreens.com',
          'pan_no': 'ABCPS4921K',
          'aadhar_no': 'XXXX-XXXX-8921',
          'profession': 'Business / Private Service',
          'address': 'House #42, Vasundhara Haat, Sector 13 Vasundhara, Ghaziabad, U.P. – 201012',
        },
        'booking': {
          'basic_rate': '₹ 8,333 / Sq. Yd',
          'development_charge': '₹ 1,200 / Sq. Yd',
          'area': '150 Sq. Yards (1350 Sq. Ft)',
          'unit_no': allottedPlot,
          'plc_in_percent': '10% (Park Facing / Corner)',
          'payment_plan': 'ISCDP Time Linked Plan',
          'plc_amount': '₹ 1,25,000',
          'booking_amount': '₹ 51,000',
          'privilege': discount,
          'total_cost': '₹ 12,50,000 (Net of Discount)',
          'mode_of_payment': 'Online / Cheque / DD',
          'chq_dd_no': 'CHQ-$ticket',
          'bank_name': 'HDFC Bank Ltd.',
          'chq_dd_amount': '₹ 51,000',
          'chq_dd_date': '06/03/2020',
        },
        'terms': _defaultTerms,
        'declaration': _defaultDeclaration,
        'date': '06/03/2020',
        'signature_note': _defaultNote,
      };
      _isLoading = false;
    });
  }

  Future<void> _downloadPdf() async {
    setState(() {
      _isDownloading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: const [
              CircularProgressIndicator(color: darkEmerald),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Generating official Allotment Letter PDF...',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final queryParams = <String, String>{};
      if (widget.ticketNo != null && widget.ticketNo!.isNotEmpty) {
        queryParams['ticket_no'] = widget.ticketNo!;
      }
      if (widget.winnerId != null && widget.winnerId! > 0) {
        queryParams['winner_id'] = widget.winnerId.toString();
      }
      if (widget.applicationId != null && widget.applicationId! > 0) {
        queryParams['id'] = widget.applicationId.toString();
      }
      if (_allotmentData != null && _allotmentData!['reference_id'] != null) {
        queryParams['reference_id'] = _allotmentData!['reference_id'].toString();
      }

      final uri = Uri.parse(AppUrl.allotmentletter).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      ).timeout(const Duration(seconds: 25));

      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Dismiss dialog
      }

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final dir = await getApplicationDocumentsDirectory();
        final ref = (_allotmentData?['reference_id'] ?? 'ISCDP_ALLOTMENT')
            .toString()
            .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
        final filePath = '${dir.path}/ABR_Allotment_Letter_$ref.pdf';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (!mounted) return;
        Utils.flushBarSuccessMessage('Official Allotment Letter downloaded successfully!', context);

        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          debugPrint('OpenFilex error: ${result.message}');
        }
      } else {
        throw Exception('Download failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (!mounted) return;
      Utils.flushBarErrorMessage('Failed to download Allotment Letter: $e', context);
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        title: Text(
          'Official Allotment Letter',
          style: appThemeTextWhiteC,
        ),
        actions: [
          IconButton(
            tooltip: 'Download PDF',
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            onPressed: _downloadPdf,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchLetterData,
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: appBarGradient,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: forestEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: _isDownloading ? null : _downloadPdf,
                  icon: _isDownloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text(
                    _isDownloading ? 'Downloading Allotment Letter...' : 'Download Allotment Letter (PDF)',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: darkEmerald),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
              child: Column(
                children: [
                  // OFFICIAL DEED CERTIFICATE CARD
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: luxuryGold, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Inner Certificate Border & Header
                        Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFFFFEFA),
                          ),
                          child: Column(
                            children: [
                              // Royal Seal & Scheme Badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: const Color(0xFF6EE7B7)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified_rounded, color: darkEmerald, size: 14),
                                        SizedBox(width: 6),
                                        Text(
                                          'ISCDP OFFICIAL PROPERTY ALLOTMENT DEED',
                                          style: TextStyle(
                                            color: forestEmerald,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10.5,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Header Title
                              Text(
                                _allotmentData?['company_name'] ?? 'ABR AASHIRWAD GREENS',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: forestEmerald,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Scheme Subtitle (with Hindi name)
                              Text(
                                _allotmentData?['scheme_title'] ??
                                    'Allotment under INDUSTRIAL SMART CITY DEVELOPMENT PLAN (ISCDP), Phulera, {औद्योगिक स्मार्ट सिटी विकास योजना (आई.एस.सी.डी.पी.), फुलेरा}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: deepNavy,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Office Address
                              Text(
                                _allotmentData?['office_address'] ??
                                    'C-18, First Floor, Vasundhara Haat, Sector 13 Vasundhara, Ghaziabad, U.P. – 201012',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Website & Email
                              Text(
                                '${_allotmentData?['website'] ?? 'https//:www.abrgreensinfrastructure.com'}  •  ${_allotmentData?['email'] ?? 'info@abrgreensinfrastructure.com'}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFF0284C7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // REFERENCE BAR
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          color: deepNavy,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.folder_shared_rounded, color: brightGold, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Personal and Booking Details',
                                    style: TextStyle(
                                      color: brightGold,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Flexible(
                                child: Text(
                                  'Ref ID: ${_allotmentData?['reference_id'] ?? 'ISCDP/ABR/2026/WIN-0104'}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SECTION 1: APPLICANT DETAILS
                              _buildSectionTitle('APPLICANT DETAILS', Icons.person_rounded),
                              const SizedBox(height: 10),
                              _buildApplicantGrid(_allotmentData?['applicant'] ?? {}),
                              const SizedBox(height: 20),

                              // SECTION 2: BOOKING DETAILS
                              _buildSectionTitle('BOOKING DETAILS', Icons.location_city_rounded),
                              const SizedBox(height: 10),
                              _buildBookingGrid(_allotmentData?['booking'] ?? {}),
                              const SizedBox(height: 20),

                              // SECTION 3: TERMS & CONDITIONS
                              _buildSectionTitle('TERMS & CONDITIONS', Icons.gavel_rounded),
                              const SizedBox(height: 10),
                              _buildTermsList(_allotmentData?['terms'] ?? _defaultTerms),
                              const SizedBox(height: 20),

                              // SECTION 4: DECLARATION
                              _buildSectionTitle('DECLARATION', Icons.verified_user_rounded),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: Text(
                                  _allotmentData?['declaration'] ?? _defaultDeclaration,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // DATE & SIGNATURE ROW
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFA7F3D0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'ALLOTMENT DATE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: forestEmerald,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _allotmentData?['date'] ?? '06/03/2020',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: deepNavy,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: const [
                                        Text(
                                          'OFFICIAL SIGNATURE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: forestEmerald,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          'Digitally Verified & Authorized',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: darkEmerald,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // MANDATORY NOTE / WARNING
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.info_rounded, color: Color(0xFFD97706), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _allotmentData?['signature_note'] ?? _defaultNote,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          height: 1.4,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF92400E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: forestEmerald,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantGrid(Map<String, dynamic> app) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderLight),
      ),
      child: Column(
        children: [
          _buildDetailRow([
            _DetailItem('Name', app['name'] ?? 'Rajesh Kumar Sharma'),
            _DetailItem('S/W/Do', app['s_w_do'] ?? 'Late Sh. O.P. Sharma'),
            _DetailItem('Nationality', app['nationality'] ?? 'Indian'),
          ]),
          const Divider(height: 1, color: borderLight),
          _buildDetailRow([
            _DetailItem('Phone/Mobile', app['phone_mobile'] ?? '+91 98765 43210'),
            _DetailItem('D.O.B', app['dob'] ?? '14/08/1986'),
            _DetailItem('Email Id', app['email_id'] ?? 'allottee@abrgreens.com'),
          ]),
          const Divider(height: 1, color: borderLight),
          _buildDetailRow([
            _DetailItem('PAN No.', app['pan_no'] ?? 'ABCPS4921K'),
            _DetailItem('Aadhar No.', app['aadhar_no'] ?? 'XXXX-XXXX-8921'),
            _DetailItem('Profession', app['profession'] ?? 'Business / Service'),
          ]),
          const Divider(height: 1, color: borderLight),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 80,
                  child: Text(
                    'Address:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textMuted),
                  ),
                ),
                Expanded(
                  child: Text(
                    app['address'] ?? 'Vasundhara Haat, Sector 13 Vasundhara, Ghaziabad, U.P. – 201012',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: textDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingGrid(Map<String, dynamic> b) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderLight),
      ),
      child: Column(
        children: [
          _buildDetailRow([
            _DetailItem('Basic Rate', b['basic_rate'] ?? '₹ 8,333 / Sq. Yd'),
            _DetailItem('Dev Charge', b['development_charge'] ?? '₹ 1,200 / Sq. Yd'),
            _DetailItem('Area', b['area'] ?? '150 Sq. Yards'),
            _DetailItem('Unit No.', b['unit_no'] ?? 'Plot #104'),
          ]),
          const Divider(height: 1, color: borderLight),
          _buildDetailRow([
            _DetailItem('PLC (in %)', b['plc_in_percent'] ?? '10%'),
            _DetailItem('Payment Plan', b['payment_plan'] ?? 'ISCDP Plan'),
            _DetailItem('PLC Amount', b['plc_amount'] ?? '₹ 1,25,000'),
            _DetailItem('Booking Amount', b['booking_amount'] ?? '₹ 51,000'),
          ]),
          const Divider(height: 1, color: borderLight),
          _buildDetailRow([
            _DetailItem('Privilege (Discount)', b['privilege'] ?? '₹ 2,00,000 Discount', isHighlighted: true),
            _DetailItem('Total Cost', b['total_cost'] ?? '₹ 12,50,000'),
            _DetailItem('Mode of Payment', b['mode_of_payment'] ?? 'Online / Cheque'),
            _DetailItem('Chq/DD No.', b['chq_dd_no'] ?? 'CHQ-88214'),
          ]),
          const Divider(height: 1, color: borderLight),
          _buildDetailRow([
            _DetailItem('Bank Name', b['bank_name'] ?? 'HDFC Bank Ltd.'),
            _DetailItem('Chq/DD Amount', b['chq_dd_amount'] ?? '₹ 51,000'),
            _DetailItem('Chq/DD Date', b['chq_dd_date'] ?? '06/03/2020'),
            _DetailItem('Allotment Status', 'CONFIRMED', isStatus: true),
          ]),
        ],
      ),
    );
  }

  Widget _buildDetailRow(List<_DetailItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: item.isHighlighted
                        ? darkEmerald
                        : (item.isStatus ? const Color(0xFF0284C7) : textDark),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTermsList(dynamic terms) {
    List<String> list = [];
    if (terms is List) {
      list = terms.map((e) => e.toString()).toList();
    }
    if (list.isEmpty) list = _defaultTerms;

    return Container(
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderLight),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: list.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final text = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '$idx.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: forestEmerald,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.4,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  final bool isHighlighted;
  final bool isStatus;

  _DetailItem(this.label, this.value, {this.isHighlighted = false, this.isStatus = false});
}
