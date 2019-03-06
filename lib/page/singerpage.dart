import 'package:fluttermusic/api/singerapi.dart';
import 'package:fluttermusic/components/lazyimagelistview.dart';
import 'package:fluttermusic/page/recommendpage.dart';
import 'package:fluttermusic/page/singerdetailpage.dart';
import 'package:flutter/material.dart';

const HOT_SINGER_LEN = 10;
const HOT_NAME = '热门';
const TITLE_HEIGHT = 30;

class SingerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SingerPageState();
  }
}

class SingerPageState extends State<SingerPage> {
  List<Widget> singerList = <Widget>[];
  ScrollController _scrollController;
  bool _mounted = true;
  double headTop = 0;
  double _diff = 0;
  double get diff => _diff;
  set diff(newVal) {
    if (newVal == _diff) {
      return;
    }
    double fixedTop =
        (newVal > 0 && newVal < TITLE_HEIGHT) ? newVal - TITLE_HEIGHT : 0;
    if (headTop == fixedTop) {
      return;
    }
    headTop = fixedTop;
    setState(() {});
    _diff = newVal;
  }

  String title = "";
  List<double> listHeight = <double>[];
  List<double> indexlistHeight = <double>[];
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  set currentIndex(newVal) {
    _currentIndex = newVal;
    title = "${mapList[_currentIndex]['title']}";
    setState(() {});
  }

  List mapList = <Map>[];
  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset < 0) {
        title = "";
        setState(() {});
      }
      for (int i = 0; i < listHeight.length - 1; i++) {
        double height1 = listHeight[i];
        double height2 = listHeight[i + 1];
        if (_scrollController.offset >= height1 &&
            _scrollController.offset < height2) {
          currentIndex = i;
          this.diff = height2 - _scrollController.offset;
          return;
        }
      }
    });
    setSingerData();
  }

  @override
  void dispose() {
    _mounted = false;
    _scrollController.dispose();
    super.dispose();
  }

  setSingerData() async {
    Map<String, dynamic> data = await SingerApi().getSingerList();
    List list = data['data']['list'];
    mapList = _normalizeSinger(list);

    if (_mounted) {
      singerList = List.generate(mapList.length, (i) {
        return SingerListIndexItem(
          map: mapList[i],
          scrollController: _scrollController,
          index: i,
          listHeight: listHeight,
        );
      });
      setState(() {});
    }
  }

  List _normalizeSinger(List list) {
    Map<String, dynamic> map = {
      'hot': {
        'title': HOT_NAME,
        'items': [],
      },
    };
    List.generate(list.length, (i) {
      if (i < HOT_SINGER_LEN) {
        map['hot']['items'].add({
          'name': list[i]['Fsinger_name'],
          'id': list[i]['Fsinger_mid'],
        });
      }
      String key = list[i]['Findex'];
      if (map[key] == null) {
        map[key] = {
          'title': key,
          'items': [],
        };
      }
      map[key]['items'].add({
        'name': list[i]['Fsinger_name'],
        'id': list[i]['Fsinger_mid'],
      });
    });
    // 为了得到有序列表，我们需要处理 map
    List ret = [];
    List hot = [];
    map.forEach((key, value) {
      Map val = map[key];
      if (RegExp("[a-zA-Z]").hasMatch(val['title'])) {
        ret.add(val);
      } else if (val['title'] == HOT_NAME) {
        hot.add(val);
      }
    });
    ret.sort((a, b) {
      return a['title'].codeUnitAt(0) - b['title'].codeUnitAt(0);
    });
    hot.addAll(ret);
    return hot;
  }

  int _getIndex(int offset) {
    for (int i = 0; i < indexlistHeight.length - 1; i++) {
      double height1 = indexlistHeight[i];
      double height2 = indexlistHeight[i + 1];
      if (offset >= height1 && offset < height2) {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          color: Color(0xff222222),
          child: LazyImageListView(
            scrollController: _scrollController,
            children: <Widget>[
              Column(
                children: singerList,
              ),
            ],
          ),
        ),
        title != ""
            ? Positioned(
                left: 0,
                right: 0,
                top: headTop,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  height: 30,
                  color: Color(0xff333333),
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            : Container(),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            child: Container(
              width: 20,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: List.generate(
                  mapList.length,
                  (i) {
                    return indexBarItem(
                      index: i,
                      currentIndex: currentIndex,
                      listText: mapList[i]['title'],
                      indexlistHeight: indexlistHeight,
                      maxLength: mapList.length,
                    );
                  },
                ),
              ),
            ),
            onVerticalDragDown: (DragDownDetails details) {
              int offset = details.globalPosition.dy.toInt();

              int index = _getIndex(offset);
              if (index != -1) {
                _scrollController.jumpTo(listHeight[index]);
                currentIndex = index;
              }
            },
            onVerticalDragUpdate: (DragUpdateDetails details) {
              int offset = details.globalPosition.dy.toInt();
              int index = _getIndex(offset);
              if (index != -1) {
                _scrollController.jumpTo(listHeight[index]);
                currentIndex = index;
              }
            },
          ),
        ),
      ],
    );
  }
}

