/*
// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'String.dart';

//notification handle in this class

class PushNotificationService {
  FirebaseMessaging _fcm;

  PushNotificationService(this._fcm);

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future initialise() async {
    if (Platform.isIOS) {
      iospermission();
    }
    _fcm.getToken();
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(myForgroundMessageHandler);
    FirebaseMessaging.onMessage.listen(myForgroundMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(myForgroundMessageHandler);
  }

  void iospermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<dynamic> myForgroundMessageHandler(
      RemoteMessage message) async {
    //print("notif content ${message}");
    if (message.data != null) {
      var data = message.data;
      var notif = message.notification;
      if (data['type'] == "default" || data['type'] == "category") {
        var title = data['title'].toString();
        var body = data['message'].toString();
        var image = data['image'];
        var payload = data["news_id"];

        if (payload == null) {
          payload = "";
        } else {
          payload = payload;
        }

        if (image != null && image != "") {
          // ||
          if (notiEnable!) {
            generateImageNotication(title, body, image, payload);
          }
        } else {
          if (notiEnable!) {
            generateSimpleNotication(title, body, payload);
          }
        }
      } else {
        */
/* var type = data['type'].toString();
        var newsId = data['news_id'].toString();
        var message = data['message']; */ /*
 //there is no other type than default OR category @ Admin Panel - so it can be considered as direct firebase notification

        //Direct Firebase Notification
        var title = notif?.title.toString();
        var msg = notif?.body.toString();
        var img = notif?.android?.imageUrl.toString();
        if (notiEnable!) {
          (img != null)
              ? generateImageNotication(title!, msg!, img, '')
              : generateSimpleNotication(title!, msg!, '');
        }
      }
    }
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static Future<void> generateImageNotication(
      String title, String msg, String image, String type) async {
    var largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    var bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    var bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: msg,
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'aliraqia.edu.iq',
      'news',
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation,
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, msg, platformChannelSpecifics, payload: type);
  }

  static Future<void> generateSimpleNotication(
      String title, String msg, String type) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'aliraqia.edu.iq',
      'news',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, msg, platformChannelSpecifics, payload: type);
  }
}
*/

import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/BreakingNews.dart';
import '../Model/News.dart';
import '../NewsDetails.dart';
import '../NewsVideo.dart';
import '../main.dart';
import 'Constant.dart';
import 'Session.dart';
import 'String.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
FirebaseMessaging messaging = FirebaseMessaging.instance;

