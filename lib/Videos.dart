// ignore_for_file: must_be_immutable, invalid_return_type_for_catch_error
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/String.dart';
import 'package:news/Helper/Widgets.dart';
import 'package:news/Model/News.dart';
import 'package:news/NewsVideo.dart';
import 'package:path_provider/path_provider.dart';

import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'Helper/LanguageNotifier.dart';
import 'Home.dart';

class Videos extends StatefulWidget {
  bool isBackRequired = false;

  Videos({
    Key? key,
    required this.isBackRequired,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => VideosState();
}

class VideosState extends State<Videos> {
  String url = "";
  List<News> videoItems = [];

  bool _isNetworkAvail = true;
  int offset = 0;
  int total = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool isBookmarkLoading = false;
  List bookMarkValue = [];
  List<News> bookmarkList = [];

  bool isVidClicked = false;
  bool isSaved = true;
  bool isShared = true;
  ScrollController controller = new ScrollController();

  @override
  void initState() {
    super.initState();

    callApi();
    controller.addListener(_scrollListener);
    _getBookmark();
  }

  callApi() {
    offset = 0;
    total = 0;
    _isLoading = true;
    videoItems.clear();
    getNewsVideoURL();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  _scrollListener() {
    if (controller.positions.last.pixels >=
            controller.positions.last.maxScrollExtent &&
        !controller.positions.last.outOfRange) {
      if (this.mounted) {
        setState(() {
          _isLoadingMore = true;

          if (offset < total) getNewsVideoURL();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Videos are loading? --$_isLoading');
    return Scaffold(
      appBar: appBar(),
      body: _isLoading
          ? Padding(
              padding: EdgeInsets.only(
                bottom: 10.0,
                left: 30.0,
                right: 30.0,
              ),
              child: contentShimmer(context))
          : mainListBuilder(),
    );
  }

  _setBookmark(String status, String id) async {
    if (bookMarkValue.contains(id)) {
      bookMarkValue = List.from(bookMarkValue)..remove(id);
    } else {
      bookMarkValue = List.from(bookMarkValue)..add(id);
    }

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
        NEWS_ID: id,
        STATUS: status,
      };

      http.Response response = await http
          .post(Uri.parse(setBookmarkApi), body: param, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      String error = getdata["error"];

      String msg = getdata["message"];
      print(msg);
      if (error == "false") {}
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

// ignore: non_constant_identifier_names
  Future<String>? getThumbnailImage(String url) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight: 64,
      // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    ).catchError((Error) => print("Error !!!!! $Error"));
    return fileName!;
  }

  appBar() {
    return PreferredSize(
        preferredSize: Size(double.infinity, 70),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
              start: 10, top: MediaQuery.of(context).padding.top + 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              (widget.isBackRequired)
                  ? setBackButton(
                      context, isDark! ? colors.bgColor : colors.secondaryColor)
                  : SizedBox.shrink(),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 15),
                child: Text(
                  getTranslated(context, 'videos_lbl')!,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Theme.of(context).colorScheme.darkColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ));
  }

  mainListBuilder() {
    return RefreshIndicator(
      onRefresh: () async {
        offset = 0;
        total = 0;
        _isLoading = true;
        videoItems.clear();
        getNewsVideoURL();
        setState(() {});
      },
      child: videoItems.isEmpty
          ? Center(
              child: Text(
                getTranslated(context, 'VIDEO_NOT_AVAIL_LBL')!,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .fontColor
                        .withOpacity(0.9),
                    fontWeight: FontWeight.w600),
              ),
            )
          : ListView.separated(
              padding: EdgeInsetsDirectional.only(top: 15),
              physics: AlwaysScrollableScrollPhysics(),
              controller: controller,
              itemBuilder: ((context, index) {
                return Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsetsDirectional.only(
                          start: 20, end: 20, top: 10, bottom: 10),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.all(const Radius.circular(10.0)),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewsVideo(
                                          model: videoItems[index],
                                          from: 1,
                                        )));
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CachedNetworkImage(
                                fadeInDuration: Duration(milliseconds: 150),
                                imageUrl: (videoItems[index].contentType ==
                                        'video_youtube')
                                    ? 'https://img.youtube.com/vi/${YoutubePlayer.convertUrlToId(videoItems[index].contentValue!)!}/0.jpg'
                                    : videoItems[index].image!,
                                width: double.maxFinite,
                                height: 220,
                                fit: BoxFit.fill,
                                errorWidget: (context, error, stackTrace) =>
                                    errorWidget(220, double.maxFinite),
                                placeholder: (context, url) {
                                  return placeHolder();
                                },
                              ),
                              CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.black45,
                                  child: Icon(
                                    Icons.play_arrow,
                                    size: 40,
                                    color: Colors.white,
                                  ))
                            ],
                          ),
                        ),
                        // ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 25, right: 25), //start: 15, end: 15
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              videoItems[index].title!,
                              style: Theme.of(context).textTheme.titleSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ))),
                    Padding(
                      padding: EdgeInsets.only(left: 25, right: 25),
                      //left: 15, right: 15
                      child: Row(
                        children: [
                          Text(
                              convertToAgo(context,
                                  DateTime.parse(videoItems[index].date!), 0)!,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .agoLabel
                                          .withOpacity(0.8))),
                          Spacer(),

                          InkWell(
                            onTap: () {
                              if (isRedundentClick(DateTime.now(), diff)) {
                                //inBetweenClicks
                                print('hold on, processing');

                                return;
                              }
                              if (CUR_USERID != "") {
                                setState(() {
                                  bookMarkValue.contains(videoItems[index].id!)
                                      ? _setBookmark("0", videoItems[index].id!)
                                      : _setBookmark(
                                          "1", videoItems[index].id!);

                                  // isSaved = true;
                                  //inBetweenClicks = 2; //0
                                  diff = resetDiff;
                                });
                              } else {
                                loginRequired(context);
                                if (mounted)
                                  setState(() {
                                    diff = resetDiff;
                                    // inBetweenClicks = 2; //0
                                  });
                              }
                              //  }
                            },
                            child: bookMarkValue.contains(videoItems[index].id)
                                ? Icon(Icons.bookmark_added_rounded)
                                : Icon(Icons.bookmark_add_outlined),
                            splashColor: Colors.transparent,
                          ),
                          // ),
                          SizedBox(width: deviceWidth! / 99.0),

                          InkWell(
                            onTap: () async {
                              if (isRedundentClick(DateTime.now(), diff)) {
                                //inBetweenClicks
                                print('hold on, processing');

                                return;
                              }
                              // print('run process');
                              // },

                              _isNetworkAvail = await isNetworkAvailable();
                              if (_isNetworkAvail) {
                                createDynamicLink(
                                    context,
                                    videoItems[index].id!,
                                    index,
                                    videoItems[index].title!,
                                    true,
                                    false,
                                    videoItems[index].image!);
                              } else {
                                showSnackBar(
                                    getTranslated(context, 'internetmsg')!,
                                    context);
                              }
                              if (mounted)
                                setState(() {
                                  diff = resetDiff;
                                  //inBetweenClicks = 2; //0
                                });
                            },
                            child: Icon(Icons.share_rounded),
                            splashColor: Colors.transparent,
                          ),
                          // )
                        ],
                      ),
                    ),
                  ],
                );
              }),
              separatorBuilder: (context, index) {
                return SizedBox(height: 3.0);
              },
              itemCount: videoItems.length),
    );
  }

  Future<void> _getBookmark() async {
    //API-getBookmarkApi
    if (CUR_USERID != "") {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          var param = {
            ACCESS_KEY: access_key,
            USER_ID: CUR_USERID,
          };
          http.Response response = await http
              .post(Uri.parse(getBookmarkApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          String error = getdata["error"];
          if (error == "false") {
            bookmarkList.clear();
            var data = getdata["data"];

            bookmarkList =
                (data as List).map((data) => new News.fromJson(data)).toList();
            bookMarkValue.clear();

            for (int i = 0; i < bookmarkList.length; i++) {
              if (mounted)
                setState(() {
                  bookMarkValue.add(bookmarkList[i].newsId);
                });
            }
            if (mounted)
              setState(() {
                isBookmarkLoading = false;
              });
          } else {
            setState(() {
              isBookmarkLoading = false;
            });
          }
        } on TimeoutException catch (_) {
          showSnackBar(getTranslated(context, 'somethingMSg')!, context);
          setState(() {
            isBookmarkLoading = false;
          });
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
      }
    }
  }

  Future<void> getNewsVideoURL() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ACCESS_KEY: access_key,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          USER_ID: CUR_USERID != "" ? CUR_USERID : "0",
          LANGUAGE_ID: CUR_LANGUAGE_ID
        };

        Response response = await post(Uri.parse(getVideosApi),
                headers: headers, body: parameter)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        String error = getdata["error"];
        String? msg = getdata["message"];
        if (error == "false") {
          var data = getdata["data"];

          total = int.parse(getdata["total"]);

          if (offset < total) {
            List mainlist = getdata['data'];

            var tempList =
                mainlist.map((data) => new News.fromVideos(data)).toList();

            videoItems.addAll(tempList);

            offset = offset + perPage;
          }
        } else {
          _isLoadingMore = false;
          // showSnackBar(msg!, context);
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
          showSnackBar('internetmsg', context);
        });
      }
    }

    return;
  }
}
