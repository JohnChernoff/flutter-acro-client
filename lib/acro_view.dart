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
    if (widget.game.phase is AcroPhase) {
      return switch (widget.game.phase as AcroPhase) {
        AcroPhase.composing => getCompView(),
        AcroPhase.voting => getVoteView(),
        AcroPhase.scoring => getScoreView(),
        AcroPhase.topicSelect => getTopicSelectView(),
        AcroPhase.paused => defView(),
        AcroPhase.waiting => defView(),
        AcroPhase.summarizing => defView(),
        AcroPhase.skipping => defView(),
        AcroPhase.finished => defView(),
      };
    } else {
      return defView();
    }
  }

  Widget defView() {
    return Text("${widget.game.phase}...");
  }

  Widget getCompView() {
    return Column(
      children: [
        const SizedBox(height: 16),
        getAcroTxtField(),
      ],
    );
  }

  Widget getTopicSelectView() {
    return DataTable(
        columns: getTopicColumns(),
        rows: List.generate(widget.game.currentTopics.length, (i) =>
        getTopicRow(widget.game.currentTopics.elementAt(i))));
  }

  Widget getVoteView() {
    widget.game.currentAcros.sort((a,b) => a.id?.compareTo(b.id ?? '0') ?? 0);
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.game.currentAcros.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
              title: Text(
                widget.game.currentAcros[index].txt,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: getAcroVoteBox(widget.game.currentAcros.elementAt(index))
          ),
        );
      },
    );
  }

  Checkbox getAcroVoteBox(Acro acro) {
    return Checkbox(value: acro == currentVote, onChanged: (b) {
      if (b == true) {
        widget.model.areaCmd(AcroMsg.newVote,data: {AcroField.vote : acro.id});
        setState(() {
          currentVote = acro;
        });
      }
    });
  }

  Widget getScoreView() {
    widget.game.currentAcros.sort((a,b) => a.votes.length.compareTo(b.votes.length));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.game.currentAcros.length,
      itemBuilder: (context, index) {
        final acro = widget.game.currentAcros[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acro.txt,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Author: ${acro.authorName}'),
                    Text('Votes: ${acro.votes.length}'),
                    Text('Time: ${acro.time}'),
                    acro.speedy ? const Icon(Icons.speed) : const SizedBox.shrink()
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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

  List<DataColumn> getTopicColumns() {
    return [
      DataColumn(label: Text("${widget.game.topicSelector} may select a Topic")),
    ];
  }

  DataRow getTopicRow(String topic) {
    return DataRow(cells: [ //onSelectChanged: (b) => print("Selected: $b"),
      DataCell(InkWell(child: Text(topic),
        onTap: () => widget.model.areaCmd(AcroMsg.newTopic, data: {AcroField.topic : topic}),
      ))
    ]);
  }
  
}