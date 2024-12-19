import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/utils/init.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<String?> password;

  bool canPop = instanceConfigured;

  @override
  void initState() {
    super.initState();
    password = SettingsValues.getPassword();
  }

  Future<bool> pop() async {
    if (await initAdGuardHome() && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      return true;
    } else {
      Fluttertoast.showToast(
        msg: 'Could not connect to AdGuard Home, please check your settings.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
  }

  Future<void> savePressed() async {
    canPop = false;
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      canPop = await pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          canPop = await pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<String?>(
              future: password,
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Form(
                  key: _formKey,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 24,
                        children: [
                          // Section Header
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'AdGuard Home Instance',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: canPop ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),

                          // Host Field
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Host',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: SettingsValues.getHost(),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(15),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Host is required.';
                              }
                              RegExp ipRegExp = RegExp(
                                r'^(?!0)(?!.*\.$)((1?\d?\d|25[0-5]|2[0-4]\d)(\.|$)){4}$',
                                caseSensitive: false,
                                multiLine: false,
                              );
                              RegExp domainRegExp = RegExp(
                                r'^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](\.[a-zA-Z]{2,})+$',
                                caseSensitive: false,
                                multiLine: false,
                              );
                              if (!ipRegExp.hasMatch(value) && !domainRegExp.hasMatch(value)) {
                                return 'Host must be a valid IP address or domain.';
                              }
                              return null;
                            },
                            onSaved: (value) => SettingsValues.setHost(value ?? ''),
                          ),

                          // Port Field
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Port',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: (SettingsValues.getPort() ?? 3000).toString(),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Port is required.';
                              }
                              int? port = int.tryParse(value);
                              if (port == null) {
                                return 'Port must be a number.';
                              }
                              if (port < 1 || port > 65535) {
                                return 'Port must be between 1 and 65535.';
                              }
                              return null;
                            },
                            onSaved: (value) => SettingsValues.setPort(int.parse(value ?? '0')),
                          ),

                          // Username Field
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: SettingsValues.getUsername(),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(32),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username is required.';
                              }
                              return null;
                            },
                            onSaved: (value) => SettingsValues.setUsername(value ?? ''),
                          ),

                          // Password Field
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: snapshot.data,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(512),
                            ],
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              SettingsValues.setPassword(value ?? '');
                              setState(() {
                                password = SettingsValues.getPassword();
                              });
                            },
                          ),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: savePressed,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

String hiveBoxSettings = 'settings';

class SettingsValues {
  static Future<bool> get instanceConfigured async => getHost() != null && getPort() != null && getUsername() != null && (await getPassword()) != null;

  static String? getHost() => Hive.box(hiveBoxSettings).get('host');
  static void setHost(String value) => Hive.box(hiveBoxSettings).put('host', value);

  static int? getPort() => Hive.box(hiveBoxSettings).get('port');
  static void setPort(int value) => Hive.box(hiveBoxSettings).put('port', value);

  static String? getUsername() => Hive.box(hiveBoxSettings).get('username');
  static void setUsername(String value) => Hive.box(hiveBoxSettings).put('username', value);

  static Future<String?> getPassword() async => await const FlutterSecureStorage().read(key: 'password');
  static void setPassword(String value) => const FlutterSecureStorage().write(key: 'password', value: value);
}
