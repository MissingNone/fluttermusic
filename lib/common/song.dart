import 'package:fluttermusic/api/songapi.dart';
import 'package:fluttermusic/common/singer.dart';

class Song {
  Song({
    this.id,
    this.mid,
    this.singer,
    this.name,
    this.album,
    this.duration,
    this.image,
    this.url,
  });
  int id;
  String mid;
  String singer;
  String name;
  String album;
  int duration;
  String image;
  String url;
  String lyric;

  String getFileName() {
    return 'C400${mid}.m4a';
  }

  getLyric() async {
    if (this.lyric != null) {
      return Future.value(this.lyric);
    }
    String lrc = await SongApi().getLyric(this.mid);
    this.lyric = lrc;
    return Future.value(lrc);
  }

  @override
  String toString() {
    return '{id:${id},mid:${mid},singer:${singer},name:${name},album:${album},duration:${duration},image:${image},url:${url}}';
  }
}

createSong(musicData) {
  return Song(
    id: musicData['songid'],
    mid: musicData['songmid'],
    singer: filterSinger(musicData['singer']),
    name: musicData['songname'],
    album: musicData['albumname'],
    duration: musicData['interval'],
    image:
        "https://y.gtimg.cn/music/photo_new/T002R300x300M000${musicData['albummid']}.jpg?max_age=2592000",
    url:
        "http://isure.stream.qqmusic.qq.com/C100${musicData['songmid']}.m4a?fromtag=32",
  );
}

String filterSinger(List singer) {
  List ret = [];
  if (singer == null) {
    return '';
  }
  singer.forEach((s) {
    ret.add(s['name']);
  });
  return ret.join('/');
}

bool isValidMusic(musicData) {
  return musicData['songid'] != null &&
      musicData['albummid'] != null &&
      (musicData['pay'] != null || musicData['pay']['payalbumprice'] == 0);
}
