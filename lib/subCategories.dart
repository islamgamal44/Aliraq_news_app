import 'dart:async';
import 'dart:convert';

// import 'dart:ui';
import 'package:flutter/material.dart';

// import 'package:flutter/services.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Widgets.dart';
import 'package:news/Model/Category.dart';
import 'package:news/Model/News.dart';

// import 'package:news/NewsDetails.dart';
// import 'package:news/NewsTag.dart';

import 'package:news/SubHome.dart';
import 'package:shimmer/shimmer.dart';

import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/String.dart';
import 'package:http/http.dart' as http;

class SubCategories extends StatefulWidget {
  final String? catId;
  final String? catName;

  final List<Category>? catList;
  final String? curTabId;
  final bool? isSubCat;
  final int? index;
  final String? subCatId;

  SubCategories({
    this.catId,
    this.catName,
    this.catList,
    this.curTabId,
    this.isSubCat,
    this.index,
    this.subCatId,
  });

  @override
  SubCategoriesState createState() => SubCategoriesState();
}

class SubCategoriesState extends State<SubCategories>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool isNetworkAvail = true;
  bool isLoadingMore = true;
  List<SubCategory> subcatData = [];
  List<Category> tempCatList = [];
  List<SubCategory> tempsubCatList = [];
  List<News> tempList = [];
  int offset = 0;
  int total = 0;

  List<News> bookmarkList = [];
  List bookMarkValue = [];

  List<Category> catList = [];
  List<News> newsList = [];
  int tcIndex = 0;
  int? selectSubCat = 0;

  // ScrollController _controller = new ScrollController();
  // bool enabled = true;
  bool isBookmark = false;
  bool isSubCatAvailable = true;
  var scrollController = ScrollController();
  String? subId = "0";

  @override
  void initState() {
    super.initState();
    getCat();
    getSubcategories();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: titleSubCatTxt(),
      body: Stack(
        children: <Widget>[
          subcatData.length != 0 ? subTabData() : catShimmer(),
          Padding(
            padding: EdgeInsets.only(top: (isSubCatAvailable) ? 40.0 : 0.0),
            child: catList.length != 0
                ? SubHome(
                    curTabId: widget.curTabId,
                    isSubCat: false,
                    scrollController: scrollController,
                    catList: catList,
                    subCatId: subId,
                    index: 0,
                    newsList: this.newsList,
                  )
                : contentWithBottomTextShimmer(context),
            //  showCircularProgress(isLoading, colors.primary)
          ),
        ],
      ),
    );
  }

  catShimmer() {

    return (isSubCatAvailable)
        ? Container(
            child: Shimmer.fromColors(
                baseColor: Colors.grey.withOpacity(0.4),
                highlightColor: Colors.grey.withOpacity(0.4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: [0, 1, 2, 3, 4, 5, 6]
                          .map((i) => Padding(
                              padding:
                                  EdgeInsetsDirectional.only(start: 15, top: 0),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Color.fromARGB(255, 59, 49, 49)),
                                height: 32.0,
                                width: 70.0,
                              )))
                          .toList()),
                )))
        : SizedBox.shrink();
  }

  titleSubCatTxt() {
    return AppBar(
      // leadingWidth: 35, //25,
      /* elevation: 0.0,
      systemOverlayStyle:
          !isDark! ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light, */
      backgroundColor: Colors.transparent,
      leading: setBackButton(context, Theme.of(context).colorScheme.darkColor),
      //padding: EdgeInsets.only(left: 10.0),
      title: Transform(
        transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
        child: Text(widget.catName!,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Theme.of(context).colorScheme.darkColor,
                  fontWeight: FontWeight.bold,
                )),
      ),
    );
  }

  //get all category using api
  Future<void> getCat() async {
    if (category_mode == "1") {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        try {
          var param = {ACCESS_KEY: access_key, LANGUAGE_ID: CUR_LANGUAGE_ID};
          http.Response response = await http
              .post(Uri.parse(getCatApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));
          var getData = json.decode(response.body);

          String error = getData["error"];
          if (error == "false") {
            tempCatList.clear();
            var data = getData["data"];
            tempCatList = (data as List)
                .map((data) => new Category.fromJson(data))
                .toList();
            catList.addAll(tempCatList);
          }
          if (mounted)
            setState(() {
              isLoading = false;
            });
        } on TimeoutException catch (_) {
          showSnackBar(getTranslated(context, 'somethingMSg')!, context);
          setState(() {
            isLoading = false;
            isLoadingMore = false;
          });
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'disabled_category')!, context);
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> getSubcategories() async {
    if (category_mode == "1") {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        try {
          var param = {
            ACCESS_KEY: access_key,
            CATEGORY_ID: widget.catId,
            LANGUAGE_ID: CUR_LANGUAGE_ID
          };

          http.Response response = await http
              .post(Uri.parse(getSubCategoryApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

          var getData = json.decode(response.body);

          String error = getData["error"];

          if (error == "false") {
            tempsubCatList.clear();
            var data = getData["data"];
            tempsubCatList = (data as List)
                .map((data) => new SubCategory.fromJson(data))
                .toList();


            if (tempsubCatList.length != 0) {
              tempsubCatList.insert(
                  0,
                  SubCategory(
                      id: "0",
                      subCatName: "${getTranslated(context, 'all_lbl')!}"));
            }
            subcatData.addAll(tempsubCatList);

          } else {
            if (subcatData.length == 0) {
              setState(() {
                isSubCatAvailable = false;
              });
            } else {
              setState(() {
                isSubCatAvailable = true;
              });
            }
          }
          if (mounted)
            setState(() {
              isLoading = false;
            });
        } on TimeoutException catch (_) {
          showSnackBar(getTranslated(context, 'somethingMSg')!, context);
          setState(() {
            isLoading = false;
            isLoadingMore = false;
          });
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'disabled_category')!, context);
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  subTabData() {
    return subCategory_mode == "1"
        ? catList.length != 0 && !isLoading
            ? subcatData.length != 0 && !isLoading
                ? Container(
                    height: 32,
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsetsDirectional.only(start: 16),
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: (subcatData.length),
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: EdgeInsetsDirectional.only(
                                  start: index == 0 ? 0 : 10),
                              child: InkWell(
                                child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsetsDirectional.only(
                                        start: 7.0,
                                        end: 7.0,
                                        top: 2.5,
                                        bottom: 2.5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: (selectSubCat == index)
                                          ? Theme.of(context)
                                              .colorScheme
                                              .tabColor
                                          : Colors.transparent,
                                    ),
                                    child: Text(
                                      subcatData[index].subCatName!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          ?.copyWith(
                                              color: selectSubCat == index
                                                  ? colors.bgColor
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .skipColor,
                                              fontSize: 12,
                                              fontWeight: selectSubCat == index
                                                  ? FontWeight.w600
                                                  : FontWeight.normal),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                    )),
                                onTap: () async {
                                  this.setState(() {
                                    selectSubCat = index;
                                    subId = subcatData[index].id;
                                  });
                                },
                              ));
                        }))
                : SizedBox.shrink()
            //if Subcategory Length of Respected Category is 0
            : Container(
                height: 32,
                margin: EdgeInsetsDirectional.only(start: 16),
                child: Align(
                    alignment: Alignment.center,
                    child: Text(getTranslated(context,
                        'cat_no_avail')!))) //if Category List is having 0 length
        : Container(
            height: 32,
            margin: EdgeInsetsDirectional.only(start: 16),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(getTranslated(context,
                    'disabled_subcat')!))); //if SubCategory Mode is Disabled
  }


}
