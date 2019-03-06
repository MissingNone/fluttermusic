import 'dart:convert';
import 'dart:io';

import 'dart:math';

class RecommendApi {
  Future<Map<String, dynamic>> getRecommend() async {
    const url =
        "https://c.y.qq.com/musichall/fcgi-bin/fcg_yqqhomepagerecommend.fcg?g_tk=1928093487&inCharset=utf-8&outCharset=utf-8&notice=0&format=jsonp&platform=h5&uin=0&needNewCode=1&jsonpCallback=jp0";
    HttpClient httpClient = new HttpClient();
    Uri uri = Uri.parse(url);
    HttpClientRequest request = await httpClient.getUrl(uri);
    //request.headers.add("Content-Type", "application/x-www-form-urlencoded");
    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();
    String body = responseBody.substring(4, responseBody.lastIndexOf(")"));
    return await json.decode(body);
  }

  getDiscList() async {
    final random = new Random().toString();
    String url =
        "https://c.y.qq.com/splcloud/fcgi-bin/fcg_get_diss_by_tag.fcg?g_tk=1928093487&inCharset=utf-8&outCharset=utf-8&notice=0&format=json&platform=yqq&hostUin=0&sin=0&ein=29&sortId=5&needNewCode=0&categoryId=10000000&rnd=" +
            random;
    HttpClient httpClient = new HttpClient();
    Uri uri = Uri.parse(url);
    HttpClientRequest request = await httpClient.getUrl(uri);
    request.headers
      ..add("Referer", "https://c.y.qq.com/")
      ..add("Host", "c.y.qq.com");
    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();
    return await json.decode(responseBody);
  }

  getSongList(disstid) async {
    String url =
        "https://c.y.qq.com/qzone/fcg-bin/fcg_ucc_getcdinfo_byids_cp.fcg?g_tk=1928093487&inCharset=utf-8&outCharset=utf-8&notice=0&format=jsonp&disstid=${disstid}&type=1&json=1&utf8=1&onlysong=0&platform=yqq&hostUin=0&needNewCode=0&jsonpCallback=jp0";
    HttpClient httpClient = new HttpClient();
    Uri uri = Uri.parse(url);
    HttpClientRequest request = await httpClient.getUrl(uri);
    request.headers
      ..add("Referer", "https://c.y.qq.com/")
      ..add("Host", "c.y.qq.com");

    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();
    String responseBodyTrim = responseBody.trim();
    String body =
        responseBodyTrim.substring(4, responseBodyTrim.lastIndexOf(")"));
    return await json.decode(body);
  }
}
