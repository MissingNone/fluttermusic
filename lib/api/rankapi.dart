import 'dart:convert';
import 'dart:io';

import 'package:fluttermusic/util/httpsend.dart';

class RankApi {
  getTopList() async {
    String url =
        "https://c.y.qq.com/v8/fcg-bin/fcg_myqq_toplist.fcg?g_tk=1928093487&inCharset=utf-8&outCharset=utf-8&notice=0&format=jsonp&uin=0&needNewCode=1&platform=h5&jsonpCallback=jp0";

    String responseBody = await HttpSend(url: url, retry: 2).send();
    String responseBodyTrim = responseBody.trim();

    RegExp regExp = RegExp("\\w+\\(({[\\s\\S]+})\\)");
    if (regExp.hasMatch(responseBodyTrim)) {
      responseBody = regExp.allMatches(responseBodyTrim).elementAt(0).group(1);
    } else {
      responseBody = responseBodyTrim;
    }
    String body = responseBody;
    return await json.decode(body);
  }

  getMusicList(String id) async {
    String url =
        "https://c.y.qq.com/v8/fcg-bin/fcg_v8_toplist_cp.fcg?g_tk=1928093487&inCharset=utf-8&outCharset=utf-8&notice=0&format=jsonp&topid=${id}&needNewCode=1&uin=0&tpl=3&page=detail&type=top&platform=h5&jsonpCallback=jp1";
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
