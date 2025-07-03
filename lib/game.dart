import 'package:zugclient/zug_area.dart';
import 'package:zugclient/zug_fields.dart';
import 'acro_field.dart';

class AcroGame extends Area {
  bool acceptedAcro = false;
  String? currentAcro;
  String? currentTopic;
  List<Acro> currentAcros = [];
  int round = 0;
  List<AcroPlayer> players = [];

  AcroGame(super.data);

  @override
  bool updateArea(dynamic data) {
    round = data[AcroField.round];
    currentAcro = data[AcroField.acro];
    return super.updateArea(data);
  }

  void newAcros(List<dynamic> data) {
    currentAcros.clear();
    for (dynamic a in data) {
      bool voting = a[AcroField.author] == null;
      if (voting) {
        currentAcros.add(Acro(a[AcroField.round],a[AcroField.acroTxt],a[AcroField.time],id: a[AcroField.acroId]));
      } else {
        List<UniqueName> votes = [];
        for (dynamic v in a[AcroField.votes]) {
          votes.add(UniqueName.fromData(v[fieldUser]));
        }
        currentAcros.add(Acro(a[AcroField.round],a[AcroField.acroTxt],a[AcroField.time],id: a[AcroField.acroId],
            authorName: UniqueName.fromData(a[AcroField.author][fieldUser]),
            voteList: votes,
            speedy: a[AcroField.speedy]
        ));
      }
    }
  }

  String phaseString() {
    if (phase == AcroPhase.composing.name) {
      return "Write your acro";
    } else if (phase == AcroPhase.voting.name) {
      return "Vote on the acros below";
    } else {
      return "${capitalize(phase)}...";
    }
  }

  String capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : s;
}

enum AcroPhase { paused,waiting,composing,voting,scoring,nextRound,summarizing,finished }

class AcroPlayer {
  final UniqueName name;
  Acro? currentAcro;
  List<Acro> history = [];

  AcroPlayer(this.name);
}

class Acro {
  UniqueName? authorName;
  int round;
  String txt;
  String? topic;
  List<UniqueName> votes = [];
  double time;
  String? id;
  bool speedy;
  bool winner;

  Acro(this.round,this.txt, this.time, {List<UniqueName>? voteList, this.speedy = false, this.winner = false, this.id, this.topic, this.authorName}) {
    if (voteList != null) votes = voteList;
  }

}