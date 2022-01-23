import 'dart:math';
import 'dart:core';

import 'package:adguardhome_client/interface/adguardhome.dart';

class AdGuardHomeStats {
  final AdGuardHome _adGuardHome;
  AdGuardHomeStats(this._adGuardHome);

  /* Provides stats of AdGuard Home. */

  Future<Map<String, dynamic>> fullReport() async {
    return {
      "DNS queries": await dnsQueries(),
      "Blocked DNS queries": await blockedFiltering(),
      "Blocked percentage ratio of DNS queries": await blockedPercentage(),
      "Blocked pages by safe browsing": await replacedSafebrowsing(),
      "Blocked pages by parental control": await replacedParental(),
      "Enforced safe searches": await replacedSafesearch(),
      "Average processing time of DNS queries (in ms)": await avgProcessingTime(),
      "Time period to keep data (in days)": await period(),
      "Top queried domains": await topQueriedDomains(),
      "Top blocked domains": await topBlockedDomains(),
      "Top clients": await topClients(),
      "DNS queries per day": await dnsQueriesPerDay(),
      "Blocked DNS queries per day": await blockedFilteringPerDay(),
      "Blocked pages by safe browsing per day": await replacedSafebrowsingPerDay(),
      "Blocked pages by parental control per day": await replacedParentalPerDay(),
    };
  }

  Future<int> dnsQueries() async {
    /* Return number of DNS queries.

        Returns:
            The number of DNS queries performed by the AdGuard Home instance.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats");
    return response["num_dns_queries"];
  }

  Future<int> blockedFiltering() async {
    /* Return number of blocked DNS queries.

        Returns:
            The number of DNS queries blocked by the AdGuard Home instance.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats");
    return response["num_blocked_filtering"];
  }

  Future<double> blockedPercentage() async {
    /* Return the blocked percentage ratio of DNS queries.

        Returns:
            The percentage ratio of blocked DNS queries by the AdGuard Home
            instance.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats");
    if (response["num_dns_queries"] == null) return 0.0;
    return round((response["num_blocked_filtering"] / response["num_dns_queries"]) * 100.0, 2);
  }

  Future<int> replacedSafebrowsing() async {
    /* Return number of blocked pages by safe browsing.

        Returns:
            The number of times a page was blocked by the safe
            browsing feature of the AdGuard Home instance.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats");
    return response["num_replaced_safebrowsing"];
  }

  Future<int> replacedParental() async {
    /* Return number of blocked pages by parental control.

        Returns:
            The number of times a page was blocked by the parental control
            feature of the AdGuard Home instance.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats");
    return response["num_replaced_parental"];
  }

  Future<int> replacedSafesearch() async {
    /* Return number of enforced safe searches.

        Returns:
            The number of times a safe search was enforced by the
            AdGuard Home instance.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats");
    return response["num_replaced_safesearch"];
  }

  Future<double> avgProcessingTime() async {
    /* Return average processing time of DNS queries (in ms).

        Returns:
            The averages processing time (in milliseconds) of DNS queries
            as performed by the AdGuard Home instance.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats");
    if (response["num_dns_queries"] == null) return 0.0;
    return round(response["avg_processing_time"] * 1000, 2);
  }

  Future<int> period() async {
    /* Return the time period to keep data (in days).

        Returns:
            The time period of data this AdGuard Home instance keeps.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats_info");
    return response["interval"];
  }

  Future<Map<String, int>> topQueriedDomains() async {
    /* Return the top queried domains.

        Returns:
            The top queried domains as a Map<String, int>.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats");
    Map<String, int> topQueriedDomains = {};
    response["top_queried_domains"].forEach((i) {
      Map<String, dynamic> topDomain = Map<String, dynamic>.from(i);
      topQueriedDomains[topDomain.entries.first.key] = topDomain.entries.first.value;
    });
    return topQueriedDomains;
  }

  Future<Map<String, int>> topBlockedDomains() async {
    /* Return the top blocked domains.

        Returns:
            The top blocked domains as a Map<String, int>.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats");
    Map<String, int> topBlockedDomains = {};
    response["top_blocked_domains"].forEach((i) {
      Map<String, dynamic> topDomain = Map<String, dynamic>.from(i);
      topBlockedDomains[topDomain.entries.first.key] = topDomain.entries.first.value;
    });
    return topBlockedDomains;
  }

  Future<Map<String, int>> topClients() async {
    /* Return the top clients.

        Returns:
            The top clients as a Map<String, int>.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats");
    Map<String, int> topClients = {};
    response["top_clients"].forEach((i) {
      Map<String, dynamic> topClient = Map<String, dynamic>.from(i);
      topClients[topClient.entries.first.key] = topClient.entries.first.value;
    });
    return topClients;
  }

  Future<List<int>> dnsQueriesPerDay() async {
    /* Return the number of DNS queries per day.

        Returns:
            The number of DNS queries per day as a list of integers.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats");
    List<int> dnsQueriesPerDay = [];
    response["dns_queries"].forEach((i) {
      dnsQueriesPerDay.add(i);
    });
    return dnsQueriesPerDay;
  }

  Future<List<int>> blockedFilteringPerDay() async {
    /* Return the number of blocked DNS queries per day.

        Returns:
            The number of blocked DNS queries per day as a list of integers.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats");
    List<int> blockedFilteringPerDay = [];
    response["blocked_filtering"].forEach((i) {
      blockedFilteringPerDay.add(i);
    });
    return blockedFilteringPerDay;
  }

  Future<List<int>> replacedSafebrowsingPerDay() async {
    /* Return the number of blocked pages by safe browsing per day.

        Returns:
            The number of blocked pages by safe browsing per day as a list of
            integers.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats");
    List<int> replacedSafebrowsingPerDay = [];
    response["replaced_safebrowsing"].forEach((i) {
      replacedSafebrowsingPerDay.add(i);
    });
    return replacedSafebrowsingPerDay;
  }

  Future<List<int>> replacedParentalPerDay() async {
    /* Return the number of blocked pages by parental control per day.

        Returns:
            The number of blocked pages by parental control per day as a list
            of integers.
        */
    Map<String, dynamic> response = await _adGuardHome.request("stats");
    List<int> replacedParentalPerDay = [];
    response["replaced_parental"].forEach((i) {
      replacedParentalPerDay.add(i);
    });
    return replacedParentalPerDay;
  }

  Future<void> reset() async {
    /* Reset all stats.

        Raises:
            AdGuardHomeError: Restting the AdGuard Home stats did not succeed.
        */
    try {
      _adGuardHome.request("stats_reset", method: "POST");
    } catch (e) {
      print("AdGuardHomeError: Restting the AdGuard Home stats did not succeed.");
    }
  }

  double round(double value, int places) {
    double mod = pow(10.0, places) as double;
    return ((value * mod).round().toDouble() / mod);
  }
}
