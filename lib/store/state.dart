import 'package:audioplayers/audioplayers.dart';
import 'package:fluttermusic/common/globalaudio.dart';
import 'package:fluttermusic/common/playmode.dart';
import 'package:fluttermusic/common/song.dart';
import 'package:flutter/material.dart';
import 'package:fluttermusic/util/utils.dart' show shuffle;

class AppState {
  static AppState appState;
  bool isShow;
  List<Song> playlist = [];
  List<Song> sequenceList = [];
  Map singer;
  int _currentIndex = -1;
  Map player = {};
  int mode = PlayMode.sequence;
  int get currentIndex => _currentIndex;
  set currentIndex(int newValue) {
    if (_currentIndex == newValue) {
      return;
    }

    if (newValue < 0 ||
        playlist[newValue].id == null ||
        playlist[newValue].url == null ||
        playlist[newValue].id ==
            (getCurrentSong() != null
                ? getCurrentSong().id
                : getCurrentSong())) {
      _currentIndex = newValue;
      return;
    }
    _currentIndex = newValue;
    GlobalAudio.instance().currentSongChange = true;
    GlobalAudio.instance().rotate = 0;
    // GlobalAudio.instance().currentTime = 0;
    // if (newValue == -1) {
    //   GlobalAudio.instance().isPlaying = false;
    // } else {
    //   GlobalAudio.instance().isPlaying = true;
    // }
  }

  AppState({
    this.isShow = false,
    this.singer = const {},
    this.player,
  });

  static AppState instance() {
    if (appState == null) {
      appState = new AppState();
    }
    return appState;
  }

  Song getCurrentSong() {
    return currentIndex >= 0 ? playlist[currentIndex] : null;
  }

  int findIndex(List<Song> list, Song song) {
    return list.indexWhere((item) {
      return item.id == song.id;
    });
  }

  selectPlay(List<Song> list, int index) {
    sequenceList = list;
    if (mode == PlayMode.random) {
      List<Song> randomList = shuffle(list);
      playlist = list;
      index = findIndex(randomList, list[index]);
    } else {
      playlist = list;
    }
    this.currentIndex = index;
    this.isShow = true;
    GlobalAudio.instance().isPlaying = true;
  }

  randomPlay(List<Song> list) {
    this.mode = PlayMode.random;
    this.sequenceList = list;
    List<Song> randomList = shuffle(list);
    this.playlist = randomList;
    this.currentIndex = 0;
    this.isShow = true;
    GlobalAudio.instance().isPlaying = true;
  }

  deleteSong(Song song) {
    List<Song> playlist = this.playlist.toList();
    List<Song> sequenceList = this.sequenceList.toList();
    int currentIndex = this.currentIndex;
    int pIndex = findIndex(playlist, song);
    playlist.removeAt(pIndex);
    int sIndex = findIndex(sequenceList, song);
    sequenceList.removeAt(sIndex);
    if (currentIndex > pIndex || currentIndex == playlist.length) {
      currentIndex--;
    }
    this.playlist = playlist;
    this.sequenceList = sequenceList;
    this.currentIndex = currentIndex;
  }

  deleteSongList() {
    GlobalAudio.instance().isPlaying = false;

    this.currentIndex = -1;
    this.playlist = [];
    this.sequenceList = [];
    this.isShow = false;
  }

  insertSong(Song song) {
    int currentIndex = this.currentIndex;
    int fpIndex = this.playlist.indexWhere((item) => item.id == song.id);
    // 因为是插入歌曲，所以索引+1
    currentIndex++;
    // 插入这首歌到当前索引位置
    playlist.insert(currentIndex, song);
    // 如果已经包含了这首歌
    if (fpIndex > -1) {
      // 如果当前插入的序号大于列表中的序号
      if (currentIndex > fpIndex) {
        playlist.removeAt(fpIndex);
        currentIndex--;
      } else {
        playlist.removeAt(fpIndex + 1);
      }
    }
    this.isShow = true;

    if (this.currentIndex == currentIndex) {
      // GlobalAudio.instance().audioPlayer.resume();
    } else {
      // GlobalAudio.instance().audioPlayer.stop();
      // GlobalAudio.instance().audioPlayer.seek(Duration(seconds: 0));
      // GlobalAudio.instance().currentTime = 0;
      // GlobalAudio.instance().audioPlayer.setUrl(this.getCurrentSong().url);
      // GlobalAudio.instance().audioPlayer.setReleaseMode(ReleaseMode.STOP);
      // GlobalAudio.instance().audioPlayer.resume();
    }
    this.currentIndex = currentIndex;
    GlobalAudio.instance().isPlaying = true;
  }
}
