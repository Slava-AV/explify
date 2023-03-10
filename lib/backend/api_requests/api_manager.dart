import 'dart:convert';
import 'dart:io';
import 'dart:core';

import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';

enum ApiCallType {
  GET,
  POST,
}

class ApiCallRecord extends Equatable {
  ApiCallRecord(
      this.callName, this.domain, this.endpoint, this.headers, this.params);
  final String callName;
  final String domain;
  final String endpoint;
  final Map<String, dynamic> headers;
  final Map<String, dynamic> params;


  @override
  List<Object> get props => [callName, domain, endpoint, headers, params];
}

class ApiManager {
  ApiManager._();
  var client = http.Client();

  // Cache that will ensure identical calls are not repeatedly made.
  static Map<ApiCallRecord, dynamic> _apiCache = {};

  static ApiManager _instance;
  static ApiManager get instance => _instance ??= ApiManager._();

  static String _accessToken;

  static void clearCache(String callName) => _apiCache.keys
      .toSet()
      .forEach((k) => k.callName == callName ? _apiCache.remove(k) : null);

  static Map<String, String> toStringMap(Map<String, dynamic> map) =>
      map.map((key, value) => MapEntry(key, value.toString()));

  static Future<dynamic> getRequest(
      String apiDomain,
      String endpoint,
      Map<String, dynamic> headers,
      Map<String, dynamic> params,
      bool returnResponse) async {
    final uri = Uri.https(apiDomain, endpoint, toStringMap(params));
    final response = await http.get(uri, headers: toStringMap(headers));
    return returnResponse ? json.decode(response.body) : null;
  }

  Future<dynamic> postRequest(
      String apiDomain,
      String endpoint,
      Map<String, dynamic> headers,
      Map<String, dynamic> params,
      bool returnResponse) async {
    final uri = Uri.https(apiDomain, endpoint);
    final response = await client.post(uri,
        headers: toStringMap(headers), body: json.encode(params));
    return returnResponse ? json.decode(response.body) : null;
  }

  Future<dynamic> makeApiCall(
      {String callName,
      String apiDomain,
      String apiEndpoint,
      ApiCallType callType,
      Map<String, dynamic> headers = const {},
      Map<String, dynamic> params = const {},
      bool returnResponse}) async {
    final callRecord =
        ApiCallRecord(callName, apiDomain, apiEndpoint, headers, params);
    // Modify for your specific needs if this differs from your API.
    if (_accessToken != null) {
      headers[HttpHeaders.authorizationHeader] = 'Token $_accessToken';
    }

    var result;
    switch (callType) {
      case ApiCallType.GET:
        result = await getRequest(
            apiDomain, apiEndpoint, headers, params, returnResponse);
        break;
      case ApiCallType.POST:
        result = await postRequest(
            apiDomain, apiEndpoint, headers, params, returnResponse);
        break;
    }

    if (result != null) {
      _apiCache[callRecord] = result;
    }

    return result;
  }
}
