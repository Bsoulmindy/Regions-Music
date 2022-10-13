import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:regions_music/domain/point.dart';
import 'form.dart';
import 'music.dart';

class Zone {
  int id = 0;
  String name = "";
  String image = "";
  List<Form> space = [];
  Music music = Music(0, "", [], AudioPlayer());
  Zone? parentZone;
  StreamSubscription<PlayerState>? streamAudio;

  Zone(this.id, this.name, this.image, this.space, this.music, this.parentZone);

  Zone.empty();

  Zone.fromForm(
      this.id, this.name, this.image, Form space, this.music, this.parentZone) {
    this.space.add(space);
  }

  @override
  bool operator ==(other) {
    if (other is Zone) {
      return id == other.id;
    }
    return false;
  }

  bool contains(Point pt) {
    for (Form form in space) {
      if (form.contains(pt)) return true;
    }

    return false;
  }

  Future<void> playMusic() async {
    await _play();

    streamAudio = music.player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _incrementLevels();
        _play();
      }
    });
  }

  void stopMusic() async {
    _stop();
    streamAudio?.cancel();
  }

  Future<void> _play() async {
    await music.play();
  }

  void _incrementLevels() {
    music.incrementLevel();
    var parent = parentZone;
    while (parent != null) {
      parent.music.incrementLevel();
      parent = parent.parentZone;
    }
  }

  void _stop() async {
    await music.stop();

    var parent = parentZone;
    while (parent != null) {
      parent.music.saveLevels();
      parent = parent.parentZone;
    }
  }

  @override
  String toString() {
    return name;
  }

  @override
  int get hashCode => id;
}
