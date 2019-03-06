import 'dart:convert';
import 'dart:io';

const Map<String, String> HTTP_METHOD = {
  "POST": "POST",
  "GET": "GET",
};
const String HTTP_METHOD_GET = "GET";

class HttpSend {
  String method;
  String url;
  Map<String, dynamic> paramters;
  Map<String, String> headers;
  int retry;
  HttpSend({
    this.method = HTTP_METHOD_GET,
    this.url = '',
    this.paramters = const {},
    this.headers = const {},
    this.retry = 0,
  });

  send({bool needRetry = true}) async {
    if (this.method == null || HTTP_METHOD[this.method.toUpperCase()] == null) {
      throw Exception("not support ${this.method} method");
    }

    if (this.url == null || this.url == '') {
      throw Exception("the 'url' option must be set");
    }
    HttpClient httpClient = new HttpClient();

    Uri uri = Uri.parse(this.url);
    HttpClientRequest request = await httpClient.getUrl(uri);
    this.headers.forEach((key, value) {
      request.headers.add(key, value);
    });
    HttpClientResponse response = await request.close();
    if (response.statusCode == 200) {
      String responseBody = await response.transform(utf8.decoder).join();
      return Future.value(responseBody);
    }
    if (needRetry) {
      while (this.retry > 0) {
        this.retry--;
        String result = await this.send(needRetry: false);
        if (result == "error") {
          continue;
        } else {
          return Future.value(result);
        }
      }
    }

    return Future.error("error");
  }
}
