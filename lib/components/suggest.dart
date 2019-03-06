import 'dart:convert';

import 'package:fluttermusic/api/searchapi.dart';
import 'package:fluttermusic/api/songapi.dart';
import 'package:fluttermusic/common/icons.dart';
import 'package:fluttermusic/common/song.dart';
import 'package:fluttermusic/components/loading.dart';
import 'package:fluttermusic/page/playerpage.dart';
import 'package:fluttermusic/page/recommendpage.dart';
import 'package:fluttermusic/page/singerdetailpage.dart';
import 'package:fluttermusic/store/state.dart';
import 'package:flutter/material.dart';

const loadingTag = "##loading##"; //表尾标记
const TYPE_SINGER = 'singer';

class Suggest extends StatefulWidget {
  String query;
  Suggest({
    Key key,
    this.query = '',
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SuggestState();
  }
}

class SuggestState extends State<Suggest> {
  List suggestList = <dynamic>[loadingTag];
  int totalnum = 0;
  int page = 1;
  setSearchData(String query) async {
    Map<String, dynamic> data = await SearchApi().search(query, page);
    List list = this._genResult(data['data']);
    Map<String, dynamic> songData = await SongApi().getPurlUrl(list);
    if (songData['url_mid']['data']['midurlinfo'] != null &&
        songData['url_mid']['data']['midurlinfo'][0]['purl'] != null) {
      int i = 0;
      list.forEach((s) {
        if (s is Song) {
          s.url = songData['url_mid']['data']['midurlinfo'][i]['purl'];
          i++;
        }
      });
    }
    totalnum = data['data']['song']['totalnum'];
    suggestList.insertAll(
        suggestList.length - 1,
        List.generate(list.length, (i) {
          return list[i];
        }));
    setState(() {});
  }

  searchMore() async {
    Map<String, dynamic> data = await SearchApi().search(widget.query, page);
    List list = this._genResult(data['data']);
    Map<String, dynamic> songData = await SongApi().getPurlUrl(list);
    if (songData['url_mid']['data']['midurlinfo'] != null &&
        songData['url_mid']['data']['midurlinfo'][0]['purl'] != null) {
      int i = 0;
      list.forEach((s) {
        if (s is Song) {
          s.url = songData['url_mid']['data']['midurlinfo'][i]['purl'];
          i++;
        }
      });
    }
    suggestList.insertAll(
        suggestList.length - 1,
        List.generate(list.length, (i) {
          return list[i];
        }));
    setState(() {});
  }

  String getDisplayName(item) {
    if (item is! Song) {
      return item['singername'];
    } else {
      return "${item.name}-${item.singer}";
    }
  }

  bool getIconCls(item) {
    if (item is! Song) {
      return true;
    } else {
      return false;
    }
  }

  List _genResult(data) {
    List ret = [];
    if (data['zhida'] != null &&
        data['zhida']['singerid'] != null &&
        this.page == 1) {
      Map singer = data['zhida'];
      singer['type'] = TYPE_SINGER;
      ret.add(singer);
    }

    ret.addAll(this._normalizeSongs(data['song']['list']));

    return ret;
  }

  List<Song> _normalizeSongs(list) {
    List<Song> ret = [];
    list.forEach((musicData) {
      if (isValidMusic(musicData)) {
        ret.add(createSong(musicData));
      }
    });
    return ret;
  }

  @override
  void initState() {
    super.initState();
    if (widget.query != '') {
      setSearchData(widget.query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 30,
          right: 30,
        ),
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: suggestList.length,
          itemBuilder: (BuildContext context, int index) {
            if (suggestList[index] == loadingTag) {
              if (suggestList.length - 1 < totalnum) {
                page++;
                searchMore();
                return Loading(
                  title: '',
                );
              } else {
                return Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "没有更多了",
                      style: TextStyle(color: Colors.grey),
                    ));
              }
            }
            return GestureDetector(
              child: Container(
                padding: EdgeInsets.only(bottom: 20),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 30,
                      child: Icon(
                        getIconCls(suggestList[index])
                            ? MusicIcons.mine
                            : MusicIcons.music,
                        size: 14,
                        color: Color.fromRGBO(255, 255, 255, 0.3),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Text(
                          getDisplayName(suggestList[index]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.3),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                if (suggestList[index] is! Song) {
                  Navigator.push(
                      context,
                      new PageRouteBuilder(pageBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation) {
                        // 跳转的路由对象
                        return SingerDetailPage(
                          id: suggestList[index]['singermid'].toString(),
                          title: suggestList[index]['singername'],
                        );
                      }, transitionsBuilder: (
                        BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation,
                        Widget child,
                      ) {
                        return createTransition(animation, child);
                      }));
                } else {
                  AppState.instance().insertSong(suggestList[index]);
                  setState(() {});
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
                }
              },
            );
          },
        ),
      ),
    );
  }
}
