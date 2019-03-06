import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:fluttermusic/common/globalaudio.dart';
import 'package:fluttermusic/common/icons.dart';
import 'package:fluttermusic/common/playmode.dart';
import 'package:fluttermusic/common/song.dart';
import 'package:fluttermusic/components/playlist.dart';
import 'package:fluttermusic/main.dart';
import 'package:fluttermusic/store/state.dart';
import 'package:fluttermusic/util/lyircparser.dart';
import 'package:fluttermusic/util/utils.dart' show shuffle;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayerPage extends StatefulWidget {
  bool isMini;
  PlayerPage({Key key, this.isMini = false}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PlayerPageState();
  }
}

class PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  Animation<double> bottomanimation;
  AnimationController bottomcontroller;
  Animation<double> rotateanimation;
  AnimationController rotatecontroller;
  ScrollController scrollController;
  AudioPlayer audioPlayer;
  bool isPlaying = false;
  int currentTime = 0;
  String playingLyric = '';
  Lyric currentLyric;
  int currentLineNum = 0;
  List<double> listy = [];
  AppState appState = AppState.instance();
  StreamSubscription<void> _subscription;

  @override
  void initState() {
    super.initState();
    Toast.remove();
    setLyricData();
    scrollController = new ScrollController();
    controller = new AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);

    animation = new Tween(begin: -100.0, end: 0.0).animate(
      new CurvedAnimation(
        parent: controller,
        curve: Cubic(0.86, 0.18, 0.82, 1.32),
      ),
    )..addListener(() {
        setState(() => {});
      });
    controller.forward();

    bottomcontroller = new AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    bottomanimation = new Tween(begin: 100.0, end: 0.0).animate(
      new CurvedAnimation(
        parent: controller,
        curve: Cubic(0.86, 0.18, 0.82, 1.32),
      ),
    )..addListener(() {
        setState(() => {});
      });
    bottomcontroller.forward();
    rotatecontroller = new AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    double circle = 2 * pi;
    rotateanimation =
        new Tween(begin: 0.0, end: circle).animate(rotatecontroller)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              rotatecontroller.reset();
              rotatecontroller.forward();
            }
          })
          ..addListener(() {
            if (!GlobalAudio.instance().isPlaying) {
              rotatecontroller.stop();
            }
            GlobalAudio.instance().rotate = rotateanimation.value / (2 * pi);
            setState(() => {});
          });
    rotatecontroller.forward(from: GlobalAudio.instance().rotate);
    _subscription =
        GlobalAudio.instance().audioPlayer.onPlayerCompletion.listen((event) {
      print('end----');
      GlobalAudio.instance().currentTime = 0;
      if (appState.mode == PlayMode.loop) {
        this.loop();
      } else {
        this.next();
      }
    });
  }

  setLyricData() async {
    if (currentLyric != null) {
      currentLyric.stop();
    }
    await getLyric();

    if (!GlobalAudio.instance().isPlaying) {
      currentLyric.stop();
    }
  }

  getLyric() async {
    String lrc = await appState.getCurrentSong().getLyric();
    if (currentLyric != null) {
      currentLyric.stop();
      currentLyric = null;
    }
    currentLyric = Lyric(
        lrc: lrc,
        handler: (Map item) {
          currentLineNum = item['lineNum'];
          playingLyric = item['txt'];
          if (currentLineNum > 5 && listy.length >= currentLineNum - 5) {
            if (scrollController.position.maxScrollExtent >
                listy[currentLineNum - 5]) {
              scrollController.animateTo(
                listy[currentLineNum - 5],
                duration: Duration(milliseconds: 1000),
                curve: Curves.ease,
              );
            } else {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 1000),
                curve: Curves.ease,
              );
            }
          }

          setState(() {});
        })
      ..init();
    currentLyric.seek(GlobalAudio.instance().currentTime * 1000);
  }

  play() async {
    if (GlobalAudio.instance().audioPlayer != null) {
      int result = await GlobalAudio.instance()
          .audioPlayer
          .play(appState.getCurrentSong().url);
      if (result == 1) {}
    }
  }

  pause() {
    if (GlobalAudio.instance().audioPlayer != null) {
      if (currentLyric != null) {
        currentLyric.stop();
      }
      GlobalAudio.instance().audioPlayer.pause();
      rotatecontroller.stop();
      GlobalAudio.instance().isPlaying = false;
      setState(() {});
    }
  }

  resume() {
    if (currentLyric != null) {
      currentLyric.seek(GlobalAudio.instance().currentTime * 1000);
    }
    GlobalAudio.instance()
        .audioPlayer
        .seek(Duration(seconds: GlobalAudio.instance().currentTime));

    rotatecontroller.forward();
    GlobalAudio.instance().isPlaying = true;
    setState(() {});
  }

  updateTime() {
    if (GlobalAudio.instance().audioPlayer != null) {
      GlobalAudio.instance()
          .audioPlayer
          .onAudioPositionChanged
          .listen((Duration p) {
        GlobalAudio.instance().currentTime = p.inSeconds;
        print(GlobalAudio.instance().currentTime);
        // setState(() {});
      });
    }
  }

  format(int interval) {
    interval = interval == null ? 0 : interval;
    int minute = (interval / 60) == null ? 0 : (interval / 60).toInt();
    String second = _pad((interval % 60).toString(), 2);
    return '${minute}:${second}';
  }

  String _pad(String num, int n) {
    if (n == null) {
      n = 2;
    }
    int len = num.length;
    while (len < n) {
      num = '0' + num;
      len++;
    }
    return num;
  }

  togglePlaying() {
    GlobalAudio.instance().isPlaying = !GlobalAudio.instance().isPlaying;
    if (GlobalAudio.instance().isPlaying) {
      rotatecontroller.forward();
    } else {
      rotatecontroller.stop();
    }

    if (currentLyric != null) {
      if (GlobalAudio.instance().isPlaying) {
        currentLyric.seek(GlobalAudio.instance().currentTime * 1000);
      } else {
        currentLyric.stop();
      }
    }
  }

  end() {
    GlobalAudio.instance().currentTime = 0;
    if (appState.mode == PlayMode.loop) {
      this.loop();
    } else {
      this.next();
    }
  }

  loop() {
    GlobalAudio.instance().currentTime = 0;
    resume();
  }

  prev() async {
    GlobalAudio.instance().currentTime = 0;
    currentLineNum = 0;
    playingLyric = '';
    if (appState.playlist.length == 1) {
      loop();
    } else {
      int index = appState.currentIndex - 1;
      if (index == -1) {
        index = appState.playlist.length - 1;
      }
      currentLyric.stop();
      appState.currentIndex = index;
      await getLyric();
      if (!GlobalAudio.instance().isPlaying) {
        togglePlaying();
      }
    }
  }

  next() async {
    GlobalAudio.instance().currentTime = 0;
    currentLineNum = 0;
    playingLyric = '';
    if (appState.playlist.length == 1) {
      loop();
    } else {
      int index = appState.currentIndex + 1;
      if (index == appState.playlist.length) {
        index = 0;
      }
      currentLyric.stop();
      appState.currentIndex = index;
      await getLyric();
      if (!GlobalAudio.instance().isPlaying) {
        togglePlaying();
      }
    }
  }

  back() {
    Toast.show(context);
    GlobalAudio.instance().needSyncRotate = true;
    if (currentLyric != null) {
      currentLyric.stop();
      currentLyric = null;
    }
    controller.reverse();
    bottomcontroller.reverse();
    _subscription.cancel();
    Navigator.of(context).pop();
  }

  changeMode() {
    appState.mode = (appState.mode + 1) % 3;
    List<Song> list;
    if (appState.mode == PlayMode.random) {
      list = shuffle(appState.sequenceList);
    } else {
      list = appState.sequenceList;
    }

    resetCurrentIndex(list);
    appState.playlist = list;
    setState(() {});
  }

  resetCurrentIndex(List<Song> list) {
    int index = list.indexWhere((item) {
      return item.id == appState.getCurrentSong().id;
    });
    appState.currentIndex = index;
  }

  @override
  void dispose() {
    scrollController.dispose();
    controller.dispose();

    bottomcontroller.dispose();
    rotatecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (appState.getCurrentSong() != null && !widget.isMini) {
      if (!GlobalAudio.instance().init) {
        GlobalAudio.instance().init = true;
        print('init');

        // updateTime();
      } else if (GlobalAudio.instance().currentSongChange) {
        GlobalAudio.instance().currentSongChange = false;
        // GlobalAudio.instance().currentTime = 0;
        GlobalAudio.instance().rotate = 0.0;
        GlobalAudio.instance().needSyncRotate = false;
        GlobalAudio.instance().isPlaying = true;
        print('currentSongChange');
      }
    }
    if (widget.isMini) {
      widget.isMini = false;
      if (!GlobalAudio.instance().isPlaying) {
        rotatecontroller.stop();
      }
    }

    return WillPopScope(
      child: Scaffold(
        backgroundColor: Color(0xff222222),
        // appBar: AppBar(
        //   leading: Transform.rotate(
        //     angle: -pi / 2,
        //     child: Icon(
        //       MusicIcons.back,
        //       color: Color(0xffffcd32),
        //     ),
        //   ),
        //   centerTitle: true,
        //   title: Text(
        //     "知否知否",
        //     overflow: TextOverflow.ellipsis,
        //     maxLines: 1,
        //     style: TextStyle(
        //       fontSize: 18,
        //     ),
        //   ),
        // ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        right: 0,
                        child: Container(
                          color: Colors.white.withOpacity(0.1),
                          child: Image.network(
                            appState.getCurrentSong().image,
                            colorBlendMode: BlendMode.src,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        right: 0,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: new Container(
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, animation.value),
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                height: 40,
                                alignment: Alignment.center,
                                child: Row(
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Transform.rotate(
                                        angle: -pi / 2,
                                        child: Icon(
                                          MusicIcons.back,
                                          color: Color(0xffffcd32),
                                        ),
                                      ),
                                      onTap: () {
                                        back();
                                      },
                                    ),
                                    Text(
                                      appState.getCurrentSong().name,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.justify,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 20,
                                alignment: Alignment.center,
                                child: Text(
                                  appState.getCurrentSong().singer,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 80,
                        bottom: 170,
                        left: 0,
                        right: 0,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: PageScrollPhysics(),
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                //不用Column包裹的话,Container设置的大小将无效
                                children: <Widget>[
                                  Hero(
                                    tag: 'image',
                                    createRectTween: (Rect begin, Rect end) {
                                      return RectTween(
                                        begin: Rect.fromLTRB(
                                            begin.left,
                                            begin.top,
                                            begin.right,
                                            begin.bottom),
                                        end: Rect.fromLTRB(end.left, end.top,
                                            end.right, end.bottom),
                                      );
                                    },
                                    flightShuttleBuilder: (
                                      BuildContext flightContext,
                                      Animation<double> animation,
                                      HeroFlightDirection flightDirection,
                                      BuildContext fromHeroContext,
                                      BuildContext toHeroContext,
                                    ) {
                                      Animation<double> newAnimation =
                                          Tween<double>(begin: 1, end: 1)
                                              .animate(animation);

                                      return ScaleTransition(
                                        scale: newAnimation,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.1),
                                              width: 10,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8 *
                                                  0.5,
                                            ),
                                          ),
                                          child: Transform.rotate(
                                            angle: rotateanimation.value,
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  Color(0xff222222),
                                              radius: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8 *
                                                  0.5,
                                              backgroundImage: NetworkImage(
                                                  appState
                                                      .getCurrentSong()
                                                      .image),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.8,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color.fromRGBO(
                                              255, 255, 255, 0.1),
                                          width: 10,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.width *
                                              0.8 *
                                              0.5,
                                        ),
                                      ),
                                      child: Transform.rotate(
                                        angle: rotateanimation.value,
                                        child: CircleAvatar(
                                          backgroundColor: Color(0xff222222),
                                          radius: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8 *
                                              0.5,
                                          backgroundImage: NetworkImage(
                                              appState.getCurrentSong().image),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 30,
                                    ),
                                    child: Text(
                                      playingLyric,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.5),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            LyricList(
                              currentLyric: currentLyric,
                              currentLineNum: currentLineNum,
                              listy: listy,
                              scrollController: scrollController,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                          left: 0,
                          right: 0,
                          bottom: 50,
                          child: Transform.translate(
                            offset: Offset(0, bottomanimation.value),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 20,
                                      height: 8,
                                      margin: EdgeInsets.only(
                                        left: 4,
                                        right: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.8),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: EdgeInsets.only(
                                        left: 4,
                                        right: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.8),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: 30,
                                        child: Text(
                                          format(GlobalAudio.instance()
                                              .currentTime),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      NotificationListener<
                                          PercentChangeNotification>(
                                        onNotification: (notification) {
                                          GlobalAudio.instance().currentTime =
                                              (appState
                                                          .getCurrentSong()
                                                          .duration
                                                          .toDouble() *
                                                      notification.percent)
                                                  .toInt();
                                          setState(() {});
                                          if (notification.isEnd) {
                                            resume();
                                          } else {
                                            pause();
                                          }
                                        },
                                        child: ProgressBar(
                                          percent: GlobalAudio.instance()
                                                  .currentTime /
                                              appState
                                                  .getCurrentSong()
                                                  .duration,
                                        ),
                                      ),
                                      Container(
                                        width: 30,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          format(appState
                                              .getCurrentSong()
                                              .duration),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Icon(
                                              appState.mode == PlayMode.sequence
                                                  ? MusicIcons.sequence
                                                  : appState.mode ==
                                                          PlayMode.loop
                                                      ? MusicIcons.loop
                                                      : MusicIcons.random,
                                              size: 30,
                                              color: Color(0xffffcd32),
                                            ),
                                          ),
                                          onTap: () {
                                            changeMode();
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Icon(
                                              MusicIcons.prev,
                                              size: 30,
                                              color: Color(0xffffcd32),
                                            ),
                                          ),
                                          onTap: () {
                                            prev();
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: GestureDetector(
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: double.infinity,
                                            child: GlobalAudio.instance()
                                                    .isPlaying
                                                ? Icon(
                                                    MusicIcons.pause,
                                                    size: 40,
                                                    color: Color(0xffffcd32),
                                                  )
                                                : Icon(
                                                    MusicIcons.play,
                                                    size: 40,
                                                    color: Color(0xffffcd32),
                                                  ),
                                          ),
                                          onTap: () {
                                            if (GlobalAudio.instance()
                                                .isPlaying) {
                                              pause();
                                            } else {
                                              resume();
                                            }
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Icon(
                                              MusicIcons.next,
                                              size: 30,
                                              color: Color(0xffffcd32),
                                            ),
                                          ),
                                          onTap: () {
                                            next();
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Icon(
                                            MusicIcons.favorite,
                                            size: 30,
                                            color: Color(0xffffcd32),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      onWillPop: () {
        back();
        return Future.value(false);
      },
    );
  }
}

class MiniPlayer extends StatefulWidget {
  MiniPlayer({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return MiniPlayerState();
  }
}

class MiniPlayerState extends State<MiniPlayer> with TickerProviderStateMixin {
  bool isPlayListShow = false;
  AnimationController rotatecontroller;
  Animation<double> rotateanimation;
  AudioPlayer audioPlayer;
  bool isPlaying = false;
  int currentTime = 0;
  double initRotate = 0;
  AppState appState = AppState.instance();
  StreamSubscription<void> _subscription;
  @override
  void initState() {
    super.initState();
    print('miniinitState');
    rotatecontroller = new AnimationController(
        duration: const Duration(seconds: 20), vsync: this);
    double circle = 2 * pi;
    rotateanimation =
        new Tween(begin: 0.0, end: circle).animate(rotatecontroller)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              rotatecontroller.reset();
              rotatecontroller.forward();
            }
          })
          ..addListener(() {
            if (GlobalAudio.instance().isPlaying) {
              rotatecontroller.forward();
            } else {
              rotatecontroller.stop();
            }
            GlobalAudio.instance().rotate = rotateanimation.value / (2 * pi);
            setState(() => {});
          });
    if (GlobalAudio.instance().audioPlayer != null) {
      _subscription =
          GlobalAudio.instance().audioPlayer.onPlayerCompletion.listen((event) {
        print('end----');
        GlobalAudio.instance().currentTime = 0;
        if (appState.mode == PlayMode.loop) {
          this.loop();
        } else {
          this.next();
        }
      });
    }
  }

  @override
  void dispose() {
    print('minidispose');
    _subscription.cancel();
    rotatecontroller.dispose();
    super.dispose();
  }

  play() async {
    if (GlobalAudio.instance().audioPlayer != null) {
      int result = await GlobalAudio.instance()
          .audioPlayer
          .play(appState.getCurrentSong().url);
      if (result == 1) {}
    }
  }

  pause() {
    if (GlobalAudio.instance().audioPlayer != null) {
      rotatecontroller.stop();
      GlobalAudio.instance().isPlaying = false;
      setState(() {});
    }
  }

  resume() {
    print(GlobalAudio.instance().currentTime);
    GlobalAudio.instance()
        .audioPlayer
        .seek(Duration(seconds: GlobalAudio.instance().currentTime));
    rotatecontroller.forward();
    GlobalAudio.instance().isPlaying = true;
    setState(() {});
  }

  loop() {
    GlobalAudio.instance().currentTime = 0;
    resume();
  }

  next() async {
    GlobalAudio.instance().currentTime = 0;
    if (appState.playlist.length == 1) {
      loop();
    } else {
      int index = appState.currentIndex + 1;
      if (index == appState.playlist.length) {
        index = 0;
      }
      appState.currentIndex = index;
    }
  }

  updateTime() {
    if (GlobalAudio.instance().audioPlayer != null) {
      GlobalAudio.instance().audioPlayer.positionHandler = (Duration p) {
        setState(() {
          GlobalAudio.instance().currentTime = p.inSeconds;
        });
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (appState.getCurrentSong() != null && appState.isShow) {
      if (GlobalAudio.instance().isPlaying) {
        rotatecontroller.forward();
      }
      if (GlobalAudio.instance().needSyncRotate) {
        rotatecontroller.forward(from: GlobalAudio.instance().rotate);
        if (!GlobalAudio.instance().isPlaying) {
          rotatecontroller.stop();
        }
      }
    }
    return appState.isShow
        ?
        // ? Positioned(
        // left: 0,
        // right: 0,
        // bottom: 0,
        // top: 0,
        // child:
        Container(
            height: 60,
            child: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: double.infinity,
                    color: Color(0xff333333),
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 10,
                            ),
                            child: Transform.rotate(
                              angle: rotateanimation.value,
                              child: Hero(
                                tag: 'image',
                                createRectTween: (Rect begin, Rect end) {
                                  return RectTween(
                                    begin: Rect.fromLTRB(begin.left, begin.top,
                                        begin.right, begin.bottom),
                                    end: Rect.fromLTRB(end.left, end.top,
                                        end.right, end.bottom),
                                  );
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  child: CircleAvatar(
                                    backgroundColor: Color(0xff222222),
                                    backgroundImage: NetworkImage(
                                        appState.getCurrentSong().image),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
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
                                          child: PlayerPage(
                                            isMini: true,
                                          ) //路由B
                                          );
                                    }));
                          },
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(bottom: 2),
                                child: Text(
                                  appState.getCurrentSong().name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 2),
                                child: Text(
                                  appState.getCurrentSong().singer,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 0.3),
                                    fontSize: 12,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Container(
                              width: 40,
                              child: Icon(
                                GlobalAudio.instance().isPlaying
                                    ? MusicIcons.pausemini
                                    : MusicIcons.playmini,
                                color: Color.fromRGBO(255, 205, 49, 0.5),
                                size: 32,
                              ),
                            ),
                          ),
                          onTap: () {
                            if (GlobalAudio.instance().isPlaying) {
                              pause();
                            } else {
                              resume();
                            }
                          },
                        ),
                        GestureDetector(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Container(
                              width: 40,
                              child: Icon(
                                MusicIcons.playlist,
                                color: Color.fromRGBO(255, 205, 49, 0.5),
                                size: 32,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (BuildContext context,
                                      Animation animation,
                                      Animation secondaryAnimation) {
                                    return PlayList();
                                  }),
                            );
                            Toast.remove();
                            // setState(() {
                            //   isPlayListShow = true;
                            // });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Positioned(
                //   left: 0,
                //   bottom: 0,
                //   right: 0,
                //   child:
                // NotificationListener(
                //   child: PlayList(
                //     isShow: isPlayListShow,
                //   ),
                //   onNotification: (CloseNotification n) {
                //     setState(() {
                //       isPlayListShow = n.isShow;
                //     });
                //   },
                // ),
                // ),
              ],
            ),
          )
        // )
        : Container();
  }
}

class CloseNotification extends Notification {
  CloseNotification({@required this.isShow});
  bool isShow;
}

class ProgressBar extends StatefulWidget {
  double percent;
  ValueChanged<double> onChanged;
  ProgressBar({this.percent = 0.0, this.onChanged}) : super();
  @override
  State<StatefulWidget> createState() {
    return ProgressBarState();
  }
}

class ProgressBarState extends State<ProgressBar> {
  double width = 0.0;
  double _left = 0;
  double x;
  double barWidth = 0.0;
  bool _initiated = false;
  double startX = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      RenderObject renderObject = context.findRenderObject();
      x = renderObject.getTransformTo(null).getTranslation().x;
      barWidth = renderObject.paintBounds.size.width;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width * 0.8 - 60;
    if (!_initiated) {
      _left = widget.percent * barWidth;
    }

    return Expanded(
      flex: 1,
      child: GestureDetector(
        child: Container(
          height: 30,
          color: Color.fromRGBO(0, 0, 0, 0),
          alignment: Alignment.center,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Container(
                color: Color.fromRGBO(0, 0, 0, 0.3),
                height: 4,
              ),
              Positioned(
                left: 0,
                height: 4,
                width: _left,
                child: Container(
                  color: Color(0xffffcd32),
                ),
              ),
              Positioned(
                top: -6,
                left: 0,
                child: Transform.translate(
                  offset: Offset(_left, 0),
                  // child: GestureDetector(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Color(0xffffcd32),
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  // ),
                ),
              ),
            ],
          ),
        ),
        onTapUp: (details) {
          _left = details.globalPosition.dx - x;
          _left = min(barWidth - 17, max(0, _left));
          _triggerPercent();
          _triggerPercentEnd();
          print("onTapUp:${_left}");
          setState(() {
            _left = _left;
          });
        },
        onTapDown: (details) {
          _initiated = true;
          // startX = details.globalPosition.dx;
          _left = details.globalPosition.dx - x;
          _left = min(barWidth - 17, max(0, _left));
          _triggerPercent();
          setState(() {
            _left = _left;
          });
        },
        onPanUpdate: (DragUpdateDetails e) {
          if (!_initiated) {
            return;
          }
          // double deltaX = e.globalPosition.dx - startX;
          _left += e.delta.dx;
          _left = min(barWidth - 17, max(0, _left));

          setState(() {
            _left = _left;
          });
          _triggerPercent();
        },
        onPanEnd: (details) {
          setState(() {
            _initiated = false;
          });
          _triggerPercentEnd();
        },
      ),
    );
  }

  _triggerPercent() {
    // widget.onChanged(_getPercent());
    PercentChangeNotification(_getPercent(), false).dispatch(context);
  }

  _triggerPercentEnd() {
    // widget.onChanged(_getPercent());
    PercentChangeNotification(_getPercent(), true).dispatch(context);
  }

  double _getPercent() {
    double clientWidth = barWidth - 17;
    return _left / clientWidth;
  }
}

class PercentChangeNotification extends Notification {
  double percent = 0;
  bool isEnd = false;
  PercentChangeNotification(this.percent, this.isEnd);
}

class LyricList extends StatefulWidget {
  Lyric currentLyric;
  int currentLineNum;
  List<double> listy;
  ScrollController scrollController;
  LyricList({
    Key key,
    this.currentLyric,
    this.currentLineNum = 0,
    this.listy,
    this.scrollController,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return LyricListState();
  }
}

class LyricListState extends State<LyricList> {
  double lyriclisty = 0;
  List<Widget> currentLyrics = <Widget>[];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      RenderObject renderObject = context.findRenderObject();
      lyriclisty = renderObject.getTransformTo(null).getTranslation().y;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentLyric != null) {
      currentLyrics = List.generate(widget.currentLyric.lines.length, (i) {
        return LyricItem(
          txt: widget.currentLyric.lines[i]['txt'],
          currentLineNum: widget.currentLineNum,
          index: i,
          listy: widget.listy,
          lyriclisty: lyriclisty,
        );
      });
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: double.infinity,
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: ListView(
          controller: widget.scrollController,
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Column(
              children: currentLyrics,
            ),
          ],
        ),
      ),
    );
  }
}

class LyricItem extends StatefulWidget {
  LyricItem({
    Key key,
    this.txt = '',
    this.currentLineNum = 0,
    this.index,
    this.listy,
    this.lyriclisty,
  }) : super(key: key);
  String txt;
  int currentLineNum;
  int index;
  List<double> listy;
  double lyriclisty;
  @override
  State<StatefulWidget> createState() {
    return LyricItemState();
  }
}

class LyricItemState extends State<LyricItem> {
  double y;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      RenderObject renderObject = context.findRenderObject();
      y = renderObject.getTransformTo(null).getTranslation().y;
      if (widget.listy.length < widget.index) {
        widget.listy.add(y - widget.lyriclisty);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 32,
      child: Text(
        widget.txt,
        overflow: TextOverflow.clip,
        maxLines: 1,
        style: TextStyle(
          color: widget.currentLineNum == widget.index
              ? Colors.white
              : Color.fromRGBO(255, 255, 255, 0.5),
          fontSize: 14,
        ),
      ),
    );
  }
}
