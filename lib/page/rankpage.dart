import 'package:fluttermusic/api/rankapi.dart';
import 'package:fluttermusic/page/recommendpage.dart';
import 'package:fluttermusic/page/toplistpage.dart';
import 'package:flutter/material.dart';

class RankPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RankPageState();
  }
}

class RankPageState extends State<RankPage> {
  List<Widget> rankList = <Widget>[];
  @override
  void initState() {
    super.initState();
    setRankListDat();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Color(0xff222222),
      child: ListView(
        physics: ScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: rankList,
      ),
    );
  }

  setRankListDat() async {
    Map<String, dynamic> data = await RankApi().getTopList();
    List list = data['data']['topList'];
    rankList = List.generate(list.length, (i) {
      return TopListItem(
        item: list[i],
      );
    });
    setState(() {});
  }
}

class TopListItem extends StatelessWidget {
  TopListItem({Key key, this.item}) : super(key: key);
  Map<String, dynamic> item;
  @override
  Widget build(BuildContext context) {
    List songList = item['songList'];
    List<Widget> list = List.generate(songList.length, (i) {
      return Row(
        children: <Widget>[
          Container(
            height: 26,
            margin: EdgeInsets.only(top: 2),
            alignment: Alignment.centerLeft,
            child: Text(
              (i + 1).toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.3),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 26,
              alignment: Alignment.centerLeft,
              child: Text(
                "${songList[i]['songname']}-${songList[i]['singername']}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 0.3),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      );
    });
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(left: 20, right: 20),
        padding: EdgeInsets.only(top: 20),
        child: Row(
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              child: Image.network(
                item['picUrl'],
                width: 100,
                height: 100,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                height: 100,
                color: Color(0xff333333),
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: list,
                ),
              ),
            )
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
              return TopListPage(id: item['id'].toString());
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
