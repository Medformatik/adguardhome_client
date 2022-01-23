import 'package:adguardhome_client/app.dart';
import 'package:adguardhome_client/interface/adguardhome.dart';
import 'package:adguardhome_client/pages/settings.dart';
import 'package:adguardhome_client/utils/init.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

AdGuardHome? adGuardHome;
bool instanceConfigured = false;

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("settings");
  if (await SettingsValues.instanceConfigured) {
    await initAdGuardHome();
    instanceConfigured = true;
  }
  runApp(const AdGuardHomeClientApp());
}
