import 'dart:math';

import 'package:fluttermusic/common/song.dart';

List<Song> shuffle(List<Song> arr) {
  List<Song> _arr = arr.toList();
  for (int i = 0; i < _arr.length; i++) {
    int j = getRandomInt(0, i);
    Song t = _arr[i];
    _arr[i] = _arr[j];
    _arr[j] = t;
  }
  return _arr;
}

int getRandomInt(int min, int max) {
  return (Random().nextDouble() * (max - min + 1) + min).floor();
}
