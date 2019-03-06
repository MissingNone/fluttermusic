import 'package:fluttermusic/api/recommendapi.dart';
import 'package:fluttermusic/api/songapi.dart';
import 'package:fluttermusic/common/icons.dart';
import 'package:fluttermusic/common/song.dart';
import 'package:fluttermusic/components/musiclist.dart';
import 'package:fluttermusic/components/songlist.dart';
import 'package:fluttermusic/page/playerpage.dart';
import 'package:fluttermusic/store/state.dart';
import 'package:flutter/material.dart';

class DiscPage extends StatefulWidget {
  String dissid;
  DiscPage({Key key, @required this.dissid}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return DiscPageState();
  }
}

class DiscPageState extends State<DiscPage> {
  List<Widget> songList = <Widget>[];
  List<Song> songs = [];
  String image = '';
  String dissname = '';
  AppState appState = AppState.instance();
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   print('didChangeDependencies');
  //   if (appState == null) {
  //     appState = AppStateContainer.of(context);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    setSongListData(widget.dissid);
  }

  @override
  void dispose() {
    super.dispose();
  }

  setSongListData(String disstid) async {
    Map<String, dynamic> data = await RecommendApi().getSongList(disstid);
    List list = data['cdlist'][0]['songlist'];
    songs = this._normalizeSongs(list);
    Map<String, dynamic> songData = await SongApi().getPurlUrl(songs);
    if (songData['url_mid']['data']['midurlinfo'] != null &&
        songData['url_mid']['data']['midurlinfo'][0]['purl'] != null) {
      int i = 0;
      songs.forEach((s) {
        s.url = songData['url_mid']['data']['midurlinfo'][i]['purl'];
        i++;
      });
    }

    image = data['cdlist'][0]['logo'];
    dissname = data['cdlist'][0]['dissname'];
    setState(() {});
  }

  List<Song> _normalizeSongs(List list) {
    List<Song> ret = [];
    list.forEach((musicData) {
      if (isValidMusic(musicData)) {
        ret.add(createSong(musicData));
      }
    });
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return MusicList(
      title: dissname,
      bgImage: image,
      songs: songs,
    );
  }
}
