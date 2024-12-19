import 'package:adguard_home_client/pages/home.dart';
import 'package:adguard_home_client/pages/settings.dart';
import 'package:flutter/material.dart';

class AdGuardHomeClientApp extends StatelessWidget {
  const AdGuardHomeClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdGuard Home',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
      },
      initialRoute: '/',
    );
  }
}
