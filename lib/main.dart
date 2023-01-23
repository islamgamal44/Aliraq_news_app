import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Demo_Localization.dart';
import 'package:news/Helper/LanguageNotifier.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/Theme.dart';
import 'package:news/Home.dart';
import 'package:news/IntroPage.dart';

import 'package:news/Splash.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Helper/Constant.dart';
import 'Helper/PushNotificationService.dart';
import 'Helper/String.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();



  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(myForgroundMessageHandler);
  SharedPreferences prefs = await SharedPreferences.getInstance();

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(create: (BuildContext context) {
          String? theme = prefs.getString(APP_THEME);
          if (theme == DARK) {
            isDark = true;
            prefs.setString(APP_THEME, DARK);
          } else if (theme == LIGHT) {
            isDark = false;
            prefs.setString(APP_THEME, LIGHT);
          }

          if (theme == null || theme == "" || theme == SYSTEM) {
            prefs.setString(APP_THEME, SYSTEM);
            var brightness =
                SchedulerBinding.instance.window.platformBrightness;
            print(
                "@Start - ${brightness} & theme mode is ${ThemeMode.system} ");
            isDark = brightness == Brightness.dark;
            return ThemeNotifier(ThemeMode.system);
          }
          return ThemeNotifier(
              theme == LIGHT ? ThemeMode.light : ThemeMode.dark);
        }),
        ChangeNotifierProvider<LanguageNotifier>(
            create: (context) => LanguageNotifier()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);



  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();

    // getLanguageList();
    //streamLangController = StreamController<List<Locale>>.broadcast();
    Future<SharedPreferences> prefs = SharedPreferences.getInstance();

    prefs.then((value) {
      bool? noti = value.getBool(NOTIENABLE);
      if (noti == null || noti == true) {
        notiEnable = true;
        value.setBool(NOTIENABLE, true);
      } else {
        notiEnable = false;
        value.setBool(NOTIENABLE, false);
      }
    });
  }

  @override
  void dispose() {
    // streamLangController!.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //uiOverlayStyle
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: (isDark != null && isDark == true)
            ? Brightness.dark
            : Brightness.light,
        statusBarIconBrightness: (isDark != null && isDark == true)
            ? Brightness.light
            : Brightness.dark,
        statusBarColor: colors.transparentColor));
    //notification service
    // final pushNotificationService = PushNotificationService(_firebaseM essaging);
    // pushNotificationService.initialise();
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Consumer<LanguageNotifier>(builder: (context, data, child) {
      print("data******lan***${data.languageCode}*****${data.isRTL}");

      return MaterialApp(
        builder: (context, widget) {
          return ScrollConfiguration(
              behavior: MyBehavior(),
              child: Directionality(
                  textDirection: data.isRTL == null || data.isRTL == "0"
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  child: widget!));
        },

        title: appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: colors.primary,
          splashColor: colors.primary,
          fontFamily: 'Sarabun',
          //'Neue Helvetica',
          canvasColor: colors.bgColor,
          brightness: Brightness.light,
          scaffoldBackgroundColor: colors.bgColor,
          appBarTheme: AppBarTheme(
              elevation: 0.0,
              backgroundColor: colors.transparentColor,
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.light,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarColor: colors.transparentColor)),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: colors.primaryApp)
              .copyWith(
                  secondary: colors.primary, brightness: Brightness.light),
        ),
        darkTheme: ThemeData(
          fontFamily: 'Sarabun',
          primaryColor: colors.secondaryColor,
          splashColor: colors.primary,
          brightness: Brightness.dark,
          canvasColor: colors.darkModeColor,
          scaffoldBackgroundColor: colors.darkModeColor,
          appBarTheme: AppBarTheme(
              elevation: 0.0,
              backgroundColor: colors.transparentColor,
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.light,
                  statusBarColor: colors.transparentColor)),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: colors.primaryApp)
              .copyWith(secondary: colors.primary, brightness: Brightness.dark),
        ),
        initialRoute: '/',
        //  onGenerateRoute: Routes.onGenerateRouted,
        routes: {
          // '/': (context) => Splash(update: updateSettings),
          '/home': (context) => Home(),
          '/': (context) => Splash()
        },
        themeMode: themeNotifier.getThemeMode(),
      );
    });
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
