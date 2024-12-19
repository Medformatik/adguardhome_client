import 'package:adguard_home_client/main.dart';
import 'package:adguard_home_client/pages/settings.dart';
import 'package:adguard_home_client/widgets/statistics_card.dart';
import 'package:adguard_home_client/widgets/statistics_table_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<String?>? version;

  @override
  void initState() {
    super.initState();
    if (instanceConfigured) {
      version = adGuardHome!.version();
    }
  }

  @override
  Widget build(BuildContext context) {
    return !instanceConfigured
        ? const SettingsPage()
        : Scaffold(
            appBar: AppBar(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AdGuard Home'),
                  FutureBuilder(
                    future: version,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return Text(
                        snapshot.hasData ? snapshot.data : 'Loading...',
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ],
              ),
              actions: [
                _SettingsButton(),
                _ProtectionToggleButton(key: UniqueKey()),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16.0,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 0.0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const _StatisticsHeadline(),
                            SizedBox(
                              height: 40.0,
                              child: CircleAvatar(
                                radius: 30.0,
                                backgroundColor: Colors.green,
                                child: GestureDetector(
                                  onTap: () => setState(() {}),
                                  child: const Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatisticsCard(
                        key: UniqueKey(),
                        primaryFuture: adGuardHome!.stats.dnsQueries(),
                        secondaryFuture: adGuardHome!.stats.avgProcessingTime(),
                        secondaryPrefix: '~',
                        secondarySuffix: 'ms',
                        graphFuture: adGuardHome!.stats.dnsQueriesPerDay(),
                        title: 'DNS Queries',
                        textColor: Colors.blue,
                        icon: Icons.dns,
                      ),
                      StatisticsCard(
                        key: UniqueKey(),
                        primaryFuture: adGuardHome!.stats.blockedFiltering(),
                        secondaryFuture: adGuardHome!.stats.blockedPercentage(),
                        secondarySuffix: '%',
                        graphFuture: adGuardHome!.stats.blockedFilteringPerDay(),
                        title: 'Blocked by Filters',
                        textColor: Colors.red,
                        icon: Icons.security,
                      ),
                      StatisticsCard(
                        key: UniqueKey(),
                        primaryFuture: adGuardHome!.stats.replacedSafebrowsing(),
                        graphFuture: adGuardHome!.stats.replacedSafebrowsingPerDay(),
                        title: 'Blocked malware/phishing',
                        textColor: Colors.green[500]!,
                        icon: Icons.coronavirus,
                      ),
                      StatisticsCard(
                        key: UniqueKey(),
                        primaryFuture: adGuardHome!.stats.replacedParental(),
                        graphFuture: adGuardHome!.stats.replacedParentalPerDay(),
                        title: 'Blocked adult websites',
                        textColor: Colors.yellow[700]!,
                        icon: Icons.person,
                      ),
                      StatisticsCard(
                        key: UniqueKey(),
                        primaryFuture: adGuardHome!.stats.replacedSafesearch(),
                        title: 'Enforced safe search',
                        textColor: Colors.purple[500]!,
                        icon: Icons.search,
                      ),
                      StatisticsTableCard(
                        key: UniqueKey(),
                        future: adGuardHome!.stats.topQueriedDomains(),
                        totalFuture: adGuardHome!.stats.dnsQueries(),
                        title: 'Top queried domains',
                        keyColumn: 'Domain',
                        valueColumn: 'Request count',
                        textColor: Colors.blue,
                        icon: Icons.dns,
                      ),
                      StatisticsTableCard(
                        key: UniqueKey(),
                        future: adGuardHome!.stats.topBlockedDomains(),
                        totalFuture: adGuardHome!.stats.blockedFiltering(),
                        title: 'Top blocked domains',
                        keyColumn: 'Domain',
                        valueColumn: 'Request count',
                        textColor: Colors.red,
                        icon: Icons.security,
                      ),
                      StatisticsTableCard(
                        key: UniqueKey(),
                        future: adGuardHome!.stats.topClients(),
                        totalFuture: adGuardHome!.stats.dnsQueries(),
                        title: 'Top clients',
                        keyColumn: 'Client',
                        valueColumn: 'Request count',
                        textColor: Colors.black,
                        icon: Icons.people,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

class _SettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: IconButton.filled(
        style: IconButton.styleFrom(
          backgroundColor: Colors.blue[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
        icon: const Icon(
          Icons.settings,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/settings');
        },
      ),
    );
  }
}

class _ProtectionToggleButton extends StatefulWidget {
  const _ProtectionToggleButton({super.key});

  @override
  State<_ProtectionToggleButton> createState() => __ProtectionToggleButtonState();
}

class __ProtectionToggleButtonState extends State<_ProtectionToggleButton> {
  late Future<bool?>? protectionEnabled;

  @override
  void initState() {
    super.initState();
    if (instanceConfigured) {
      protectionEnabled = adGuardHome!.protectionEnabled();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
        future: protectionEnabled,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
              ),
              icon: SizedBox(
                height: 16.0,
                width: 16.0,
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              ),
              onPressed: () {},
            );
          }
          return snapshot.data
              ? IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                  ),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await adGuardHome!.disableProtection();
                    setState(() {
                      protectionEnabled = adGuardHome!.protectionEnabled();
                    });
                  },
                )
              : IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                  ),
                  icon: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await adGuardHome!.enableProtection();
                    setState(() {
                      protectionEnabled = adGuardHome!.protectionEnabled();
                    });
                  },
                );
        },
      ),
    );
  }
}

class _StatisticsHeadline extends StatefulWidget {
  const _StatisticsHeadline();

  @override
  State<_StatisticsHeadline> createState() => __StatisticsHeadlineState();
}

class __StatisticsHeadlineState extends State<_StatisticsHeadline> {
  late Future<int>? period;

  @override
  void initState() {
    super.initState();
    if (instanceConfigured) {
      period = adGuardHome!.stats.period();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: period,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Expanded(
          child: Text(
            "Statistics for the last ${snapshot.data ?? "..."} days",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[800]),
          ),
        );
      },
    );
  }
}
