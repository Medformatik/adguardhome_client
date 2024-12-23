import 'dart:convert';

import 'package:adguard_home_client/interface/filtering.dart';
import 'package:adguard_home_client/interface/parental.dart';
import 'package:adguard_home_client/interface/querylog.dart';
import 'package:adguard_home_client/interface/safebrowsing.dart';
import 'package:adguard_home_client/interface/safesearch.dart';
import 'package:adguard_home_client/interface/stats.dart';
import 'package:dio/dio.dart';

class AdGuardHome {
  final String host;
  final String basePath;
  final String? password;
  final int port;
  final int requestTimeout;
  final bool tls;
  final String? userAgent;
  final String? username;
  final bool verifySsl;

  late AdGuardHomeFiltering filtering;
  late AdGuardHomeParental parental;
  late AdGuardHomeQueryLog queryLog;
  late AdGuardHomeSafeBrowsing safeBrowsing;
  late AdGuardHomeSafeSearch safeSearch;
  late AdGuardHomeStats stats;

  Dio? _session;
  bool _closeSession = false;

  bool get isDemo => host == 'demo.demo.demo' && port == 3000 && username == 'demo' && password == 'demo';
  bool _demoProtectionEnabled = true;

  AdGuardHome({
    required this.host,
    this.basePath = '/control',
    this.password,
    this.port = 3000,
    this.requestTimeout = 10000,
    this.tls = false,
    this.userAgent,
    this.username,
    this.verifySsl = true,
  }) {
    // Initialize connection with AdGuard Home.

    // Class constructor for setting up an AdGuard Home object to
    // communicate with an AdGuard Home instance.

    /* 
    Args:
      host: Hostname or IP address of the AdGuard Home instance.
      basePath: Base path of the API, usually `/control`, which is the default.
      password: Password for HTTP auth, if enabled.
      port: Port on which the API runs, usually 3000.
      requestTimeout: Max timeout to wait for a response from the API.
      session: Optional, shared, aiohttp client session.
      tls: True, when TLS/SSL should be used.
      userAgent: Defaults to PythonAdGuardHome/<version>.
      username: Username for HTTP auth, if enabled.
      verifySsl: Can be set to false, when TLS with self-signed cert is used.
    */

    filtering = AdGuardHomeFiltering(this);
    parental = AdGuardHomeParental(this);
    queryLog = AdGuardHomeQueryLog(this);
    safeBrowsing = AdGuardHomeSafeBrowsing(this);
    safeSearch = AdGuardHomeSafeSearch(this);
    stats = AdGuardHomeStats(this);
  }

  Future<Map<String, dynamic>> request(
    String uri, {
    String method = 'GET',
    dynamic data,
    Map? jsonData,
    Map<String, String>? params,
  }) async {
    /* 
    Handle a request to the AdGuard Home instance.

    Make a request against the AdGuard Home API and handles the response.

    Args:
      uri: The request URI on the AdGuard Home API to call.
      method: HTTP method to use for the request; e.g., GET, POST.
      data: RAW HTTP request data to send with the request.
      json_data: Dictionary of data to send as JSON with the request.
      params: Mapping of request parameters to send with the request.

    Returns:
      The response from the API. In case the response is a JSON response,
      the method will return a decoded JSON response as a Python
      dictionary. In other cases, it will return the RAW text response.

    Raises:
      AdGuardHomeConnectionError: An error occurred while communicating
        with the AdGuard Home instance (connection issues).
      AdGuardHomeError: An error occurred while processing the
        response from the AdGuard Home instance (invalid data).
    */

    String scheme = tls ? 'https' : 'http';
    String url = '$scheme://$host:$port$basePath/$uri';

    String? auth;

    Map<String, String> headers = {
      'Accept': 'application/json, text/plain, */*',
    };

    if (userAgent != null) {
      headers['User-Agent'] = userAgent!;
    }

    if (username != null && password != null) {
      auth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      headers['authorization'] = auth;
    }

    if (_session == null) {
      _session = Dio(
        BaseOptions(
          connectTimeout: Duration(milliseconds: requestTimeout),
        ),
      );
      _closeSession = true;
    }

    Response? response;

    try {
      response = await _session!.fetch(
        RequestOptions(
          method: method,
          path: url,
          headers: headers,
          data: data,
          connectTimeout: Duration(milliseconds: requestTimeout),
          queryParameters: params,
        ),
      );
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        print(e.response!.data);
        print(e.response!.headers);
        print(e.response!.requestOptions);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.requestOptions);
        print(e.message);
      }
    }

    if (response == null) {
      print('No response');
      return {'error': 'No response'};
    }

    String? contentType = response.headers.value('Content-Type');

    if ([4, 5].contains(response.statusCode! ~/ 100)) {
      if (contentType == 'application/json') {
        print('AdGuardHomeError: ${response.statusCode}, ${response.data.toString()}');
      }
    }

    if (contentType != null && contentType.contains('application/json')) {
      return response.data;
    }

    String text = response.data;
    return {'message': text};
  }

  // Return if AdGuard Home protection is enabled or not.
  Future<bool> protectionEnabled() async {
    if (isDemo) return _demoProtectionEnabled;
    Map<String, dynamic> response = await request('status');
    return response['protection_enabled'] ?? false;
  }

  Future<void> enableProtection() async {
    /*
    Enable AdGuard Home protection.
    Raises:
      AdGuardHomeError: Failed enabling AdGuard Home protection.
    */
    if (isDemo) {
      _demoProtectionEnabled = true;
      return;
    }
    try {
      await request(
        'dns_config',
        method: 'POST',
        data: {'protection_enabled': true},
      );
    } catch (e) {
      print('AdGuardHomeError: Failed enabling AdGuard Home protection.');
    }
  }

  Future<void> disableProtection() async {
    /*
    Disable AdGuard Home protection.
    Raises:
      AdGuardHomeError: Failed disabling AdGuard Home protection.
    */
    if (isDemo) {
      _demoProtectionEnabled = false;
      return;
    }
    try {
      await request(
        'dns_config',
        method: 'POST',
        data: {'protection_enabled': false},
      );
    } catch (e) {
      print('AdGuardHomeError: Failed disabling AdGuard Home protection.');
    }
  }

  // Return the current version of the AdGuard Home instance.
  Future<String> version() async {
    if (isDemo) return 'Version: Demo';
    Map<String, dynamic> response = await request('status');
    return response['version'] ?? 'Version unknown';
  }

  // Returns if the AdGuard Home instance is connected or not
  Future<bool> successfullyConnected() async {
    if (isDemo) return true;
    Map<String, dynamic>? response = await request('status');
    return !(response.containsKey('error') && response['error'] == 'No response');
  }

  Future<void> close() async {
    if (_session != null && _closeSession) {
      _session!.close();
    }
  }
}
