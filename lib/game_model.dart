import 'package:acro_client/acro_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:zug_utils/zug_dialogs.dart';
import 'package:zugclient/zug_area.dart';
import 'package:zugclient/zug_fields.dart';
import 'package:zugclient/zug_model.dart';
import 'game.dart';

class AcroModel extends ZugModel {

  AcroGame get currentGame => currentArea as AcroGame;

  AcroGame getGame(data) => getOrCreateArea(data) as AcroGame;

  TextEditingController acroWriter = TextEditingController();

  AcroModel(super.domain, super.port, super.remoteEndpoint, super.prefs, {super.firebaseOptions,super.localServer,super.showServMess,super.javalinServer}) {
    showServMess = true;
    modelName = "my_client";
    addFunctions({
      AcroMsg.acroConfirmed: handleAcroConfirmation,
      ServMsg.kicked: handleKick
    });
    editOption(AudioOpt.music, true);
    checkRedirect("lichess.org");
  }

  bool handleAcroConfirmation(data) {
    getGame(data).acceptedAcro = true;
    return true;
  }

  @override
  bool handleUpdateOccupants(data, {Area? area}) {
    return super.handleUpdateOccupants(data);
  }

  @override
  bool handleNewPhase(data) {
    super.handleNewPhase(data);
    AcroGame game = getGame(data);
    game.acceptedAcro = false;
    if (acroWriter.hasListeners) acroWriter.clear();
    if (data[fieldPhase] == AcroPhase.composing.name) {
      game.currentAcro = data[fieldPhaseData][AcroField.acro];
      game.currentTopic = data[fieldPhaseData][AcroField.topic];
    } else if (data[fieldPhase] == AcroPhase.voting.name || data[fieldPhase] == AcroPhase.scoring.name) {
      game.newAcros(data[fieldPhaseData][AcroField.acros]);
    } else if (data[fieldPhase] == AcroPhase.topicSelect.name) {
      game.newTopics(data[fieldPhaseData]);
    }
    return true;
  }

  bool handleKick(data) {
    ZugDialogs.popup("You've been kicked for idleness");
    return true;
  }

  @override
  Area createArea(data) {
    return AcroGame(data);
  }

}