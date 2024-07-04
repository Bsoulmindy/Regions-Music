import 'dart:async';

import 'inactive_time.dart';
import 'package:just_audio/just_audio.dart';

class Music {
  int id;
  String path;
  List<int>
      levels; // Each level has a milliseconds indicating where to play the music
  int currentLevel = 0;
  List<InactiveTime> inactiveTimes = [];

  StreamSubscription<PlayerState>? streamAudio;
  AudioPlayer player;

  Music(this.id, this.path, this.levels, this.player);

  void incrementLevel() {
    if (currentLevel < levels.length - 1) {
      currentLevel++;
    }
  }

  Future<void> play() async {
    await _play();
  }

  Future<void> playLoop() async {
    await _play();
    streamAudio = player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        incrementLevel();
        _play();
      }
    });
  }

  Future<void> stop() async {
    _stop();
    streamAudio?.cancel();
  }

  void saveLevels() {
    for (int level = 0; level < currentLevel; level++) {
      int time = DateTime.now().millisecondsSinceEpoch;
      for (int j = level + 1; j <= currentLevel; j++) {
        time += levels[j];
      }
      inactiveTimes.add(InactiveTime(level, time));
    }
  }

  Future<void> _play() async {
    // Checking for inactiveTime
    if (currentLevel > 0) {
      for (InactiveTime time in inactiveTimes) {
        if (DateTime.now().millisecondsSinceEpoch > time.timeExpiration) {
          currentLevel = time.levelAfterExpiration;
          break;
        }
      }
    }

    inactiveTimes.clear();

    await player.setFilePath(path);

    Duration start = Duration(milliseconds: levels[currentLevel]);

    if (currentLevel + 1 >= levels.length) {
      await player.setClip(start: start, end: null);
    } else {
      await player.setClip(
          start: start, end: Duration(milliseconds: levels[currentLevel + 1]));
    }

    player.play();
  }

  Future<void> _stop() async {
    await player.stop();

    saveLevels();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Music && other.id == id;
  }

  @override
  int get hashCode => id.hashCode ^ path.hashCode;
}
