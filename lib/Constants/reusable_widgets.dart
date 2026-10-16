import 'package:flutter/material.dart';
import 'package:property_project/Screens/Auth%20Screen/login_screen.dart';
import 'package:property_project/Screens/Drawer/lucky_draw_screen.dart';
import 'package:property_project/Screens/Drawer/my_applications_Screen.dart';
import 'package:property_project/Screens/Drawer/receipt_screen.dart';
import 'package:property_project/Screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../Screens/Drawer/aboutus_screen.dart';
import '../Screens/Drawer/contact_us_screen.dart';
import '../Screens/Drawer/payment_screen.dart';
import '../Screens/Drawer/profile_screen.dart';
import '../Screens/create_visit_screen.dart';
import '../Screens/referals_screen.dart';
import '../Screens/resale_screen.dart';
import 'colors.dart';

class AppDrawer extends StatefulWidget {
  AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final List<String> drawerItems = [
    'Home',
    'MY PROFILE',
    'MY APPLICATIONS',
    'LUCKY DRAW',
    'CONTACT US',
    'PAYMENT DETAILS',
    'ABOUT US',
    'RECEIPT',
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
    Icons.headphones,
    Icons.attach_money,
    Icons.error_outline,
    Icons.description_outlined,
    Icons.person_add,
    Icons.swap_horiz,
    Icons.location_on,
    Icons.logout_outlined,
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
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
                return ListTile(
                  selectedTileColor: selectedColor,
                  leading: Icon(drawerIcons[index]),
                  title: Text(drawerItems[index]),
                  selected: selectedIndex == index,
                  onTap: () {
                    setState(() {
                      selectedIndex = index; // Update the selected index
                    });
                    if (index == 0) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                    item: drawerItems[index],
                                  )));
                    } else if (index == 1) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                    item: drawerItems[index],
                                  )));
                    } else if (index == 2) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyApplicationScreen(
                                    item: drawerItems[index],
                                  )));
                    } else if (index == 3) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LuckyDrawScreen(
                                    item: drawerItems[index],
                                  )));
                    } else if (index == 4) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ContactUsScreen()));
                    } else if (index == 5) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                    item: drawerItems[index],
                                  )));
                    } else if (index == 6) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutUsScreen(
                                    item: drawerItems[index],
                                  )));
                    } else if (index == 7) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReceiptScreen(
                                    item: drawerItems[index],
                                  )));
                    } else if (index == 8) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReferalsScreen()));
                    } else if (index == 9) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ResaleScreen()));
                    } else if (index == 10) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateVisitScreen()));
                    } else if (index == 11) {
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
