import 'package:flutter/material.dart';

class LazyImageListView extends StatefulWidget {
  List<Widget> children;
  ScrollController scrollController;
  LazyImageListView({
    Key key,
    this.children = const <Widget>[],
    @required this.scrollController,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LazyImageListViewState();
  }
}

class LazyImageListViewState extends State<LazyImageListView> {
  ScrollController _scrollController;
  double y;
  double height;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      RenderObject renderObject = context.findRenderObject();
      y = renderObject.getTransformTo(null).getTranslation().y;
      height = renderObject.paintBounds.size.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ImageNotification>(
      onNotification: (notification) {
        notification.imagePositon.height = height;
        notification.imagePositon.listy = y;
      },
      child: ListView(
        controller: widget.scrollController,
        physics: ScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: widget.children,
      ),
    );
  }
}

class ImagePositon extends StatefulWidget {
  ImagePositon({
    Key key,
    @required this.scrollController,
    @required this.child,
    this.width = 60,
    this.height = 60,
    this.index,
    this.defaultView,
  }) : super(key: key);
  Widget child;
  double width;
  double height;
  int index;
  Widget defaultView;
  ScrollController scrollController;
  @override
  State<StatefulWidget> createState() {
    return ImagePositonState();
  }
}

class ImagePositonState extends State<ImagePositon> {
  bool _isMounted = false;
  bool _hasListener = false;
  double y;
  double height;
  double listy;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((callback) {
      RenderObject renderObject = context.findRenderObject();
      y = renderObject.getTransformTo(null).getTranslation().y;
      if (!_isMounted) {
        ImageNotification(this).dispatch(context);
        if (widget.scrollController.offset + listy + height > y) {
          _isMounted = true;
          setState(() {});
          widget.scrollController.removeListener(isInView);
        }
      }
    });
  }

  isInView() {
    if (!_isMounted) {
      if (widget.scrollController.offset + listy + height > y) {
        _isMounted = true;
        setState(() {});
        widget.scrollController.removeListener(isInView);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasListener) {
      widget.scrollController.addListener(isInView);
      _hasListener = true;
    }
    Widget defaultView;
    if (widget.defaultView == null) {
      defaultView = Container(
        width: widget.width,
        height: widget.height,
        color: Colors.blue,
      );
    } else {
      defaultView = widget.defaultView;
    }

    return _isMounted ? widget.child : defaultView;
  }
}

class ImageNotification extends Notification {
  ImagePositonState imagePositon;
  ImageNotification(this.imagePositon);
}
