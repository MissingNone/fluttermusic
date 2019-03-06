import 'package:audioplayers/audioplayers.dart';
import 'package:fluttermusic/store/state.dart';

class GlobalAudio {
  static GlobalAudio globalAudio;
  AudioPlayer audioPlayer;
  int currentTime = 0;
  bool _isPlaying = false;
  double rotate = 0.0;
  bool needSyncRotate = false;
  bool currentSongChange = false;
  bool init = false;
  static GlobalAudio instance() {
    if (globalAudio == null) {
      globalAudio = new GlobalAudio();
    }
    return globalAudio;
  }

  _init() {
    if (audioPlayer == null) {
      audioPlayer = new AudioPlayer();
      audioPlayer.setReleaseMode(ReleaseMode.STOP);
      audioPlayer.onAudioPositionChanged.listen((Duration p) {
        currentTime = p.inSeconds;
        // setState(() {});
      });
    }
  }

  bool get isPlaying => _isPlaying;
  set isPlaying(newVal) {
    _init();
    _isPlaying = newVal;
    if (newVal) {
      audioPlayer.setUrl(AppState.instance().getCurrentSong().url);
      audioPlayer.resume();
    } else {
      audioPlayer.pause();
    }
  }
}
