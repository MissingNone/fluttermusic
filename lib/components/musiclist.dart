import 'package:fluttermusic/common/globalaudio.dart';
import 'package:fluttermusic/common/icons.dart';
import 'package:fluttermusic/common/song.dart';
import 'package:fluttermusic/components/songlist.dart';
import 'package:fluttermusic/page/playerpage.dart';
import 'package:fluttermusic/store/state.dart';
import 'package:flutter/material.dart';

class MusicList extends StatefulWidget {
  String bgImage;
  List<Song> songs;
  String title;
  bool rank;
  MusicList({
    Key key,
    this.bgImage = '',
    this.songs = const <Song>[],
    this.title = '',
    this.rank = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MusicListState();
  }
}

class MusicListState extends State<MusicList> {
  AppState appState = AppState.instance();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    leading: GestureDetector(
                      child: Icon(
                        MusicIcons.back,
                        size: 22,
                        color: Color(0xffffcd32),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    centerTitle: true,
                    primary: true,
                    forceElevated: false,
                    automaticallyImplyLeading: false,
                    titleSpacing: 0.0,
                    snap: false,
                    expandedHeight: MediaQuery.of(context).size.width * 0.7,
                    floating: false,
                    pinned: true,
                    title: Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      centerTitle: true,
                      background: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width * 0.7,
                        color: Color(0xff222222),
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            widget.bgImage != ''
                                ? Image.network(
                                    widget.bgImage,
                                    alignment: Alignment.topCenter,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Color(0xff222222),
                                  ),
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                color: Color.fromRGBO(7, 17, 27, 0.4),
                              ),
                            ),
                            Positioned(
                              bottom: 18.0,
                              left: MediaQuery.of(context).size.width * 0.5 -
                                  67.5,
                              child: GestureDetector(
                                child: Container(
                                  width: 135.0,
                                  padding: EdgeInsets.only(top: 7, bottom: 7),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xffffcd32),
                                    ),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 6),
                                        child: Icon(
                                          MusicIcons.play,
                                          color: Color(0xffffcd32),
                                          size: 16,
                                        ),
                                      ),
                                      Text(
                                        "随机播放全部",
                                        style: TextStyle(
                                          color: Color(0xffffcd32),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  appState.randomPlay(widget.songs);
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                          transitionDuration: Duration(
                                              milliseconds: 500), //动画时间为500毫秒
                                          pageBuilder: (BuildContext context,
                                              Animation animation,
                                              Animation secondaryAnimation) {
                                            return new FadeTransition(
                                                //使用渐隐渐入过渡,
                                                opacity: animation,
                                                child: PlayerPage() //路由B
                                                );
                                          }));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: NotificationListener<SelectPlayNotification>(
                onNotification: (selectPlay) {
                  appState.selectPlay(widget.songs, selectPlay.index);
                  // appState.playlist = widget.songs;
                  // appState.currentIndex = selectPlay.index;
                  // appState.isShow = true;
                  // GlobalAudio.instance().isPlaying = true;
                  print('appState.isShow:${appState.isShow}');
                  setState(() {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            transitionDuration:
                                Duration(milliseconds: 500), //动画时间为500毫秒
                            pageBuilder: (BuildContext context,
                                Animation animation,
                                Animation secondaryAnimation) {
                              return new FadeTransition(
                                  //使用渐隐渐入过渡,
                                  opacity: animation,
                                  child: PlayerPage() //路由B
                                  );
                            }));
                  });
                },
                child: SongList(
                  songs: widget.songs,
                  rank: widget.rank,
                ),
              ),
            ),
          ),
          // MiniPlayer(),
        ],
      ),
    );
  }
}
