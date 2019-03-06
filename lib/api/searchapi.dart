import 'dart:convert';
import 'dart:io';

import 'package:fluttermusic/util/httpsend.dart';

class SearchApi {
  getHotKey() async {
    const url =
        "https://c.y.qq.com/splcloud/fcgi-bin/gethotkey.fcg?g_tk=1928093487&inCharset=utf-8&outCharset=utf-8&notice=0&format=jsonp&uin=0&needNewCode=1&platform=h5&jsonpCallback=jp0";
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

  search(String query, int page) async {
    String url =
        "https://c.y.qq.com/soso/fcgi-bin/search_for_qq_cp?g_tk=1928093487&inCharset=utf-8&outCharset=utf-8&notice=0&format=json&w=${Uri.encodeFull(query)}&p=${page}&perpage=20&n=20&catZhida=1&zhidaqu=1&t=0&flag=1&ie=utf-8&sem=1&aggr=0&remoteplace=txt.mqq.all&uin=0&needNewCode=1&platform=h5";
    String responseBody = await HttpSend(url: url, retry: 2, headers: {
      "Referer": "https://c.y.qq.com/",
      "Host": "c.y.qq.com",
    }).send();
    String responseBodyTrim = responseBody.trim();
    String body = responseBodyTrim;
    return await json.decode(body);
  }
}
