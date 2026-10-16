import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:property_project/Constants/reusable_widgets.dart';
import 'package:property_project/Screens/Drawer/my_applications_Screen.dart';
import 'package:property_project/res/app_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lucky_draw_apply_screen.dart';

class _SoldOutProject {
  final String name;
  final String image;
  final String status;

  const _SoldOutProject({
    required this.name,
    required this.image,
    this.status = 'SOLD OUT',
  });
}

class HomeScreen extends StatefulWidget {
  final String? item;

  const HomeScreen({super.key, this.item});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _pageBackground = Color(0xFFF5F6F8);
  static const _gold = Color(0xFFD7A51D);
  static const _ink = Color(0xFF20242A);
  static const _muted = Color(0xFF777D84);

  static const _soldOutProjects = [
    _SoldOutProject(
      name: 'ABR Sagar City',
      image: 'assets/images/sold_out_sagar_city.png',
    ),
    _SoldOutProject(
      name: 'Samriddhi Greens',
      image: 'assets/images/sold_out_samriddhi_greens.png',
    ),
    _SoldOutProject(
      name: 'Aashirwad Greens',
      image: 'assets/images/sold_out_aashirwad_greens.png',
    ),
    _SoldOutProject(
      name: 'ABR Udyog Nagar',
      image: 'assets/images/sold_out_udyog_nagar.jpg',
    ),
  ];

  List<_SoldOutProject> homeProjects = _soldOutProjects;
  Map<String, dynamic> appSettings = {};
  String customerName = '';
  int? profileCompletion;

  @override
  void initState() {
    super.initState();
    getHomeImages();
    getProfileData();
  }

  Future<Map<String, String>> _authorizedHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError('Please sign in to view your home page.');
    }
    return {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };
  }

  Future<void> getHomeImages() async {
    try {
      final response = await http
          .post(
            Uri.parse(AppUrl.homeImages),
            headers: await _authorizedHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;
      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
        return;
      }

      final data = decoded['data'];
      final settings =
          data is Map<String, dynamic> ? data['app_settings'] : null;
      if (!mounted || settings is! Map<String, dynamic>) return;

      final rawProjects = settings['home_projects'];
      final configuredProjects = rawProjects is List
          ? rawProjects
              .whereType<Map>()
              .map((project) {
                return _SoldOutProject(
                  name: project['name']?.toString() ?? '',
                  image: project['image']?.toString() ?? '',
                  status: project['status']?.toString() == 'AVAILABLE'
                      ? 'AVAILABLE'
                      : 'SOLD OUT',
                );
              })
              .where((project) =>
                  project.name.isNotEmpty && project.image.isNotEmpty)
              .toList()
          : null;

      setState(() {
        appSettings = settings;
        if (configuredProjects != null) homeProjects = configuredProjects;
      });
    } catch (error) {
      debugPrint('Home banner images could not be loaded: $error');
    }
  }

  Future<void> getProfileData() async {
    try {
      final response = await http
          .post(
            Uri.parse(AppUrl.getProfile),
            headers: await _authorizedHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;
      final decoded = json.decode(response.body);
      final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
      if (decoded is! Map<String, dynamic> ||
          decoded['success'] != true ||
          data is! Map<String, dynamic>) {
        return;
      }

      final name = '${data['name'] ?? ''} ${data['surname'] ?? ''}'.trim();
      final fields = [
        name,
        data['mobile'],
        data['address'],
        data['city'],
        data['state'],
        data['email'],
      ];
      final completedFields = fields.where((value) {
        return value != null && value.toString().trim().isNotEmpty;
      }).length;

      if (!mounted) return;
      setState(() {
        customerName = name;
        profileCompletion = (completedFields / fields.length * 100).round();
      });
    } catch (error) {
      debugPrint('Home profile summary could not be loaded: $error');
    }
  }

  String _dashboardImageUrl(String imagePath) {
    final uri = Uri.tryParse(imagePath);
    if (uri != null && uri.hasScheme) return imagePath;
    return Uri.parse(AppUrl.imageBaseUrl).resolve(imagePath).toString();
  }

  Widget _buildHeader() {
    final bannerPath = appSettings['dashboard_image_1']?.toString();
    final firstName = customerName.isEmpty
        ? 'Welcome'
        : customerName.split(RegExp(r'\s+')).first;
    final completion = profileCompletion;

    return SizedBox(
      height: 174,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (bannerPath != null && bannerPath.isNotEmpty)
            CachedNetworkImage(
              imageUrl: _dashboardImageUrl(bannerPath),
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            )
          else
            const SizedBox.shrink(),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xCC10243E),
                  const Color(0xAA10243E),
                  _pageBackground.withValues(alpha: 0.96),
                ],
                stops: const [0, 0.58, 1],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 16, 22),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.menu_rounded),
                      color: Colors.white,
                      iconSize: 30,
                      tooltip: 'Open menu',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFFB9C3CE),
                      size: 39,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi $firstName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Almost there!',
                          style: TextStyle(
                            color: Color(0xFFFFC928),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: completion == null ? 0 : completion / 100,
                          strokeWidth: 4,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFC928)),
                        ),
                        Text(
                          completion == null ? '--' : '$completion%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 29,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(_SoldOutProject project) {
    final cardWidth = MediaQuery.sizeOf(context).width - 40;
    final isSoldOut = project.status == 'SOLD OUT';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x160D2017),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: cardWidth,
            height: cardWidth * 0.68,
            child: ColoredBox(
              color: const Color(0xFFF1F2F0),
              child: project.image.startsWith('assets/')
                  ? Image.asset(
                      project.image,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    )
                  : CachedNetworkImage(
                      imageUrl: project.image,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Color(0xFF89928D),
                          size: 42,
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(
            height: 70,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSoldOut
                          ? const Color(0xFFFFEEEE)
                          : const Color(0xFFE9F6EC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSoldOut
                            ? const Color(0xFFF2BABA)
                            : const Color(0xFFB7DEC0),
                      ),
                    ),
                    child: Text(
                      project.status,
                      style: TextStyle(
                        color: isSoldOut
                            ? const Color(0xFFB42318)
                            : const Color(0xFF287641),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyDrawSection() {
    final imageWidth = MediaQuery.sizeOf(context).width - 40;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LuckyDrawApplyScreen(),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: imageWidth,
            height: imageWidth * 0.68,
            child: ColoredBox(
              color: const Color(0xFFF1F2F0),
              child: Image.asset(
                'assets/images/lucky_draw_promo.png',
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      drawer: AppDrawer(),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: _gold, size: 25),
                        const SizedBox(width: 9),
                        const Expanded(
                          child: Text(
                            'Trending Projects',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyApplicationScreen(
                                item: 'MY APPLICATIONS',
                              ),
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF123E7C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 12),
                            shape: const StadiumBorder(),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ownership',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Discover ABR Greens communities.',
                      style: TextStyle(color: _muted, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    ...homeProjects.map(_buildProjectCard),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildLuckyDrawSection()),
          ],
        ),
      ),
    );
  }
}
