import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../res/app_urls.dart';

Future<void> sendTokenToServer(String fcmToken) async {
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('accessToken');
  
  final url = Uri.parse(AppUrl.fcmtokenPush); 
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  final body = jsonEncode({'fcm_token': fcmToken});
  
  try {
    
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print('Token sent successfully to server.');
      print("Under the function: $body");
    } else {
      print('Failed to send token to server. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error sending token to server: $error');
  }
}




Future<void> backgroundHandler(RemoteMessage message) async {
  print("Background Message: ${message.notification?.body}");
  // Handle the background notification here
}

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
    'high_important_channel', // Channel ID
    'High Important Notification', // Channel name
    description:
        'This channel is used to handle foreground notifications of the app.', // Channel description
    importance: Importance.high,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future initLocalNotifications() async{
    // const iOS = IOSInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/launcher_icon');
    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(
      settings
    );
  }

  Future<void> initialize() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    final fcmToken = await _firebaseMessaging.getToken();
    initLocalNotifications();
    print("fcToken: $fcmToken and Settings: $settings");

    FirebaseMessaging.onBackgroundMessage(backgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/launcher_icon',
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message clicked!");
      // Handle navigation or other actions here
    });
  }


  Future<void> pushFCM() async {
    print("called from login for token push");
    final fcmToken = await _firebaseMessaging.getToken();
    await sendTokenToServer(fcmToken!);
  }

}
