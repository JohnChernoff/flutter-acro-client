import 'package:zugclient/zug_area.dart';
import 'acro_field.dart';
import 'game_model.dart';

class AcroGame extends Area {
  Acro? currentAcro;
  String? currentTopic;
  int round = 0;
  List<AcroPlayer> players = [];

  AcroGame(super.data);

  void update(dynamic data,GameModel? model) {
    round = data[AcroField.round];
  }

  String phaseString() {
    if (phase == AcroPhase.acro.name) {
      return "Write your acro!";
    } else if (phase == AcroPhase.vote.name) {
      return "Vote on acros!";
    } else {
      return capitalize(phase);
    }
  }

  String capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : s;
}

enum AcroPhase { idle, acro, vote, score, summary }

class AcroPlayer {
  final UniqueName name;
  Acro? currentAcro;
  List<Acro> history = [];

  AcroPlayer(this.name);

}

class Acro {
  AcroPlayer author;
  int round;
  String txt;
  String? topic;
  List<AcroPlayer> votes = [];
  int time;
  String? id;
  bool speedy;
  bool winner;

  Acro(this.author,this.round,this.txt, this.time, {List<AcroPlayer>? voteList, this.speedy = false, this.winner = false, this.id, this.topic}) {
    if (voteList != null) votes = voteList;
  }

}