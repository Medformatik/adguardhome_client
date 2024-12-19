import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/pages/settings.dart';

Future<bool> initAdGuardHome() async {
  print('Initializing AdGuardHome instance');
  print('Host: ${SettingsValues.getHost()}');
  print('Port: ${SettingsValues.getPort()}');
  print('Username: ${SettingsValues.getUsername()}');

  adGuardHome = AdGuardHome(
    host: SettingsValues.getHost()!,
    port: SettingsValues.getPort()!,
    username: SettingsValues.getUsername()!,
    password: (await SettingsValues.getPassword())!,
  );

  if (await adGuardHome!.successfullyConnected()) {
    return true;
  } else {
    adGuardHome = null;
    return false;
  }
}
