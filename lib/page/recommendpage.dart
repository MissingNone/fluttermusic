import 'package:fluttermusic/api/recommendapi.dart';
import 'package:fluttermusic/components/lazyimagelistview.dart';
import 'package:fluttermusic/components/loading.dart';
import 'package:fluttermusic/page/discpage.dart';
import 'package:fluttermusic/page/playerpage.dart';
import 'package:fluttermusic/page/rankpage.dart';
import 'package:fluttermusic/page/searchpage.dart';
import 'package:fluttermusic/page/singerpage.dart';
import 'package:fluttermusic/page/swiperpage.dart';
import 'package:fluttermusic/store/state.dart';
import 'package:flutter/material.dart';

class RecommendPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RecommendPageState();
  }
}

class RecommendPageState extends State<RecommendPage>
    with SingleTickerProviderStateMixin {
  List<Widget> arr = <Widget>[];
  List<Widget> children = <Widget>[];
  List<Widget> discList = <Widget>[];
  double width;
  int currentIndex = 0;
  TabController _tabController;
  ScrollController _scrollController;
  AppState appState = AppState.instance();
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (appState == null) {
  //     appState = AppStateContainer.of(context);
  //   }
  // }

  @override
  void initState() {
    setData();
    setDiscData();

    super.initState();
    _tabController = new TabController(vsync: this, length: 4);
    _scrollController = new ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  setData() async {
    Map<String, dynamic> data = await RecommendApi().getRecommend();
    List list = data['data']['slider'];
    Map first = list[0];
    Map last = list[list.length - 1];
    list.add(first);
    list.insert(0, last);
    List<Widget> _children = List.generate(list.length, (i) {
      return Container(
        width: width,
        child: Image.network(
          list[i]['picUrl'],
          fit: BoxFit.cover,
        ),
      );
    });
    children = _children;
    setState(() {});
  }

  setDiscData() async {
    Map<String, dynamic> data = await RecommendApi().getDiscList();
    List list = data['data']['list'];
    List<Widget> _children = List.generate(list.length, (i) {
      return DiscItem(
        image: list[i]['imgurl'],
        title: list[i]['creator']['name'],
        desc: list[i]['dissname'],
        dissid: list[i]['dissid'],
        scrollController: _scrollController,
        index: i,
      );
    });
    discList = _children;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    Swiper _swiper = Swiper(
      children: children,
    );
    if (children.length > 0) {
      arr = List<Widget>.generate(children.length - 2, (i) {
        if (i == currentIndex) {
          return Container(
            width: 20,
            height: 8,
            margin: EdgeInsets.only(left: 4, right: 4),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.8),
              borderRadius: BorderRadius.circular(4.0),
            ),
          );
        }
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(left: 4, right: 4),
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.5),
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      });
    }

    return ConstrainedBox(
      constraints: BoxConstraints.expand(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Color(0xff222222),
              title: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 6, right: 9),
                      child: Image.asset("images/logo@2x.png",
                          height: 32, width: 30),
                    ),
                    Text(
                      "Chicken Music",
                      style: TextStyle(
                        color: Color(0xffffcd32),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              bottom: new TabBar(
                controller: _tabController,
                labelColor: Color(0xffffcd32),
                indicatorColor: Color(0xffffcd32),
                unselectedLabelColor: Color.fromRGBO(255, 255, 255, 0.5),
                tabs: <Widget>[
                  new Tab(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text("推荐"),
                    ),
                  ),
                  new Tab(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text("歌手"),
                    ),
                  ),
                  new Tab(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text("排行"),
                    ),
                  ),
                  new Tab(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text("搜索"),
                    ),
                  ),
                ],
              ),
            ),
            body: new TabBarView(controller: _tabController, children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    color: Color(0xff222222),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: LazyImageListView(
                            scrollController: _scrollController,
                            children: <Widget>[
                              Container(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    NotificationListener<MyNotification>(
                                      onNotification: (notification) {
                                        setState(() {
                                          currentIndex =
                                              ((notification.offset - 360) /
                                                      360)
                                                  .toInt();
                                        });
                                      },
                                      child: children.length == 0
                                          ? Container()
                                          : _swiper,
                                    ),
                                    Positioned(
                                      bottom: 12.0,
                                      child: Row(
                                        children: arr,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 65,
                                alignment: Alignment.center,
                                child: Text(
                                  "热门歌单推荐",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xffffcd32),
                                  ),
                                ),
                              ),
                              discList.length > 0
                                  ? Column(
                                      children: discList,
                                    )
                                  : Container(),
                            ],
                          ),
                        ),

                        // Stack(
                        //   alignment: Alignment.center,
                        //   children: <Widget>[
                        //     NotificationListener<MyNotification>(
                        //       onNotification: (notification) {
                        //         setState(() {
                        //           currentIndex = ((notification.offset - 360) / 360).toInt();
                        //         });
                        //       },
                        //       child: children.length == 0 ? Container() : _swiper,
                        //     ),
                        //     Positioned(
                        //       bottom: 18.0,
                        //       child: Row(
                        //         children: arr,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  discList.length > 0 ? Container() : Loading(),
                ],
              ),
              SingerPage(),
              RankPage(),
              SearchPage(),
            ]),
          ),
          // MiniPlayer(),
        ],
      ),
    );
  }
}

class Tabs extends StatelessWidget {
  Tabs({
    Key key,
    this.currentIndex = 0,
    this.tabItems = const <String>[],
  }) : super(key: key);
  int currentIndex;
  List<String> tabItems;
  List<String> _tabPaths = [
    '/recommend',
    '/singer',
    '/rank',
    '/search',
  ];
  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(tabItems.length, (i) {
      if (currentIndex == i) {
        return Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xffffcd32),
                  width: 2,
                ),
              ),
            ),
            child: Text(
              tabItems[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xffffcd32),
                fontSize: 14,
              ),
            ),
          ),
        );
      }
      return MyTab(text: tabItems[i], path: _tabPaths[i]);
    });
    return Container(
      height: 44,
      width: double.infinity,
      child: Row(
        children: items,
      ),
    );
  }
}

class MyTab extends StatelessWidget {
  MyTab({Key key, this.path, this.text}) : super(key: key);
  String path;
  String text;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        child: Container(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.5),
              fontSize: 14,
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(path);
        },
      ),
    );
  }
}

class DiscItem extends StatelessWidget {
  DiscItem({
    Key key,
    this.image,
    this.title,
    this.desc,
    this.dissid,
    this.scrollController,
    this.index,
  }) : super(key: key);
  String image;
  String title;
  String desc;
  String dissid;
  ScrollController scrollController;
  int index;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //当Container没有设置颜色时点击事件无效;
      child: Container(
        color: Color(0xff222222),
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 0),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 20),
              child: ImagePositon(
                scrollController: scrollController,
                index: index,
                defaultView: Image.asset(
                  "images/default.png",
                  width: 60,
                  height: 60,
                ),
                child: Image.network(
                  image,
                  width: 60,
                  height: 60,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    width: double.infinity,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Text(
                      desc,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(255, 255, 255, 0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            new PageRouteBuilder(pageBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation) {
              // 跳转的路由对象
              return DiscPage(dissid: dissid);
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
  }
}

SlideTransition createTransition(Animation<double> animation, Widget child) {
  return new SlideTransition(
    position: new Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(animation),
    child: child,
  );
}
