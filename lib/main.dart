import 'dart:developer';
import 'package:acro_client/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:zug_utils/zug_utils.dart';
import 'package:zugclient/zug_app.dart';
import 'package:zugclient/zug_model.dart';
import 'game_model.dart';
import 'game_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  String appName = "AcroCafe";
  ZugUtils.getIniDefaults("defaults.ini").then((defaults) {
    ZugUtils.getPrefs().then((prefs) {
      String domain = defaults["domain"] ?? "localhost";
      int port = int.parse(defaults["port"] ?? "3333");
      String endPoint = defaults["endpoint"] ?? "acrosrv";
      bool localServer = bool.parse(defaults["localServer"] ?? "true");
      log("Starting $appName Client, domain: $domain, port: $port, endpoint: $endPoint, localServer: $localServer");
      AcroModel model = AcroModel(domain,port,endPoint,prefs,
          firebaseOptions: DefaultFirebaseOptions.web, localServer : localServer,showServMess : false, javalinServer: true);
      runApp(GameApp(model,appName));
    });
  });
}

class GameApp extends ZugApp {
  GameApp(super.model, super.appName,
      {super.key, super.logLevel = Level.INFO, super.noNav = true, super.splashLandscapeImgPath = "images/splash_land.gif"});

  @override
  AppBar createAppBar(BuildContext context, ZugModel model,
      {Widget? txt, Color? color}) {
    return AppBar(
      backgroundColor: Colors.black,
      title: Text(
          "Welcome to $appName, ${model.userName?.name ?? "Unknown User"}! ",
          style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget createMainPage(model) {
    return GameView(model as AcroModel);
  }
}
