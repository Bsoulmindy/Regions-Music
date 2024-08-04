import 'dart:async';
import 'dart:ui';

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

  Color getAreaColor() {
    int modulo = id % 10;
    switch (modulo) {
      case 1:
        return const Color.fromARGB(64, 255, 0, 0);
      case 2:
        return const Color.fromARGB(64, 255, 123, 0);
      case 3:
        return const Color.fromARGB(64, 251, 255, 0);
      case 4:
        return const Color.fromARGB(64, 81, 255, 0);
      case 5:
        return const Color.fromARGB(64, 0, 255, 106);
      case 6:
        return const Color.fromARGB(64, 0, 255, 242);
      case 7:
        return const Color.fromARGB(64, 0, 110, 255);
      case 8:
        return const Color.fromARGB(64, 17, 0, 255);
      case 9:
        return const Color.fromARGB(64, 153, 0, 255);
      case 0:
        return const Color.fromARGB(64, 247, 0, 255);

      default:
        return const Color.fromARGB(64, 0, 0, 0);
    }
  }

  @override
  String toString() {
    return name;
  }

  @override
  int get hashCode => id;
}
