import 'package:acro_client/acro_field.dart';
import 'package:acro_client/game.dart';
import 'package:flutter/material.dart';
import 'package:zug_utils/zug_utils.dart';
import 'game_model.dart';

class AcroView extends StatefulWidget {
  final AcroModel model;
  final AcroGame game;

  const AcroView(this.model, this.game, {super.key});

  @override
  State<StatefulWidget> createState() => _AcroViewState();

}

class _AcroViewState extends State<AcroView> {
  Acro? currentVote;

  @override
  void initState() {
    super.initState();
    widget.model.acroWriter = TextEditingController();
  }

  @override
  void dispose() {
    widget.model.acroWriter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text("Topic: ${widget.game.currentTopic ?? 'general'}"),
      getAcroWidget(widget.game.currentAcro ?? ""),
      getPhaseWidget()
    ]);
  }

  Widget getAcroWidget(String acro) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(acro.length, (i) =>
            Expanded(
              child: Image(
                  fit: BoxFit.contain,
                  image: ZugUtils.getAssetImage("images/letters/png/bev/${acro.substring(i,i+1).toLowerCase()}.png")
              ),
            )
        )
    );
  }

  Widget getPhaseWidget() {
    if (widget.game.phase == AcroPhase.composing.name) {
      return Column(
        children: [
          const SizedBox(height: 16),
          getAcroTxtField(),
        ],
      );
    } else if (widget.game.phase == AcroPhase.voting.name) {
      widget.game.currentAcros.sort((a,b) => a.id?.compareTo(b.id ?? '0') ?? 0);
      return DataTable(columns: getAcroVoteColumns(), rows: List.generate(widget.game.currentAcros.length, (i) =>
          getAcroVoteRow(widget.game.currentAcros.elementAt(i))));
    } else if (widget.game.phase == AcroPhase.scoring.name) {
      widget.game.currentAcros.sort((a,b) => a.votes.length.compareTo(b.votes.length));
      return DataTable(columns: getAcroScoreColumns(), rows: List.generate(widget.game.currentAcros.length, (i) =>
          getAcroScoreRow(widget.game.currentAcros.elementAt(i))));
    } else if (widget.game.phase == AcroPhase.topicSelect.name) {
      return DataTable(columns: getTopicColumns(), rows: List.generate(widget.game.currentTopics.length, (i) =>
          getTopicRow(widget.game.currentTopics.elementAt(i))));
    } else {
      return Text("${widget.game.phase}...");
    }
  }

  TextField getAcroTxtField() {
    return TextField(
        controller: widget.model.acroWriter,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.game.acceptedAcro ? Colors.green : Colors.grey,
              width: widget.game.acceptedAcro ? 2.0 : 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.game.acceptedAcro ? Colors.green : Colors.blue,
              width: 2.0,
            ),
          ),
          labelText: 'Enter Your Acro',
          suffixIcon: widget.game.acceptedAcro ?
          const Icon(Icons.check_circle, color: Colors.green) : null,
        ),
        onSubmitted: (txt) {
          widget.model.areaCmd(AcroMsg.newAcro,data: {AcroField.acro : txt});
          //setState(() { controller.clear(); });
        }
    );
  }

  List<DataColumn> getAcroVoteColumns() {
    return [
      const DataColumn(label: Icon(Icons.where_to_vote)),
      const DataColumn(label: Text("Num")),
      const DataColumn(label: Text("Acro"))
    ];
  }

  List<DataColumn> getAcroScoreColumns() {
    return [
      const DataColumn(label: Text("Author")),
      const DataColumn(label: Text("Acro")),
      const DataColumn(label: Text("Votes")),
      const DataColumn(label: Text("Time")),
      const DataColumn(label: Text("Speed")),
    ];
  }

  List<DataColumn> getTopicColumns() {
    return [
      DataColumn(label: Text("${widget.game.topicSelector} may select a Topic")),
    ];
  }

  DataRow getAcroVoteRow(Acro acro) {
    return DataRow(cells: [
      DataCell(Checkbox(value: acro == currentVote, onChanged: (b) {
        if (b == true) {
          widget.model.areaCmd(AcroMsg.newVote,data: {AcroField.vote : acro.id});
          setState(() {
            currentVote = acro;
          });
        }
      })),
      DataCell(Text(acro.id ?? "?")),
      DataCell(Text(acro.txt))
    ]);
  }

  DataRow getAcroScoreRow(Acro acro) {
    return DataRow(cells: [
      DataCell(Text(acro.authorName?.name ?? "?")),
      DataCell(Text(acro.txt)),
      DataCell(Text("${acro.votes.length}")),
      DataCell(Text("${acro.time}")),
      DataCell(acro.speedy ? const Icon(Icons.speed) : const Text("")),
    ]);
  }

  DataRow getTopicRow(String topic) {
    return DataRow(cells: [
      DataCell(InkWell(child: Text(topic),
        onTap: () => widget.model.areaCmd(AcroMsg.newTopic, data: {AcroField.topic : topic}),
      ))
    ]);
  }
  
}