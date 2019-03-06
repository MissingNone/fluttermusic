import 'package:fluttermusic/api/singerapi.dart';
import 'package:fluttermusic/api/songapi.dart';
import 'package:fluttermusic/common/song.dart';
import 'package:fluttermusic/components/musiclist.dart';
import 'package:flutter/material.dart';

class SingerDetailPage extends StatefulWidget {
  String id;
  String title;
  SingerDetailPage({Key key, this.id, this.title}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return SingerDetailPageState();
  }
}

class SingerDetailPageState extends State<SingerDetailPage> {
  List<Song> songs = <Song>[];
  String title = '';
  List<Song> _normalizeSongs(List list) {
    List<Song> ret = [];
    list.forEach((item) {
      var musicData = item['musicData'];
      if (isValidMusic(musicData)) {
        ret.add(createSong(musicData));
      }
    });
    return ret;
  }

  setSingerDetailData(String id) async {
    Map<String, dynamic> data = await SingerApi().getSingerDetail(id);
    List list = data['data']['list'];
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
    title = widget.title;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setSingerDetailData(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    String bgImage =
        'https://y.gtimg.cn/music/photo_new/T001R300x300M000${widget.id}.jpg?max_age=2592000';
    return MusicList(
      title: title,
      bgImage: bgImage,
      songs: songs,
    );
  }
}
