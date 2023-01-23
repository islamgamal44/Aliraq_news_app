// import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';

// import 'package:flutter/services.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/LanguageNotifier.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/String.dart';
import 'package:news/Helper/Widgets.dart';

// import 'package:news/IntroPage.dart';
import 'package:news/Login.dart';
import 'package:news/Model/LanguageModel.dart';
import 'package:news/main.dart';
import 'package:provider/provider.dart';

import 'Home.dart';

class LanguageList extends StatefulWidget {
  final int? from;

  const LanguageList({Key? key, this.from}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LanguageListState();
  }
}

class LanguageListState extends State<LanguageList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isNetworkAvail = true;
  bool isProgress = false;
  String? selectLan;
  String? selectLanId;
  String? selectLanRTL;

  @override
  void initState() {
    getLanguageList();
    selectLan = context.read<LanguageNotifier>().getLanguageCode();

    super.initState();
  }

  getLanguageList() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var param = {ACCESS_KEY: access_key};

        Response response = await post(Uri.parse(getLanguagesApi),
                body: param, headers: headers)
            .timeout(Duration(seconds: timeOut));

        print("response status code****${response.statusCode}");
        if (response.statusCode == 200) {
          var getData = json.decode(response.body);

          String error = getData["error"];

          if (error == "false") {
            var data = getData["data"];
            List<LanguageModel> tempLangList = (data as List)
                .map((data) => new LanguageModel.fromJson(data))
                .toList();
            context.read<LanguageNotifier>().setLanguageList(tempLangList);

            /* for (int i = 0; i < tempLangList.length; i++) {
              if (tempLangList[i].code ==
                  context.read<LanguageNotifier>().getLanguageCode()) {
                setState(() {
                  selectLan = i;
                });
              }
            }*/
          }
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  @override
  void dispose() {
    /* if (widget.from == 1)
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark);  */ //set to Dark byDefault for IntroScreen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      //floatingActionButton: saveBtn(),
      appBar: appBarDetails(),
      body: Stack(
        children: <Widget>[setTitle(), setBuilder(), saveBtn(), progressBar()],
      ),
    );
  }

  Widget progressBar() {
    if (isProgress) {
      return showCircularProgress(
          isProgress, Theme.of(context).colorScheme.primary);
    } else {
      return SizedBox.shrink();
    }
  }

/*  void _changeLan(String language) async {

  }*/

  appBarDetails() {
    return PreferredSize(
      preferredSize: Size(double.infinity, 45),
      child: AppBar(
        backgroundColor: Colors.transparent,
        leading: widget.from == 1
            ? const SizedBox.shrink()
            : setBackButton(context, Theme.of(context).colorScheme.skipColor),
      ),
    );
  }

  setTitle() {
    return Container(
      child: Padding(
        padding: EdgeInsetsDirectional.only(top: 25.0, start: 20.0),
        child: Text(
          getTranslated(context, 'choose_lan_lbl')!,
          style: Theme.of(context).textTheme.headline5?.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5),
        ),
      ),
    );
  }

