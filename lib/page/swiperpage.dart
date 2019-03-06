import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

class SwiperPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SwiperPage();
  }
}

class _SwiperPage extends State<SwiperPage> {
  List<Widget> arr = <Widget>[];
  List<Widget> children = <Widget>[];
  double width;
  int currentIndex = 0;
  @override
  void initState() {
    getNewList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    Swiper _swiper = Swiper(
      children: children,
    );
    if (children.length > 0) {
      arr = List<Widget>.generate(children.length - 2, (i) {
        if (i == currentIndex) {
          return Container(
            width: 20,
            height: 8,
            margin: EdgeInsets.only(left: 4, right: 4),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4.0),
            ),
          );
        }
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(left: 4, right: 4),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("轮播图"),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          NotificationListener<MyNotification>(
            onNotification: (notification) {
              setState(() {
                currentIndex = ((notification.offset - 360) / 360).toInt();
              });
            },
            child: children.length == 0 ? Container() : _swiper,
          ),
          Positioned(
            bottom: 18.0,
            child: Row(
              children: arr,
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  getNewList() async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient
        .postUrl(Uri.parse("https://api.yuntaigo.com/md/yscapi/newlist"));
    request.headers.add("Content-Type", "application/x-www-form-urlencoded");
    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();
    Map<String, dynamic> data = json.decode(responseBody);
    List list = data['newlist'];
    Map first = list[0];
    Map last = list[list.length - 1];
    list.add(first);
    list.insert(0, last);
    List<Widget> _children = List.generate(list.length, (i) {
      print(list[i]['appimg']);
      return Container(
        width: width,
        color: Colors.red,
        child: Image.network(
          list[i]['appimg'],
          fit: BoxFit.cover,
        ),
      );
    });
    // _children.add(first);
    // _children.insert(0, last);
    children = _children;
    setState(() {});
    httpClient.close();
  }
}

class MyNotification extends Notification {
  MyNotification(this.offset);
  final double offset;
}

class Swiper extends StatefulWidget {
  Swiper(
      {Key key,
      this.auto = true,
      this.duration = const Duration(milliseconds: 3000),
      this.animateDuration = const Duration(milliseconds: 500),
      this.children = const <Widget>[]})
      : super(key: key);
  bool auto;
  Duration duration;
  Duration animateDuration;
  List<Widget> children;
  @override
  State<StatefulWidget> createState() {
    return _Swiper();
  }
}

class _Swiper extends State<Swiper> {
  ScrollController _scrollController =
      new ScrollController(initialScrollOffset: 360);
  int index = 0;
  double offset = 360;
  double width;
  Timer timer;
  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.offset >= width * (widget.children.length - 1)) {
        offset = 360;
        _scrollController.jumpTo(offset);
      }
      if (_scrollController.offset <= 0) {
        offset = width * (widget.children.length - 2);
        _scrollController.jumpTo(offset);
      }
      if (!widget.auto) {
        offset = _scrollController.offset;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    if (this.timer == null && this.widget.auto) {
      _scrollTimer(width);
    }
    return Container(
      height: width * 0.40,
      child: NotificationListener(
        onNotification: (notification) {
          if (notification.runtimeType == ScrollEndNotification) {
            MyNotification(_scrollController.offset).dispatch(context);
          }
        },
        child: Listener(
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: PageScrollPhysics(parent: BouncingScrollPhysics()),
            controller: _scrollController,
            children: widget.children,
          ),
          onPointerDown: (details) {
            if (this.timer != null) {
              this.timer.cancel();
            }
          },
          onPointerUp: (details) {
            _scrollTimer(width);
          },
        ),
      ),
    );
  }

  _scrollTimer(double width) {
    if (widget.auto) {
      if (widget.duration.compareTo(widget.animateDuration) < 0) {
        throw Exception("定时器的时间必须大于动画时间");
      }
      this.timer = Timer.periodic(widget.duration, (timer) {
        offset = _scrollController.offset + width;
        _scrollController.animateTo(offset,
            duration: widget.animateDuration, curve: Curves.ease);
      });
    }
  }

  @override
  void dispose() {
    if (this.timer != null) {
      this.timer.cancel();
      this.timer = null;
    }
    _scrollController.dispose();
    super.dispose();
  }
}
