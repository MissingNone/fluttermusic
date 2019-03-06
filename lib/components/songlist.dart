import 'package:fluttermusic/common/song.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SongList extends StatelessWidget {
  List<Song> songs;
  bool rank;
  List<Widget> songList = <Widget>[];
  SongList({
    Key key,
    this.songs = const <Song>[],
    this.rank = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    songList = List.generate(songs.length, (i) {
      return SongListItem(
        songname: songs[i].name,
        singer: songs[i].singer,
        album: songs[i].album,
        index: i,
        rank: rank,
      );
    });
    return Container(
      width: double.infinity,
      color: Color(0xff222222),
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
              child: ListView(
                physics: ScrollPhysics(parent: BouncingScrollPhysics()),
                children: songList,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SongListItem extends StatelessWidget {
  Map map = {
    "0": "images/first@2x.png",
    "1": "images/second@2x.png",
    "2": "images/third@2x.png",
  };
  SongListItem({
    Key key,
    this.songname,
    this.singer,
    this.album,
    this.index,
    this.rank = false,
  }) : super(key: key);
  String songname;
  String singer;
  String album;
  int index;
  bool rank;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 64,
        color: Color(0xff222222),
        child: Row(
          children: <Widget>[
            rank
                ? Container(
                    alignment: Alignment.center,
                    width: 25,
                    margin: EdgeInsets.only(right: 30),
                    child: index <= 2
                        ? Image.asset(
                            map[index.toString()],
                            width: 25,
                            height: 24,
                          )
                        : Text(
                            index.toString(),
                            style: TextStyle(
                              color: Color(0xffffcd32),
                            ),
                          ),
                  )
                : Container(),
            SongListExpandedItem(
              songname: songname,
              singer: singer,
              album: album,
            ),
          ],
        ),
      ),
      onTap: () {
        print(index);
        SelectPlayNotification(index).dispatch(context);
      },
    );
  }
}

class SongListExpandedItem extends StatefulWidget {
  String singer;
  String album;
  String songname;
  SongListExpandedItem({
    Key key,
    this.songname,
    this.singer,
    this.album,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SongListExpandedItemState();
  }
}

class SongListExpandedItemState extends State<SongListExpandedItem> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 20,
            alignment: Alignment.centerLeft,
            child: Text(
              widget.songname,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            height: 20,
            margin: EdgeInsets.only(top: 4),
            alignment: Alignment.centerLeft,
            child: Text(
              "${widget.singer}·${widget.album}",
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              maxLines: 1,
              style: TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.3),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectPlayNotification extends Notification {
  int index;
  SelectPlayNotification(this.index);
}
