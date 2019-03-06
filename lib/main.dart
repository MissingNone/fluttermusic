import 'dart:convert';
import 'dart:typed_data';

import 'package:fluttermusic/common/globalaudio.dart';
import 'package:fluttermusic/components/confirm.dart';
import 'package:fluttermusic/components/playlist.dart';
import 'package:fluttermusic/page/playerpage.dart';
import 'package:fluttermusic/page/rankpage.dart';
import 'package:fluttermusic/page/recommendpage.dart';
import 'package:fluttermusic/page/searchpage.dart';
import 'package:fluttermusic/page/singerpage.dart';
import 'package:fluttermusic/page/testpage.dart';
import 'package:fluttermusic/page/testpage1.dart';
import 'package:fluttermusic/store/state.dart';
import 'package:fluttermusic/util/lyircparser.dart';
import 'package:flutter/material.dart';
import 'page/swiperpage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: RecommendPage(),
      routes: <String, WidgetBuilder>{
        '/confirm': (BuildContext context) => new Confirm(),
        '/singer': (BuildContext context) => new SingerPage(),
        '/rank': (BuildContext context) => new RankPage(),
        '/search': (BuildContext context) => new SearchPage()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double value = 0;
  // AppState appState;
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (appState == null) {
  //     appState = AppStateContainer.of(context);
  //   }
  // }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Stack(
          children: <Widget>[
            Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: Column(
                // Column is also layout widget. It takes a list of children and
                // arranges them vertically. By default, it sizes itself to fit its
                // children horizontally, and tries to be as tall as its parent.
                //
                // Invoke "debug painting" (press "p" in the console, choose the
                // "Toggle Debug Paint" action from the Flutter Inspector in Android
                // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                // to see the wireframe for each widget.
                //
                // Column has various properties to control how it sizes itself and
                // how it positions its children. Here we use mainAxisAlignment to
                // center the children vertically; the main axis here is the vertical
                // axis because Columns are vertical (the cross axis would be
                // horizontal).
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.display1,
                  ),
                  FlatButton(
                    child:
                        Text("open ${GlobalAudio.instance().isPlaying} route"),
                    textColor: Colors.blue,
                    onPressed: () {
                      //导航到新路由
                      // Navigator.push(context,
                      //     new MaterialPageRoute(builder: (context) {
                      //   return new TestPager();
                      // }));
                      // Navigator.push(
                      //   context,
                      //   PageRouteBuilder(
                      //       opaque: false,
                      //       pageBuilder: (BuildContext context,
                      //           Animation animation,
                      //           Animation secondaryAnimation) {
                      //         return NotificationListener<ConfirmNotification>(
                      //           onNotification: (notification) {
                      //             setState(() {
                      //               appState.isShow = !appState.isShow;
                      //             });
                      //           },
                      //           child: Confirm(),
                      //         );
                      //       }),
                      // );
                      Toast.remove();
                    },
                  ),
                  FlatButton(
                    child: Text("open RecommendPage route"),
                    textColor: Colors.blue,
                    onPressed: () {
                      //导航到新路由
                      Navigator.push(context,
                          new MaterialPageRoute(builder: (context) {
                        return new RecommendPage();
                      }));
                    },
                  ),
                  FlatButton(
                    child: Text("open SingerPage route"),
                    textColor: Colors.blue,
                    onPressed: () {
                      //导航到新路由
                      Toast.show(context);
                    },
                  ),
                  FlatButton(
                    child: Text("open TestPager route"),
                    textColor: Colors.blue,
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(pageBuilder: (BuildContext context,
                            Animation animation, Animation secondaryAnimation) {
                          return TestPager.instance();
                        }),
                      );
                    },
                  ),
                  FlatButton(
                    child: Text("open TestPage route"),
                    textColor: Colors.blue,
                    onPressed: () {
                      //导航到新路由
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
                      // Navigator.push(context,
                      //     new MaterialPageRoute(builder: (context) {
                      //   return new PlayerPage();
                      // }));
                    },
                  ),
                  Slider(
                    value: value,
                    onChanged: (val) {
                      setState(() {
                        value = val;
                      });
                    },
                  ),
                  ProgressBar(
                    percent: value,
                    onChanged: (val) {
                      setState(() {
                        value = val;
                      });
                    },
                  ),
                  // BlackContainer(),
                ],
              ),
            ),
            // PlayList(),
            // MiniPlayer(
            //   isMiniPlayerShow: true,
            // ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Toast {
  static OverlayEntry overlayEntry;
  static OverlayState overlayState;
  static show(BuildContext context) {
    overlayState = Overlay.of(context);
    overlayEntry = new OverlayEntry(builder: (context) {
      return buildToastLayout();
    });
    overlayState.insert(overlayEntry);
  }

  static remove() {
    overlayEntry?.remove();
  }

  static LayoutBuilder buildToastLayout() {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        child: Material(
          color: Colors.white.withOpacity(0),
          child: MiniPlayer(),
        ),
        alignment: Alignment.bottomCenter,
      );
    });
  }
}

class BlackContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BlackContainerState();
  }
}

class BlackContainerState extends State<BlackContainer> {
  AppState appState = AppState.instance();
  bool isShow = false;
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (appState == null) {
  //     appState = AppStateContainer.of(context);
  //   }
  // }
  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onTap: () {
                  print(22);
                },
              ),
              GestureDetector(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onTap: () {
                  setState(() {
                    isShow = true;
                  });
                },
              ),
            ],
          ),
          isShow
              ? Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.red,
                      child: GestureDetector(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              height: 40,
                              width: 360,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        onTap: () {
                          print(22);
                          setState(() {
                            isShow = false;
                          });
                        },
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
