import 'package:flutter/cupertino.dart';

import 'game_model.dart';

class AcroView extends StatefulWidget {
  final GameModel model;

  const AcroView(this.model, {super.key});

  @override
  State<StatefulWidget> createState() => _AcroViewState();

}

class _AcroViewState extends State<AcroView> {
  @override
  Widget build(BuildContext context) {
    return const Text("Whee");
  }
  
}