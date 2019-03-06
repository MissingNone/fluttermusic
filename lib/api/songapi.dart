import 'dart:convert';
import 'dart:io';

import 'dart:math';
import 'dart:typed_data';

import 'package:fluttermusic/common/song.dart';
import 'package:fluttermusic/util/httpsend.dart';

class SongApi {
  getLyric(String mid) async {
    String url =
        "https://c.y.qq.com/lyric/fcgi-bin/fcg_query_lyric_new.fcg?g_tk=1928093487&inCharset=utf-8&outCharset=utf-8&notice=0&format=json&songmid=${mid}&platform=yqq&hostUin=0&needNewCode=0&categoryId=10000000&pcachetime=${DateTime.now().millisecondsSinceEpoch}";
    // HttpClient httpClient = new HttpClient();
    // Uri uri = Uri.parse(url);
    // HttpClientRequest request = await httpClient.getUrl(uri);
    // request.headers
    //   ..add("Referer", "https://c.y.qq.com/")
    //   ..add("Host", "c.y.qq.com");
    // HttpClientResponse response = await request.close();
    // String responseBody = await response.transform(utf8.decoder).join();
    String responseBody = await HttpSend(url: url, retry: 2, headers: {
      "Referer": "https://c.y.qq.com/",
      "Host": "c.y.qq.com",
    }).send();
    Map<String, dynamic> lyricJson = await json.decode(responseBody);
    String lyric = lyricJson['lyric'];
    Uint8List unit8list = base64Decode(lyric);
    List<int> lrcByte = String.fromCharCodes(unit8list).codeUnits;
    String lrc = utf8.decode(lrcByte);
    return lrc;
  }

  getPurlUrl(List songs) async {
    String url = "https://u.y.qq.com/cgi-bin/musicu.fcg";
    HttpClient httpClient = new HttpClient();
    Uri uri = Uri.parse(url);
    HttpClientRequest request = await httpClient.postUrl(uri);
    List<String> mids = [];
    List<int> types = [];
    songs.forEach((s) {
      if (s is Song) {
        mids.add(s.mid);
        types.add(0);
      }
    });
    String jsonStr = json.encode({
      "comm": {
        "g_tk": 5381,
        "inCharset": "utf-8",
        "outCharset": "utf-8",
        "notice": 0,
        "format": "json",
        "platform": "h5",
        "needNewCode": 1,
        "uin": 0
      },
      "url_mid": genUrlMid(mids, types),
    });
    List<int> bytes = utf8.encode(jsonStr);

    request.headers
      ..add("referer", "https://y.qq.com/")
      ..add("origin", "https://y.qq.com")
      ..add("Content-type", "application/x-www-form-urlencoded")
      ..add("Content-Length", bytes.length);
    request.write(jsonStr);
    await request.flush();
    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();
    return await json.decode(responseBody);
  }

  genUrlMid(List<String> mids, List<int> types) {
    return {
      'module': 'vkey.GetVkeyServer',
      'method': 'CgiGetVkey',
      'param': {
        'guid': getUid(),
        'songmid': mids,
        'songtype': types,
        'uin': '0',
        'loginflag': 0,
        'platform': '23'
      }
    };
  }

  String getUid() {
    String _uid = '';
    int t = DateTime.now().millisecondsSinceEpoch;
    _uid = '' +
        ((2147483647 * (Random().nextInt(1))).round() * t % 1e10).toString();
    return _uid;
  }
}
