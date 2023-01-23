import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:flutter/services.dart';
//import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:http/http.dart';
import 'package:news/Helper/Widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';

class PrivacyPolicy extends StatefulWidget {
  final String? title;
  final String? from;
  final String? desc;
  const PrivacyPolicy({Key? key, this.title, this.from, this.desc}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePrivacy();
  }
}

class StatePrivacy extends State<PrivacyPolicy> with TickerProviderStateMixin {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();



  @override
  void initState() {
    super.initState();
    //getSetting();
  }

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
            key: _scaffoldKey,
            appBar: getAppBar(),
            body: SingleChildScrollView(
              padding:
                  EdgeInsetsDirectional.only(start: 15.0, end: 15.0, top: 5.0),
              child: HtmlWidget(
                widget.desc!,
                onTapUrl: (
                  String? url,
                ) async {
                  if (await canLaunchUrl(Uri.parse(url!))) {
                    await launchUrl(Uri.parse(url));
                    return true;
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
            ));
  }

  //set appbar
  getAppBar() {
    return PreferredSize(
        preferredSize: Size(double.infinity, 45),
        child: AppBar(
          centerTitle: false, //true,
          backgroundColor: Colors.transparent,
          leading: setBackButton(
              context, !isDark! ? colors.secondaryColor : colors.bgColor),

          title: Transform(
            transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
            child: Text(
              widget.title!,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: !isDark! ? colors.secondaryColor : colors.bgColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5),
            ),
          ),
        ));
  }


}
