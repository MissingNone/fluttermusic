import 'dart:convert';
import 'dart:io';

import 'package:fluttermusic/util/httpsend.dart';

class SingerApi {
  getSingerList() async {
    const url =
        "https://c.y.qq.com/v8/fcg-bin/v8.fcg?g_tk=1928093487&inCharset=utf-8&outCharset=utf-8&notice=0&format=jsonp&channel=singer&page=list&key=all_all_all&pagesize=100&pagenum=1&hostUin=0&needNewCode=0&platform=yqq&jsonpCallback=jp0";
    HttpClient httpClient = new HttpClient();
    Uri uri = Uri.parse(url);
    HttpClientRequest request = await httpClient.getUrl(uri);
    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();
    String responseBodyTrim = responseBody.trim();
    String body =
        responseBodyTrim.substring(4, responseBodyTrim.lastIndexOf(")"));
    return await json.decode(body);
  }

  getSingerDetail(String singermid) async {
    String url =
        "https://c.y.qq.com/v8/fcg-bin/fcg_v8_singer_track_cp.fcg?g_tk=1928093487&inCharset=utf-8&outCharset=utf-8&notice=0&format=jsonp&hostUin=0&needNewCode=0&platform=yqq&order=listen&begin=0&num=80&songstatus=1&singermid=${singermid}&jsonpCallback=jp3";
    String responseBody = await HttpSend(url: url, retry: 2, headers: {
      "Referer": "https://c.y.qq.com/",
      "Host": "c.y.qq.com",
    }).send();
    String responseBodyTrim = responseBody.trim();
    RegExp regExp = RegExp("\\w+\\(({[\\s\\S]+})\\S?\\)");
    if (regExp.hasMatch(responseBodyTrim)) {
      responseBody = regExp.allMatches(responseBodyTrim).elementAt(0).group(1);
    } else {
      responseBody =
          responseBodyTrim.substring(4, responseBodyTrim.lastIndexOf(")"));
    }
    String body = responseBody;

    return await json.decode(body);
  }
}
