import 'package:adguard_home_client/app.dart';
import 'package:adguard_home_client/interface/adguardhome.dart';
import 'package:adguard_home_client/pages/settings.dart';
import 'package:adguard_home_client/utils/init.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

AdGuardHome? adGuardHome;

bool get instanceConfigured => adGuardHome != null;

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');

  if (await SettingsValues.instanceConfigured) {
    await initAdGuardHome();
  }

  runApp(const AdGuardHomeClientApp());
}
