import 'package:acro_client/acro_lobby.dart';
import 'package:flutter/material.dart';
import 'package:zugclient/lobby_page.dart';
import 'package:zugclient/zug_chat.dart';
import 'package:zugclient/zug_fields.dart';
import 'acro_view.dart';
import 'game.dart';
import 'game_model.dart';

class GameView extends StatefulWidget {

  final GameModel model;
  const GameView(this.model, {super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<GameView> with TickerProviderStateMixin {
  late AnimationController ac;

  @override
  void initState() {
    super.initState();
    widget.model.areaCmd(ClientMsg.setDeaf,data:{fieldDeafened:false});
    widget.model.areaCmd(ClientMsg.updateArea);
    ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 8000),reverseDuration: const Duration(seconds: 99999));
  }

  @override
  void dispose() {
    ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AcroGame cg = widget.model.currentGame;
    if (ac.duration?.inMilliseconds != cg.phaseTime) { //print("Setting duration: ${cg.phaseTime}");
      ac.reset();
      if (cg.phaseTime != null) {
        ac.duration = Duration(milliseconds: cg.phaseTime ?? 999999);
        ac.repeat(reverse: true); // restart with new duration
      }
    }
    print(cg.options);
    return ColoredBox(color: Colors.cyan, child: Row(children: [
      Expanded(
        child: AcroLobby(
          widget.model,
          style: LobbyStyle.tersePort,
          buttonsBkgCol: Colors.black,
          zugChat: ZugChat(
            widget.model,
            defScope: widget.model.currentArea == widget.model.noArea
                ? MessageScope.server
                : MessageScope.area,
          ),
        ),
      ),
      Expanded(child: Column(children: [
        acroContainer(null, null, Colors.cyanAccent,
            Row(children: [
              Text("${cg.phaseString()}: "),
              Expanded(
                child: ValueListenableBuilder<double>(
                  valueListenable: ac,
                  builder: (context, value, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0), // Flip horizontally
                      child: LinearProgressIndicator(
                        value: value, // Use regular value
                        color: Colors.black,
                        backgroundColor: Colors.cyanAccent,
                        minHeight: 32,
                      ),
                    );
                  },
                ),
              ),
            ])),
        Wrap(alignment: WrapAlignment.spaceEvenly, children: [
          //textBox("Allow Guests: ${cg.guests}", Colors.green),
          textBox("Current Round: ${cg.round}", Colors.orange),
          textBox("Points for Victory: ${cg.options["victoryPoints"] ?? "-"}", Colors.teal),
          //textBox("Max players: ${cg.maxPlayers}", Colors.pink),
        ]),
        Expanded(child: AcroView(widget.model)),
      ])
      ),
    ]));
  }

  Widget textBox(String txt, Color color) {
    return acroContainer(192, 72, color, Text(txt));
  }

  Widget acroContainer(double? width, double? height, Color color, Widget child) {
    return Container(decoration: BoxDecoration(
        color: color,
        boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 12, spreadRadius: 0.4)]
    ), width: width, height: height, child: Padding(padding: const EdgeInsets.all(24), child: child));
  }

}