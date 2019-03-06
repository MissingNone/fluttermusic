import 'package:fluttermusic/api/searchapi.dart';
import 'package:fluttermusic/components/suggest.dart';
import 'package:flutter/material.dart';

const HOT_KEY_LEN = 10;

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchPageState();
  }
}

class SearchPageState extends State<SearchPage> {
  String query = '';
  List<Widget> hotKeyList = <Widget>[];
  List<String> suggestList = <String>[];
  @override
  void initState() {
    super.initState();
    setHotKeyData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  setHotKeyData() async {
    Map<String, dynamic> data = await SearchApi().getHotKey();
    List list = data['data']['hotkey'];
    hotKeyList = List.generate(HOT_KEY_LEN, (i) {
      return Container(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        margin: EdgeInsets.only(right: 20, bottom: 10),
        decoration: BoxDecoration(
          color: Color(0xff333333),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          list[i]['k'].trim(),
          style: TextStyle(
            color: Color.fromRGBO(255, 255, 255, 0.3),
            fontSize: 14,
          ),
        ),
      );
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Color(0xff222222),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              height: 40,
              padding: EdgeInsets.only(
                left: 6,
                right: 6,
              ),
              decoration: BoxDecoration(
                color: Color(0xff333333),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                style: TextStyle(
                  color: Colors.white,
                ),
                onChanged: (v) {
                  query = v;

                  setState(() {});
                },
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "搜索歌曲、歌手",
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.5),
                  ),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.cancel),
                ),
              ),
            ),
          ),
          query != ''
              ? Suggest(
                  query: query,
                )
              : Container(
                  width: double.infinity,
                  margin:
                      EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 20),
                        child: Text(
                          "热门搜索",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(255, 255, 255, 0.5),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Wrap(
                          children: hotKeyList,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
