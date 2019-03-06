import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  Loading({
    Key key,
    this.title = '正在载入...',
  }) : super(key: key);
  String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "images/loading.gif",
            width: 24,
            height: 24,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Color.fromRGBO(255, 255, 255, 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