class SingerListIndexItem extends StatelessWidget {
  SingerListIndexItem({
    Key key,
    this.map,
    this.scrollController,
    this.index,
    this.listHeight,
  }) : super(key: key);
  Map<String, dynamic> map = {};
  ScrollController scrollController;
  int index;
  List<double> listHeight;
  @override
  Widget build(BuildContext context) {
    List<dynamic> singerItems = map['items'];
    List<Widget> items = List.generate(singerItems.length, (i) {
      return GestureDetector(
        child: SingerListItem(
          name: singerItems[i]['name'],
          id: singerItems[i]['id'],
          scrollController: scrollController,
        ),
        onTap: () {
          Navigator.push(
              context,
              new PageRouteBuilder(pageBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                // 跳转的路由对象
                return SingerDetailPage(
                  id: singerItems[i]['id'].toString(),
                  title: singerItems[i]['name'],
                );
              }, transitionsBuilder: (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child,
              ) {
                return createTransition(animation, child);
              }));
        },
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((d) {
      RenderObject renderObject = context.findRenderObject();
      double height = renderObject.paintBounds.size.height;
      if (index == 0) {
        listHeight.add(0);
      }
      listHeight.add(listHeight.elementAt(index) + height);
    });
    return Container(
      padding: EdgeInsets.only(bottom: 30),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            height: 30,
            color: Color(0xff333333),
            padding: EdgeInsets.only(left: 20),
            child: Text(
              map['title'],
              style: TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.5),
                fontSize: 12,
              ),
            ),
          ),
          Column(
            children: items,
          ),
        ],
      ),
    );
  }
}

class SingerListItem extends StatelessWidget {
  SingerListItem({
    Key key,
    this.name,
    this.id,
    this.scrollController,
  }) : super(key: key);
  String name;
  String id;
  ScrollController scrollController;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.only(top: 20, left: 30),
      child: Row(
        children: <Widget>[
          ImagePositon(
            scrollController: scrollController,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xff222222),
              backgroundImage: NetworkImage(
                  'https://y.gtimg.cn/music/photo_new/T001R300x300M000${id}.jpg?max_age=2592000'),
            ),
            defaultView: CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xff222222),
              backgroundImage: AssetImage("images/default.png"),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20),
            child: Text(
              name,
              style: TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.5),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class indexBarItem extends StatelessWidget {
  indexBarItem({
    Key key,
    this.index,
    this.currentIndex,
    this.indexlistHeight,
    this.listText,
    this.maxLength,
  }) : super(key: key);
  int index;
  int currentIndex;
  List<double> indexlistHeight;
  String listText;
  int maxLength;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((d) {
      RenderObject renderObject = context.findRenderObject();
      double y = renderObject.getTransformTo(null)?.getTranslation().y;
      if (indexlistHeight.length == index) {
        indexlistHeight.add(y);
        if (index == 0) {
          indexlistHeight[index] = y - 10;
        }
        if (maxLength - 1 == index) {
          indexlistHeight.add(y + 20 + 10);
        }
        print(indexlistHeight.length);
      }
    });
    return Container(
      padding: EdgeInsets.all(3),
      width: 20,
      alignment: Alignment.center,
      child: Text(
        "${listText}".substring(0, 1),
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
