import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TestPageState();
  }
}

class _TestPageState extends State<TestPage> {
  ScrollController _scrollController;
  ScrollController _innerScrollController;
  ScrollPhysics _scrollPhysics = NeverScrollableScrollPhysics();
  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= 150) {
        _scrollPhysics = BouncingScrollPhysics();
        setState(() {});
      }
      print('_scrollController:${_scrollController.offset}');
    });
    _innerScrollController = new ScrollController();
    _innerScrollController.addListener(() {
      if (_innerScrollController.offset <= 0) {
        _scrollPhysics = NeverScrollableScrollPhysics();
        setState(() {});
      }
      print('_innerScrollController:${_innerScrollController.offset}');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _innerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text(
                "title",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              pinned: true,
              expandedHeight: 200.0,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.none,
                background: Container(
                  height: 200.0,
                  color: Colors.blue,
                ),
              ),
            ),
          ];
        },
        body: Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: ListView(
                  controller: _innerScrollController,
                  physics: _scrollPhysics,
                  children: List.generate(40, (i) {
                    return Container(
                      height: 20,
                      child: Text("content-${i}"),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
