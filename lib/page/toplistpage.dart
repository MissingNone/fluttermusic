import 'package:fluttermusic/api/rankapi.dart';
import 'package:fluttermusic/api/songapi.dart';
import 'package:fluttermusic/common/song.dart';
import 'package:fluttermusic/components/musiclist.dart';
import 'package:fluttermusic/store/state.dart';
import 'package:flutter/material.dart';

class TopListPage extends StatefulWidget {
  String id;
  TopListPage({Key key, this.id}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return TopListPageState();
  }
}

class TopListPageState extends State<TopListPage> {
  List<Song> songs = <Song>[];
  String topTitle = '';
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
    super.initState();
    setTopListData(widget.id);
  }

  setTopListData(String id) async {
    Map<String, dynamic> data = await RankApi().getMusicList(id);
    List list = data['songlist'];
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
    topTitle = data['topinfo']['ListName'];
    setState(() {});
  }

  List<Song> _normalizeSongs(List list) {
    List<Song> ret = [];
    list.forEach((item) {
      var musicData = item['data'];
      if (isValidMusic(musicData)) {
        ret.add(createSong(musicData));
      }
    });
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    String bgImage = songs.length > 0 ? songs[0].image : '';
    return MusicList(
      title: topTitle,
      bgImage: bgImage,
      songs: songs,
      rank: true,
    );
  }
}
