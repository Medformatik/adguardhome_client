import 'package:adguardhome_client/main.dart';
import 'package:adguardhome_client/utils/init.dart';
import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<String?> password;

  @override
  void initState() {
    super.initState();
    password = SettingsValues.getPassword();
  }

  Future<bool> onWillPop() async {
    if (await SettingsValues.instanceConfigured) {
      // AdGuardHome is configured
      await initAdGuardHome(); // Re-initialize AdGuardHome
      instanceConfigured = true; // Set instanceConfigured to true
      if (await adGuardHome!.successfullyConnected()) {
        Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
      } else {
        // AdGuardHome interface could not be connected, something isn't configured correctly
        Fluttertoast.showToast(
          msg: "Could not connect to AdGuard Home, please check your settings.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      // AdGuardHome instance is not configured, show error
      Fluttertoast.showToast(
        msg: "You first have to configure your AdGuard Home instance.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    return false;
  }

  Future savePressed() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      if (!instanceConfigured) await onWillPop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await onWillPop(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: FutureBuilder(
          future: password,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            return Form(
              key: _formKey,
              child: CardSettings(
                children: <CardSettingsSection>[
                  CardSettingsSection(
                    header: CardSettingsHeader(
                      label: 'AdGuard Home Instance',
                    ),
                    children: <CardSettingsWidget>[
                      CardSettingsText(
                        fieldPadding: const EdgeInsets.only(left: 14.0, top: 16.0, right: 14.0, bottom: 8.0),
                        label: 'Host',
                        initialValue: SettingsValues.getHost(),
                        maxLength: 15,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Host is required.';
                          RegExp ipRegExp = RegExp(r"^(?!0)(?!.*\.$)((1?\d?\d|25[0-5]|2[0-4]\d)(\.|$)){4}$", caseSensitive: false, multiLine: false);
                          if (!ipRegExp.hasMatch(value)) return 'Host must be a valid IP address.';
                        },
                        onSaved: (value) => SettingsValues.setHost(value as String),
                      ),
                      CardSettingsInt(
                        label: 'Port',
                        initialValue: SettingsValues.getPort() ?? 3000,
                        validator: (value) {
                          if (value == null) return 'Port is required.';
                          if (value < 1 || value > 65535) return 'Port must be between 1 and 65535.';
                        },
                        onSaved: (value) => SettingsValues.setPort(value as int),
                      ),
                      CardSettingsText(
                        label: 'Username',
                        initialValue: SettingsValues.getUsername(),
                        maxLength: 32,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Username is required.';
                        },
                        onSaved: (value) => SettingsValues.setUsername(value as String),
                      ),
                      CardSettingsPassword(
                        fieldPadding: const EdgeInsets.only(left: 14.0, top: 8.0, right: 14.0, bottom: 16.0),
                        label: 'Password',
                        initialValue: snapshot.data,
                        maxLength: 512,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password is required.';
                        },
                        onSaved: (value) {
                          SettingsValues.setPassword(value as String);
                          setState(() {
                            password = SettingsValues.getPassword();
                          });
                        },
                      ),
                      CardSettingsButton(
                        label: 'Save',
                        textColor: Colors.white,
                        backgroundColor: Colors.green,
                        onPressed: savePressed,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

String hiveBoxSettings = "settings";

class SettingsValues {
  static Future<bool> get instanceConfigured async => getHost() != null && getPort() != null && getUsername() != null && (await getPassword()) != null;

  static String? getHost() => Hive.box(hiveBoxSettings).get("host");
  static setHost(String value) => Hive.box(hiveBoxSettings).put("host", value);

  static int? getPort() => Hive.box(hiveBoxSettings).get("port");
  static setPort(int value) => Hive.box(hiveBoxSettings).put("port", value);

  static String? getUsername() => Hive.box(hiveBoxSettings).get("username");
  static setUsername(String value) => Hive.box(hiveBoxSettings).put("username", value);

  static Future<String?> getPassword() async => await const FlutterSecureStorage().read(key: "password");
  static setPassword(String value) => const FlutterSecureStorage().write(key: "password", value: value);
}
