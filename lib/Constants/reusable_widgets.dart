import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:property_project/Screens/Auth%20Screen/login_screen.dart';
import 'package:property_project/Screens/Drawer/lucky_draw_screen.dart';
import 'package:property_project/Screens/Drawer/my_applications_Screen.dart';
import 'package:property_project/Screens/Drawer/receipt_screen.dart';
import 'package:property_project/Screens/home_screen.dart';
import 'package:property_project/Screens/lucky_draw_results.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../Screens/Drawer/aboutus_screen.dart';
import '../Screens/Drawer/contact_us_screen.dart';
import '../Screens/Drawer/payment_screen.dart';
import '../Screens/Drawer/profile_screen.dart';
import '../Screens/create_visit_screen.dart';
import '../Screens/referals_screen.dart';
import '../Screens/resale_screen.dart';
import '../res/app_urls.dart';
import 'colors.dart';

class AppDrawer extends StatefulWidget {
  AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isDrawDeclared = true;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkDrawDeclaredStatus();
  }

  Future<void> _checkDrawDeclaredStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';
      final res = await http.post(
        Uri.parse(AppUrl.luckyDrawResults),
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final status = data['data']?['draw_status']?.toString() ?? data['data']?['status']?.toString();
        final declared = data['data']?['results_declared'] == true || status == 'declared';
        if (mounted && _isDrawDeclared != declared) {
          setState(() {
            _isDrawDeclared = declared;
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final List<String> drawerItems = [
      'Home',
      'MY PROFILE',
      'MY APPLICATIONS',
      'LUCKY DRAW',
      if (_isDrawDeclared) 'DRAW DECLARED',
      'CONTACT US',
      'PAYMENT DETAILS',
      'ABOUT US',
      'REFERALS',
      'RESALE',
      'SITE VISIT',
      'SIGN OUT',
    ];

    final List<IconData> drawerIcons = [
      Icons.home,
      Icons.person_outline,
      Icons.apps,
      Icons.redeem,
      if (_isDrawDeclared) Icons.emoji_events_rounded,
      Icons.headphones,
      Icons.attach_money,
      Icons.error_outline,
      Icons.person_add,
      Icons.swap_horiz,
      Icons.location_on,
      Icons.logout_outlined,
    ];

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(gradient: appBarGradient),
            child: Image(image: AssetImage('assets/images/drawer.png')),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 0),
              itemCount: drawerItems.length,
              itemBuilder: (context, index) {
                final itemTitle = drawerItems[index];
                return ListTile(
                  selectedTileColor: selectedColor,
                  leading: Icon(
                    drawerIcons[index],
                    color: itemTitle == 'DRAW DECLARED' ? const Color(0xFFE7AA33) : null,
                  ),
                  title: Text(
                    itemTitle,
                    style: itemTitle == 'DRAW DECLARED'
                        ? const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                            letterSpacing: 0.3,
                          )
                        : null,
                  ),
                  selected: selectedIndex == index,
                  onTap: () {
                    setState(() {
                      selectedIndex = index; // Update the selected index
                    });
                    if (itemTitle == 'Home') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                    item: itemTitle,
                                  )));
                    } else if (itemTitle == 'MY PROFILE') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                    item: itemTitle,
                                  )));
                    } else if (itemTitle == 'MY APPLICATIONS') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyApplicationScreen(
                                    item: itemTitle,
                                  )));
                    } else if (itemTitle == 'LUCKY DRAW') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LuckyDrawScreen(
                                    item: itemTitle,
                                  )));
                    } else if (itemTitle == 'DRAW DECLARED') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LuckyDrawResult()));
                    } else if (itemTitle == 'CONTACT US') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ContactUsScreen()));
                    } else if (itemTitle == 'PAYMENT DETAILS') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                    item: itemTitle,
                                  )));
                    } else if (itemTitle == 'ABOUT US') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutUsScreen(
                                    item: itemTitle,
                                  )));
                    } else if (itemTitle == 'REFERALS') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReferalsScreen()));
                    } else if (itemTitle == 'RESALE') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ResaleScreen()));
                    } else if (itemTitle == 'SITE VISIT') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateVisitScreen()));
                    } else if (itemTitle == 'SIGN OUT') {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Logout'),
                            content: Text('Do you want to logout?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Confirm'),
                                onPressed: () {
                                  _signOut(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                      child:
                      Text('Logout');
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerEffect extends StatelessWidget {
  double height;
  double width;
  ShimmerEffect({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: redC,
      highlightColor: redC,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.grey.withOpacity(0.9)),
      ),
    );
  }
}

Future<void> _signOut(BuildContext context) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.remove('accessToken');

  Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
}
