import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zugclient/dialogs.dart';
import 'package:zugclient/lobby_page.dart';
import 'package:zugclient/options_page.dart';
import 'package:zugclient/zug_area.dart';
import 'acro_field.dart';

//TODO: fix backgroundImage path
class AcroLobby extends LobbyPage {
  const AcroLobby(super.client, {
    super.backgroundImage = const AssetImage("assets/images/rosham_bkg.png"),
    super.areaName = "Acro Area",
    super.bkgCol = Colors.black,
    super.buttonsBkgCol,
    super.style = LobbyStyle.tersePort,
    super.width,
    super.borderWidth  = 1,
    super.borderCol = Colors.white,
    super.zugChat,
    super.createButt = false,
    super.startButt = false,
    super.seekButt = false,
    super.portFlex = 1,
    super.key});

  @override
  Widget getJoinButton({Color normCol = Colors.blueAccent,  pressedCol = Colors.greenAccent}) {
    return super.getJoinButton(normCol: Colors.greenAccent, pressedCol: Colors.blueAccent);
  }

  @override
  Widget selectedArea(BuildContext context, {Color? bkgCol, Color? txtCol, Iterable<dynamic>? occupants}) {
    List<dynamic> players = model.currentArea.occupantMap.values.toList();
    players.sort((a,b) => b[AcroField.points] - a[AcroField.points]);
    return super.selectedArea(context, bkgCol: bkgCol, txtCol: txtCol, occupants: players);
  }

  @override
  List<DataColumn> getOccupantHeaders({Color color = Colors.white}) {
    return [
      DataColumn(label: Expanded(child: Text("Name",style: TextStyle(color: color)))),
      DataColumn(label: Expanded(child: Text("Points",style: TextStyle(color: color)))),
    ];
  }

  @override
  DataRow getOccupantData(UniqueName uName, Map<String,dynamic> json, {Color color = Colors.white}) { //print("json: $json , name: $uName");
    return DataRow(cells: [
      DataCell(Text(uName.name,style: TextStyle(color: color))),
      DataCell(Text("${json[AcroField.points]}", style: TextStyle(color: color))),
    ]);
  }

  @override
  List<Widget> getExtraCmdButtons(BuildContext context) {
    return [
      ElevatedButton(
          style: getButtonStyle(Colors.pinkAccent, Colors.white),
          onPressed: () async => model.areaCmd(AcroMsg.nudge),
          child: Text("Start", style: getButtonTextStyle())
      ),
      ElevatedButton(
          style: getButtonStyle(Colors.white, Colors.greenAccent),
          onPressed: () async => HelpDialog(model,await rootBundle.loadString('txt/help.txt'),bkgCol: Colors.greenAccent).raise(),
          child: Text("Help", style: getButtonTextStyle())
      ),
      ElevatedButton(
          style: getButtonStyle(Colors.blue, Colors.greenAccent),
          onPressed: () => OptionDialog(model,context,OptionScope.general).raise(),
          child: Text("Settings", style: getButtonTextStyle())
      ),
    ];
  }

}