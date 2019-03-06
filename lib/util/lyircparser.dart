import 'dart:async';

import 'dart:ui';

const timeExp = r"\[(\d{2,}):(\d{2})(?:\.(\d{2,3}))?]";

const STATE_PAUSE = 0;
const STATE_PLAYING = 1;
const Map<String, String> tagRegMap = {
  'title': 'ti',
  'artist': 'ar',
  'album': 'al',
  'offset': 'offset',
  'by': 'by'
};

class Lyric {
  String lrc;
  Map tags = {};
  List lines = [];
  int state = STATE_PAUSE;
  int curLine = 0;
  int curNum = 0;
  int startStamp = 0;
  int pauseStamp = 0;
  Function handler;
  Timer timer;
  Lyric({
    this.lrc,
    this.handler,
  });

  init() {
    this._initTag();

    this._initLines();
  }

  _initTag() {
    tagRegMap.forEach((key, value) {
      RegExp matches = new RegExp('\\[${tagRegMap[key]}:([^\\]]*)]');
      bool isMatch = matches.hasMatch(this.lrc);
      this.tags[key] =
          isMatch ? matches.allMatches(this.lrc).elementAt(0).group(1) : '';
    });
  }

  _initLines() {
    List<String> lines = this.lrc.split('\n');
    print(lines.length);
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      bool isMatches = RegExp(timeExp).hasMatch(line);
      if (isMatches) {
        Match result = RegExp(timeExp).allMatches(line).elementAt(0);
        String txt = line.replaceAllMapped(RegExp(timeExp), (replace) {
          return '';
        }).trim();

        if (txt != null && txt != '') {
          int time = int.parse(result.group(1)) * 60 * 1000 +
              int.parse(result.group(2)) * 1000 +
              (result.group(3) != null ? int.parse(result.group(3)) : 0) * 10;
          // print(time);
          this.lines.add({
            'time': time,
            'txt': txt,
          });
        }
      }
    }

    this.lines.sort((a, b) {
      return a['time'] - b['time'];
    });
  }

  _findCurNum(time) {
    for (int i = 0; i < this.lines.length; i++) {
      if (time <= this.lines[i]['time']) {
        return i;
      }
    }
    return this.lines.length - 1;
  }

  _callHandler(i) {
    if (i < 0) {
      return;
    }
    this.handler({
      'txt': this.lines[i]['txt'],
      'lineNum': i,
    });
  }

  _playRest() {
    Map line = this.lines[this.curNum];
    int delay = line['time'] -
        (new DateTime.now().millisecondsSinceEpoch - this.startStamp);

    this.timer = new Timer(Duration(milliseconds: delay), () {
      this._callHandler(this.curNum++);
      if (this.curNum < this.lines.length && this.state == STATE_PLAYING) {
        this._playRest();
      }
    });
  }

  play(int startTime, {bool skipLast = false}) {
    if (this.lines.length <= 0) {
      return;
    }
    this.state = STATE_PLAYING;

    this.curNum = this._findCurNum(startTime);
    this.startStamp = new DateTime.now().millisecondsSinceEpoch - startTime;

    if (!skipLast) {
      this._callHandler(this.curNum - 1);
    }

    if (this.curNum < this.lines.length) {
      if (this.timer != null) {
        this.timer.cancel();
      }
      this._playRest();
    }
  }

  togglePlay() {
    int now = new DateTime.now().millisecondsSinceEpoch;
    if (this.state == STATE_PLAYING) {
      this.stop();
      this.pauseStamp = now;
    } else {
      this.state = STATE_PLAYING;
      this.play(
          (this.pauseStamp > 0 ? this.pauseStamp : now) -
              (this.startStamp > 0 ? this.startStamp : now),
          skipLast: true);
      this.pauseStamp = 0;
    }
  }

  stop() {
    this.state = STATE_PAUSE;
    if (this.timer != null) {
      this.timer.cancel();
    }
  }

  seek(int offset) {
    this.play(offset);
  }
}
