import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Model/LiveStreaming.dart';
import 'Helper/Widgets.dart';
import 'NewsVideo.dart';

// ignore: must_be_immutable
class Live extends StatefulWidget {
  List<LiveStreamingModel> liveNews;

  Live({Key? key, required this.liveNews}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateLive();
}

class StateLive extends State<Live> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isNetworkAvail = true;
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  appBarSet() {
    return AppBar(

      backgroundColor: Colors.transparent,
      leading: setBackButton(context, Theme.of(context).colorScheme.fontColor),
      //padding: EdgeInsets.only(left: 10.0),

      title: Transform(
        transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
        child: Text(getTranslated(context, 'live_videos_lbl')!,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: appBarSet(),
        body:
            mainListBuilder()

        );
  }

  mainListBuilder() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: ListView.separated(
          itemBuilder: ((context, index) {
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 20),
              child: ClipRRect(
                borderRadius: BorderRadius.all(const Radius.circular(10.0)),
                child:
                    InkWell(
                  onTap: () {

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewsVideo(
                                  liveModel: widget.liveNews[index],
                                  from: 2,
                                )));

                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [

                        CachedNetworkImage(
                          fadeInDuration: Duration(milliseconds: 150),
                          imageUrl: widget.liveNews[index].image!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorWidget: (context, error, stackTrace) =>
                              errorWidget(200, double.infinity),
                          placeholder: (context, url) {
                            return Image.asset(
                              'assets/images/Placeholder_video.jpg',
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.black45,
                          child: Icon(
                            Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          )),
                      Positioned.directional(
                        textDirection: Directionality.of(context),
                        bottom: 10,
                        start: 20,
                        end: 20,
                        child: Text(
                          widget.liveNews[index].title!,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(color: colors.tempboxColor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),

              ),
            );
          }),
          separatorBuilder: (context, index) {
            return SizedBox(height: 3.0);
          },
          itemCount: widget.liveNews.length),
    );
  }
}
