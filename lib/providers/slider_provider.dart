import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:musicplayer/providers/audio_provider.dart';

class SliderProvider with ChangeNotifier {
  late AudioProvider _audioProvider;
  int slider = 0;
  bool playing = false;
  bool repeat = false;
  bool shuffle = false;
  double volume = 0.5;

  void init(AudioProvider audioProvider) {
    _audioProvider = audioProvider;
    slider = _audioProvider.getSlider();
    repeat = _audioProvider.getRepeat();
    shuffle = _audioProvider.getShuffle();
    volume = _audioProvider.getVolume();
    _audioProvider.audioPlayer.onPositionChanged.listen((Duration event) {
      // debugPrint("Position changed: ${event.inMilliseconds}");
      slider = event.inMilliseconds;
      _audioProvider.setSlider(slider);
      notifyListeners();
    });
    _audioProvider.audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      playing = state == PlayerState.playing;
      if (state == PlayerState.completed) {
        if (repeat) {
          slider = 0;
          _audioProvider.setSlider(0);
          _audioProvider.play();
        } else {
          _audioProvider.skipToNext();
        }
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void setSlider(int value) {
    slider = value;
    _audioProvider.audioPlayer.seek(Duration(milliseconds: value));
    _audioProvider.setSlider(value);
    notifyListeners();
  }

  void setRepeat(bool newRepeat) {
    repeat = newRepeat;
    _audioProvider.setRepeat(newRepeat);
    notifyListeners();
  }

  void setShuffle(bool newShuffle) {
    shuffle = newShuffle;
    _audioProvider.setShuffle(newShuffle);
    notifyListeners();
  }

  void setVolume(double newVolume) {
    volume = newVolume;
    notifyListeners();
    _audioProvider.setVolume(newVolume);
  }
}