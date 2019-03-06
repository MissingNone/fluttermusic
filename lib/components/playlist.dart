import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:fluttermusic/common/globalaudio.dart';
import 'package:fluttermusic/common/icons.dart';
import 'package:fluttermusic/common/playmode.dart';
import 'package:fluttermusic/common/song.dart';
import 'package:fluttermusic/components/confirm.dart';
import 'package:fluttermusic/main.dart';
import 'package:fluttermusic/page/playerpage.dart';
import 'package:fluttermusic/store/state.dart';
import 'package:flutter/material.dart';

class PlayList extends StatefulWidget {
  PlayList({Key key, this.isShow}) : super(key: key);
  bool isShow = false;
  @override
  State<StatefulWidget> createState() {
    return PlayListState();
  }
}

class PlayListState extends State<PlayList> with TickerProviderStateMixin {
  List<Widget> list = [];
  AppState appState = AppState.instance();
  bool isMounted = false;
  ScrollController _scrollController;
  Animation<double> bottomanimation;
  AnimationController bottomcontroller;
  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    bottomcontroller = new AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    bottomanimation =
        new Tween(begin: -360.0, end: 0.0).animate(bottomcontroller)
          ..addListener(() {
            setState(() => {});
          });
    bottomcontroller.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    bottomcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isMounted) {
      isMounted = true;
      int i = 0;
      double current = 0;
      appState.sequenceList.forEach((song) {
        list.add(
          PlayListItem(
            song: song,
            songname: song.name,
            isPlaying: appState.getCurrentSong().id == song.id,
            index: i,
          ),
        );
        if (appState.getCurrentSong().id == song.id) {
          current = i.toDouble();
        }
        i++;
      });
      // Timer(Duration(milliseconds: 20), () {
      //   _scrollController.animateTo(current * 40,
      //       duration: Duration(milliseconds: 300), curve: Curves.ease);
      // });
    }

    return WillPopScope(
      child: Material(
        type: MaterialType.transparency,
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: Color.fromRGBO(0, 0, 0, 0.3),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        right: 0,
                        left: 0,
                        bottom: bottomanimation.value,
                        child: Container(
                          color: Color(0xff333333),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                  top: 20,
                                  right: 30,
                                  bottom: 10,
                                  left: 20,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(right: 10),
                                      child: Icon(
                                        MusicIcons.sequence,
                                        size: 30,
                                        color:
                                            Color.fromRGBO(255, 205, 49, 0.5),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        appState.mode == PlayMode.sequence
                                            ? '顺序播放'
                                            : appState.mode == PlayMode.random
                                                ? '随机播放'
                                                : '单曲循环',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromRGBO(
                                              255, 255, 255, 0.5),
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        MusicIcons.clear,
                                        size: 14,
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.3),
                                      ),
                                      onTap: () {
                                        print('clear');
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                              opaque: false,
                                              pageBuilder:
                                                  (BuildContext context,
                                                      Animation animation,
                                                      Animation
                                                          secondaryAnimation) {
                                                return NotificationListener<
                                                    ConfirmNotification>(
                                                  onNotification:
                                                      (notification) {
                                                    // GlobalAudio.instance()
                                                    //     .isPlaying = false;

                                                    // appState.currentIndex = -1;
                                                    // appState.playlist = [];
                                                    // appState.isShow = false;
                                                    appState.deleteSongList();
                                                    setState(() {});
                                                    close();
                                                  },
                                                  child: Confirm(),
                                                );
                                              }),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 240,
                                child: NotificationListener<
                                    SelectItemNotification>(
                                  onNotification: (notification) {
                                    int i = 0;
                                    double current = 0;
                                    list = [];
                                    appState.sequenceList.forEach((song) {
                                      list.add(
                                        PlayListItem(
                                          song: song,
                                          songname: song.name,
                                          isPlaying:
                                              appState.getCurrentSong().id ==
                                                  song.id,
                                          index: i,
                                        ),
                                      );
                                      if (appState.getCurrentSong().id ==
                                          song.id) {
                                        current = i.toDouble();
                                        print(current);
                                      }
                                      i++;
                                    });

                                    setState(() {});
                                    Timer(Duration(milliseconds: 20), () {
                                      _scrollController.animateTo(current * 40,
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.ease);
                                    });
                                  },
                                  child: ListView(
                                    controller: _scrollController,
                                    physics: BouncingScrollPhysics(),
                                    children: list,
                                  ),
                                ),
                              ),
                              Container(
                                width: 140,
                                margin: EdgeInsets.only(
                                  top: 20,
                                  bottom: 30,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    width: 1,
                                    color: Color.fromRGBO(255, 255, 255, 0.5),
                                  ),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                          right: 5,
                                        ),
                                        child: Icon(
                                          MusicIcons.add,
                                          size: 10,
                                          color: Color.fromRGBO(
                                              255, 255, 255, 0.5),
                                        ),
                                      ),
                                      Text(
                                        "添加歌曲到队列",
                                        style: TextStyle(
                                          color: Color.fromRGBO(
                                              255, 255, 255, 0.5),
                                          fontSize: 12,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  height: 50,
                                  color: Color(0xff222222),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "关闭",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromRGBO(255, 255, 255, 0.5),
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  close();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () {
        close();
        return Future.value(false);
      },
    );
    // : Container();
  }

  close() {
    Navigator.of(context).pop();
    bottomcontroller.reverse().whenComplete(() {
      Toast.show(context);
    });

    // CloseNotification(isShow: false).dispatch(context);
  }
}

class PlayListItem extends StatefulWidget {
  PlayListItem({
    this.song,
    this.songname,
    this.isPlaying = false,
    this.index,
  });
  Song song;
  String songname;
  bool isPlaying;
  int index;
  @override
  State<StatefulWidget> createState() {
    return PlayListItemState();
  }
}

class PlayListItemState extends State<PlayListItem> {
  AppState appState = AppState.instance();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 40,
        color: Color.fromRGBO(0, 0, 0, 0),
        padding: EdgeInsets.only(
          right: 30,
          left: 20,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 20,
              child: widget.isPlaying
                  ? Icon(
                      MusicIcons.play,
                      size: 12,
                      color: Color.fromRGBO(255, 205, 49, 0.5),
                    )
                  : Container(),
            ),
            Expanded(
              flex: 1,
              child: Text(
                widget.song.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(255, 255, 255, 0.3),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                right: 15,
              ),
              child: Icon(
                MusicIcons.favorite,
                size: 12,
                color: Color(0xffffcd32),
              ),
            ),
            GestureDetector(
              child: Container(
                child: Icon(
                  MusicIcons.delete,
                  size: 12,
                  color: Color(0xffffcd32),
                ),
              ),
              onTap: () {
                // appState.playlist.removeAt(widget.index);
                // if (appState.currentIndex > widget.index ||
                //     appState.currentIndex == appState.playlist.length) {
                //   appState.currentIndex = appState.currentIndex - 1;
                // }
                appState.deleteSong(widget.song);
                GlobalAudio.instance().isPlaying = true;
                SelectItemNotification().dispatch(context);
              },
            ),
          ],
        ),
      ),
      onTap: () {
        int index = widget.index;
        if (appState.mode == PlayMode.random) {
          index = appState.playlist.indexWhere((song) {
            return song.id == widget.song.id;
          });
        }
        int currentIndex = appState.currentIndex;

        appState.currentIndex = index;
        if (currentIndex != widget.index) {
          SelectItemNotification().dispatch(context);
        }
        GlobalAudio.instance().isPlaying = true;
      },
    );
  }
}

class SelectItemNotification extends Notification {}
