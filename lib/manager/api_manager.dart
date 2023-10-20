import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:slf_front/setting.dart';

class APIManager {
  static const String URI_CHICKEN_PRODUCTION = "/api/chicken-production";
  static const String URI_CHICKEN_SELL = "/api/chicken-sell";
  static const String URI_PRICE = "/api/price";
  static const String URI_COMPANY = "/api/company";
  static const String URI_BUY = "/api/buy";
  static const String URI_WORK = "/api/work";
  static const String URI_DATE = "/api/date";

  final String _baseUri = Setting.testURI;

  Future<dynamic> GET(String uri, Map? param) async {
    String paramString = "";

    param?.forEach((key, value) {
      paramString += "${key}=${value}&";
    });

    String newUri = "$uri?$paramString";

    final http.Response httpResponse = await http.get(
        Uri.parse(_baseUri + newUri),
    );

    final response = json.decode(utf8.decode(httpResponse.bodyBytes));

    return httpResponse.statusCode == 200 ?  response["data"] : null;
  }

  Future<dynamic> POST(String uri, Map param) async {
    final http.Response httpResponse = await http.post(
        Uri.parse(_baseUri + uri),
        headers: <String, String>{
          'Content-Type' : 'application/json'
        },
        body: json.encode(param)
    );

    final response = json.decode(utf8.decode(httpResponse.bodyBytes));

    return httpResponse.statusCode == 200 ?  response["data"] : null;
  }

  Future<dynamic> PUT(String uri, Map param) async {

    final http.Response httpResponse = await http.put(
        Uri.parse(_baseUri + uri),
        headers: <String, String>{
          'Content-Type' : 'application/json'
        },
        body: json.encode(param)
    );


    final response = json.decode(utf8.decode(httpResponse.bodyBytes));

    return httpResponse.statusCode == 200 ?  response["data"] : null;
  }

  Future<dynamic> DELETE(String uri, Map param) async {


    final http.Response httpResponse = await http.delete(
        Uri.parse(_baseUri + uri),
        headers: <String, String>{
          'Content-Type' : 'application/json'
        },
        body: json.encode(param)
    );

    final response = json.decode(utf8.decode(httpResponse.bodyBytes));

    return httpResponse.statusCode == 200 ?  response["data"] : null;
  }

}