/*  contentView() {
    return SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(
            start: 15.0, end: 15.0, bottom: 20.0), //top: 30.0,
        controller: _scrlController,
        child: getLangList());
  }*/

  setBuilder() {
    return Container(
        margin: EdgeInsetsDirectional.only(top: 120), child: getLangList());
  }

  getLangList() {
    return ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: 20),
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: ((context, index) => Padding(
              padding: EdgeInsets.fromLTRB(
                  20.0, 5.0, 20.0, 5.0), //fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                leading: CachedNetworkImage(
                  //image
                  imageUrl: context
                      .read<LanguageNotifier>()
                      .languageList[index]
                      .image!,
                  height: 30.0,

                  width: 30,
                  fit: BoxFit.cover,
                  placeholder: (context, url) {
                    return placeHolder();
                  },

                  errorWidget: (context, error, stackTrace) {
                    return errorWidget(30, 30);
                  },
                ),
                title: Text(
                  context
                      .read<LanguageNotifier>()
                      .languageList[index]
                      .language!,
                  style: Theme.of(this.context).textTheme.titleLarge?.copyWith(
                      color: (selectLan ==
                              context
                                  .read<LanguageNotifier>()
                                  .languageList[index]
                                  .code)
                          ? Theme.of(context).colorScheme.lightColor
                          : Theme.of(context).colorScheme.fontColor),
                ),
                tileColor: (selectLan ==
                        context
                            .read<LanguageNotifier>()
                            .languageList[index]
                            .code)
                    ? Theme.of(context)
                        .colorScheme
                        .darkColor //Theme.of(context).colorScheme.langSel
                    : null,
                onTap: () {
                  setState(() {
                    selectLan = context
                        .read<LanguageNotifier>()
                        .languageList[index]
                        .code;
                    selectLanId = context
                        .read<LanguageNotifier>()
                        .languageList[index]
                        .id!;
                    selectLanRTL = context
                        .read<LanguageNotifier>()
                        .languageList[index]
                        .isRtl;
                    //    _changeLan()langCode[index];//change at a time - for demo
                  });
                },
              ),
            )),
        separatorBuilder: (context, index) {
          return SizedBox(height: 1.0);
        },
        itemCount: context.read<LanguageNotifier>().languageList.length);
  }

  saveBtn() {
    return Container(
      // Padding(
      padding: EdgeInsets.only(bottom: 15),
      alignment: Alignment(0, 0.8),
      child: new InkWell(
          child: Container(
            height: 55.0,
            width: MediaQuery.of(context).size.width * 0.9,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(15.0)),
            child: Text(
              getTranslated(context, 'save_lbl')!,
              style: Theme.of(this.context).textTheme.headline6?.copyWith(
                  color: colors.bgColor, fontWeight: FontWeight.bold),
            ),
          ),
          onTap: () {
            print(
                "context code****${context.read<LanguageNotifier>().languageCode}*****${selectLan}");
            if (context.read<LanguageNotifier>().languageCode != selectLan) {
              print("inner");
              getLangJsonDataList(selectLan!).whenComplete(() {
                if (widget.from == 1) {
                  //goto loginscreen directly
                  setPrefrenceBool(ISFIRSTTIME, true);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                  // Navigator.pop(context);
                }
              });
            } else {
              /* CUR_LANGUAGE_ID = Provider.of<LanguageNotifier>(context)
                    .languageList[selectLan!]
                    .id!;
                setPrefrence(
                    LANGUAGE_ID,
                    Provider.of<LanguageNotifier>(context)
                        .languageList[selectLan!]
                        .id!);*/
              if (widget.from == 1) {
                //goto loginscreen directly
                setPrefrenceBool(ISFIRSTTIME, true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              } else {
                Navigator.pop(context);
              }
            }
          }),
    );
  }

  Future getLanJsonData(String code, var data) async {
    setState(() {
      setPrefrence(code, jsonEncode(data));
    });
  }

  Future getLangJsonDataList(String code) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      setState(() {
        isProgress = true;
      });
      try {
        var param = {ACCESS_KEY: access_key, CODE: code};

        Response response = await post(Uri.parse(getLangJsonDataApi),
                body: param, headers: headers)
            .timeout(Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getData = json.decode(response.body);

          String error = getData["error"];
          if (error == "false") {
            var data = getData["data"];
            print("data****json****$data");
            // setPrefrence(code, jsonEncode(data));
            getLanJsonData(code, data).then((value) {
              context
                  .read<LanguageNotifier>()
                  .changeSetting(code, selectLanRTL!);

              setPrefrence(ISRTL, selectLanRTL!);
              setPrefrence(LANGUAGE_ID, selectLanId!);
              setPrefrence(LANGUAGE_CODE, code);
              CUR_LANGUAGE_ID = selectLanId;
            });
          }
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }
}
