import 'package:adguardhome_client/interface/adguardhome.dart';
import 'package:adguardhome_client/main.dart';
import 'package:adguardhome_client/pages/settings.dart';

Future<void> initAdGuardHome() async {
  print("Initializing AdGuardHome instance");
  print("Host: ${SettingsValues.getHost()}");
  print("Port: ${SettingsValues.getPort()}");
  print("Username: ${SettingsValues.getUsername()}");
  adGuardHome = AdGuardHome(
    host: SettingsValues.getHost()!,
    port: SettingsValues.getPort()!,
    username: SettingsValues.getUsername()!,
    password: (await SettingsValues.getPassword())!,
  );
}
