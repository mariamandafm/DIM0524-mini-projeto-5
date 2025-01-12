import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
late AndroidNotificationChannel channel;

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  /// Create a [AndroidNotificationChannel] for heads up notifications

  bool isFlutterLocalNotificationsInitialized = false;

  Future<void> initNotificaction() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print('My token: ${fcmToken}');
    FirebaseMessaging.onBackgroundMessage(handlerBackgroundMessage);
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(showFlutterNotification);
  }

  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }
}

void showFlutterNotification(RemoteMessage remoteMessage) {
  print("...onMessage...");
  print("${remoteMessage.notification?.title}");
  print("${remoteMessage.notification?.body}");
  RemoteNotification? notification = remoteMessage.notification;
  AndroidNotification? android = remoteMessage.notification?.android;
  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'launch_background',
        ),
      ),
    );
  }
}

Future<void> handlerBackgroundMessage(RemoteMessage remoteMessage) async {
  print("${remoteMessage.notification?.title}");
  print("${remoteMessage.notification?.body}");
}

Future<String> uploadImageToFirebase(File img) async {
  try {
    final ref = FirebaseStorage.instance
        .ref()
        .child('places_images')
        .child('${DateTime.now()}.jpg');
    await ref.putFile(img);
    return ref.getDownloadURL();
  } catch (e) {
    print(e);
    return '';
  }
}

Future<File?> downloadImageFromFirebase(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = Uri.parse(imageUrl).pathSegments.last.split('?').first;
      final filePath = '${appDir.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(response.bodyBytes);

      print('Imagem salva em: $filePath');

      return file;
    } else {
      throw Exception('Falha ao baixar imagem: ${response.statusCode}');
    }
  } catch (e) {
    print('Erro ao baixar a imagem: $e');
    return null;
  }
}