//Future<void> backgroundMessage(RemoteMessage message) async {}
backgroundMessage(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print(
      'notification(${notificationResponse.id}) action tapped: ${notificationResponse.actionId} with payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

class PushNotificationService {
  late BuildContext context;

  PushNotificationService({required this.context});

  Future initialise() async {
    print('firebase_token->initialize===${messaging == null}==');
    iOSPermission();
    print('firebase_token->initialize=///');
    messaging.getToken();
    print('firebase_token->initialize==**');
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    /* const IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
    const MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings();*/

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        /* didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );*/
      },
    );

    /*const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);*/

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    /*flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      print("payload*****$payload");
      selectNotificationPayload(payload);
    });*/
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationPayload(notificationResponse.payload!);

            break;
          case NotificationResponseType.selectedNotificationAction:
            print(
                "notification-action-id--->${notificationResponse.actionId}==${notificationResponse.payload}");

            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: backgroundMessage,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data != null) {
        var data = message.data;
        var notif = message.notification;
        if (data['type'] == "default" || data['type'] == "category") {
          var title = data['title'].toString();
          var body = data['message'].toString();
          var image = data['image'];
          var payload = data["news_id"];

          if (payload == null) {
            payload = "";
          } else {
            payload = payload;
          }

          if (image != null && image != "") {
            if (notiEnable!) {
              generateImageNotication(title, body, image, payload);
            }
          } else {
            if (notiEnable!) {
              generateSimpleNotication(title, body, payload);
            }
          }
        } else {
          //Direct Firebase Notification
          var title = notif?.title.toString();
          var msg = notif?.body.toString();
          var img = notif?.android?.imageUrl.toString();
          if (notiEnable!) {
            (img != null)
                ? generateImageNotication(title!, msg!, img, '')
                : generateSimpleNotication(title!, msg!, '');
          }
        }
      }
    });

    messaging.getInitialMessage().then((RemoteMessage? message) async {
      bool back = await getPrefrenceBool(ISFROMBACK);
      print("message******$message");
      if (message != null && back) {
        var data = message.data;
        var notif = message.notification;
        if (data['type'] == "default" || data['type'] == "category") {
          var title = data['title'].toString();
          var body = data['message'].toString();
          var image = data['image'];
          var payload = data["news_id"];

          if (payload == null) {
            payload = "";
          } else {
            payload = payload;
          }

          if (image != null && image != "") {
            if (notiEnable!) {
              generateImageNotication(title, body, image, payload);
            }
          } else {
            if (notiEnable!) {
              generateSimpleNotication(title, body, payload);
            }
          }
        } else {
          //Direct Firebase Notification
          var title = notif?.title.toString();
          var msg = notif?.body.toString();
          var img = notif?.android?.imageUrl.toString();
          if (notiEnable!) {
            (img != null)
                ? generateImageNotication(title!, msg!, img, '')
                : generateSimpleNotication(title!, msg!, '');
          }
        }
        setPrefrenceBool(ISFROMBACK, false);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("message******$message");
      if (message.data != null) {
        var data = message.data;
        var notif = message.notification;
        if (data['type'] == "default" || data['type'] == "category") {
          var title = data['title'].toString();
          var body = data['message'].toString();
          var image = data['image'];
          var payload = data["news_id"];

          if (payload == null) {
            payload = "";
          } else {
            payload = payload;
          }

          if (image != null && image != "") {
            if (notiEnable!) {
              generateImageNotication(title, body, image, payload);
            }
          } else {
            if (notiEnable!) {
              generateSimpleNotication(title, body, payload);
            }
          }
        } else {
          //Direct Firebase Notification
          var title = notif?.title.toString();
          var msg = notif?.body.toString();
          var img = notif?.android?.imageUrl.toString();
          if (notiEnable!) {
            (img != null)
                ? generateImageNotication(title!, msg!, img, '')
                : generateSimpleNotication(title!, msg!, '');
          }
        }
      }
      setPrefrenceBool(ISFROMBACK, false);
    });
  }

  void iOSPermission() async {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  //when open dynamic link news index and id can used for fetch specific news
  Future<void> getNewsById(
    String id,
    String index,
  ) async {
    var param = {
      NEWS_ID: id,
      ACCESS_KEY: access_key,
      // ignore: unnecessary_null_comparison
      USER_ID: CUR_USERID != null && CUR_USERID != "" ? CUR_USERID : "0",
      LANGUAGE_ID: CUR_LANGUAGE_ID
    };

    var apiName = getNewsByIdApi;
    http.Response response = await http
        .post(Uri.parse(apiName), body: param, headers: headers)
        .timeout(Duration(seconds: timeOut));
    var getdata = json.decode(response.body);

    String error = getdata["error"];

    if (error == "false") {
      var data = getdata["data"];

      List<News> news = [];

      news = (data as List).map((data) => new News.fromJson(data)).toList();

      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => NewsDetails(
                model: news[0],
                index: int.parse(index),
                id: news[0].id,
                isDetails: true,
                news: [],
              )));
    }
  }

  selectNotificationPayload(String? payload) async {
    if (payload != null && payload != "") {
      debugPrint('notification payload: $payload');
      getNewsById(payload, "0");
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    }
  }
}

Future<dynamic> myForgroundMessageHandler(RemoteMessage message) async {
  setPrefrenceBool(ISFROMBACK, true);

  return Future<void>.value();
}

Future<String> _downloadAndSaveImage(String url, String fileName) async {
  var directory = await getApplicationDocumentsDirectory();
  var filePath = '${directory.path}/$fileName';
  var response = await http.get(Uri.parse(url));

  var file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<void> generateImageNotication(
    String title, String msg, String image, String type) async {
  var largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
  var bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');
  var bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: msg,
      htmlFormatSummaryText: true);
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'big text channel id', 'big text channel name',
      channelDescription: 'big text channel description',
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation);
  var platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(0, title, msg, platformChannelSpecifics, payload: type);
}

const DarwinNotificationDetails darwinNotificationDetails =
    DarwinNotificationDetails(
  categoryIdentifier: "",
);

Future<void> generateSimpleNotication(
    String title, String msg, String type) async {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your channel id', 'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker');
  //var iosDetail = const IOSNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
  await flutterLocalNotificationsPlugin
      .show(0, title, msg, platformChannelSpecifics, payload: type);
}
