import 'dart:math';

import 'package:fluttermusic/common/globalaudio.dart';
import 'package:fluttermusic/components/playlist.dart';
import 'package:fluttermusic/store/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class TestPager extends StatefulWidget {
  static TestPager _pager;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TestPagerState();
  }

  static TestPager instance() {
    if (_pager == null) {
      print('in');
      _pager = TestPager();
    }
    return _pager;
  }
}

class TestPagerState extends State<TestPager> with TickerProviderStateMixin {
  ScrollController _scrollController;
  double headTop = 0;
  double diff = 0;
  String title = "";
  List<double> listHeight = <double>[];
  List<String> listText = <String>[
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z'
  ];
  List<double> indexlistHeight = <double>[];
  int currentIndex = 0;
  @override
  void initState() {
    super.initState();
    print('initState');
    double height = 0;
    listHeight.add(height);
    for (int i = 0; i < listText.length; i++) {
      height += 216;
      listHeight.add(height);
    }
    // double indexheight = 72;
    // indexlistHeight.add(indexheight);
    // indexheight = 102;
    // indexlistHeight.add(indexheight);
    // for (int i = 0; i < listText.length; i++) {
    //   indexheight += 20;
    //   indexlistHeight.add(indexheight);
    // }
    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset < 0) {
        title = "";
        setState(() {});
      }
      for (int i = 0; i < listText.length - 1; i++) {
        double height1 = listHeight[i];
        double height2 = listHeight[i + 1];
        if (_scrollController.offset >= height1 &&
            _scrollController.offset < height2) {
          currentIndex = i;
          title = "${listText[currentIndex]}";
          setState(() {});
          diff = height2 - _scrollController.offset;
          double fixedTop = (diff > 0 && diff < 50) ? diff - 50 : 0;
          if (headTop == fixedTop) {
            return;
          }
          headTop = fixedTop;
          setState(() {});
          return;
        }
      }
    });
  }

  int _getIndex(int offset) {
    for (int i = 0; i < listText.length - 1; i++) {
      double height1 = indexlistHeight[i];
      double height2 = indexlistHeight[i + 1];
      if (offset >= height1 && offset < height2) {
        return i;
      }
    }
    return -1;
  }

  @override
  void dispose() {
    print('dispose');
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("轮播图"),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: ListView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              children: List.generate(listText.length, (i) {
                return Container(
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 50,
                        color: Colors.yellow,
                        margin: EdgeInsets.only(
                          bottom: 4,
                        ),
                        child: Text("${listText[i]}"),
                      ),
                      Container(
                        width: double.infinity,
                        height: 50,
                        color: Colors.white,
                        margin: EdgeInsets.only(
                          bottom: 4,
                        ),
                        child: Text("${listText[i]}-${listText[i]}"),
                      ),
                      Container(
                        width: double.infinity,
                        height: 50,
                        color: Colors.white,
                        margin: EdgeInsets.only(
                          bottom: 4,
                        ),
                        child: Text("${listText[i]}-${listText[i]}"),
                      ),
                      Container(
                        width: double.infinity,
                        height: 50,
                        color: Colors.white,
                        margin: EdgeInsets.only(
                          bottom: 4,
                        ),
                        child: Text("${listText[i]}-${listText[i]}"),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          title != ""
              ? Positioned(
                  left: 0,
                  right: 0,
                  top: headTop,
                  child: Container(
                    height: 50,
                    color: Colors.yellow,
                    child: Text(title),
                  ),
                )
              : Container(),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              child: indexBarItemList(
                currentIndex: currentIndex,
                indexlistHeight: indexlistHeight,
              ),
              onVerticalDragDown: (DragDownDetails details) {
                int offset = details.globalPosition.dy.toInt();
                print(offset);
                int index = _getIndex(offset);
                if (index != -1) {
                  currentIndex = index;
                  setState(() {});
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class indexBarItemList extends StatelessWidget {
  indexBarItemList({
    this.currentIndex,
    this.indexlistHeight,
  });
  int currentIndex;
  List<double> indexlistHeight;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: 20,
      padding: EdgeInsets.only(top: 10, bottom: 10),
      color: Color.fromRGBO(0, 0, 0, 0.7),
      child: Column(
        children: List.generate(20, (i) {
          return indexBarItem(
            title: "${i}",
            index: i,
            currentIndex: currentIndex,
            indexlistHeight: indexlistHeight,
          );
        }),
      ),
    );
  }
}

class indexBarItem extends StatelessWidget {
  indexBarItem({
    this.title,
    this.index,
    this.currentIndex,
    this.indexlistHeight,
  });
  String title;
  int currentIndex;
  int index;
  List<double> indexlistHeight;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((d) {
      RenderObject renderObject = context.findRenderObject();
      double y = renderObject.getTransformTo(null)?.getTranslation().y;
      if (indexlistHeight.length == index) {
        indexlistHeight.add(y);
        // print("${y}-${title}");
      }
    });
    return Container(
      padding: EdgeInsets.all(3),
      width: 20,
      alignment: Alignment.center,
      child: Text(
        "${title}".substring(0, 1),
        style: TextStyle(
          color: currentIndex == index
              ? Color(0xffffcd32)
              : Color.fromRGBO(255, 255, 255, 0.5),
          fontSize: 12,
        ),
      ),
    );
  }
}
