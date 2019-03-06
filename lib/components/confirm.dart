import 'package:fluttermusic/store/state.dart';
import 'package:flutter/material.dart';

class Confirm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ConfirmState();
  }
}

class ConfirmState extends State<Confirm> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Color.fromRGBO(0, 0, 0, 0.3),
              ),
            ),
            Positioned(
              top: 200,
              left: MediaQuery.of(context).size.width / 2 - 270 / 2,
              child: ConfirmContent(),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ConfirmContentState();
  }
}

class ConfirmContentState extends State<ConfirmContent>
    with TickerProviderStateMixin {
  Animation<double> animation;
  AnimationController scaleController;

  @override
  void initState() {
    super.initState();
    scaleController = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    animation = new Tween(begin: 0.0, end: 1.1).animate(
      CurvedAnimation(
        parent: scaleController,
        curve: Interval(
          0.0,
          0.5,
          curve: Cubic(0.25, 0.1, 1, 1),
        ),
      ),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animation = new Tween(begin: 1.1, end: 1.0).animate(
            CurvedAnimation(
              parent: scaleController,
              curve: Interval(
                0.5,
                1.0,
                curve: Cubic(0, 0, 0.25, 1),
              ),
            ),
          )..addListener(() {
              setState(() {});
            });
        }
      })
      ..addListener(() {
        setState(() {});
      });

    scaleController.forward();
  }

  @override
  void dispose() {
    scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: animation.value,
      child: Container(
        width: 270,
        decoration: BoxDecoration(
          color: Color(0xff333333),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(15, 19, 15, 19),
              child: Container(
                height: 22,
                alignment: Alignment.center,
                child: Text(
                  "是否清空播放列表",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.5),
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Color.fromRGBO(0, 0, 0, 0.3),
                            ),
                            right: BorderSide(
                              color: Color.fromRGBO(0, 0, 0, 0.3),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Container(
                            height: 22,
                            alignment: Alignment.center,
                            child: Text(
                              "取消",
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.3),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Color.fromRGBO(0, 0, 0, 0.3),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Container(
                            height: 22,
                            alignment: Alignment.center,
                            child: Text(
                              "清空",
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.3),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        ConfirmNotification().dispatch(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmNotification extends Notification {}
