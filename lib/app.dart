import 'package:adguardhome_client/pages/home.dart';
import 'package:adguardhome_client/pages/settings.dart';
import 'package:flutter/material.dart';

class AdGuardHomeClientApp extends StatelessWidget {
  const AdGuardHomeClientApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "AdGuard Home",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => const HomePage(),
        "/settings": (context) => const SettingsPage(),
      },
      initialRoute: "/",
    );
  }
}
