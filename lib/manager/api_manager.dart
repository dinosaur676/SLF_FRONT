import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

class APIManager {
  static const String URI_CHICKEN = "/api/chicken";
  static const String URI_PRICE = "/api/price";

  String _baseUri = "http://192.168.219.101:8390";

  Future<dynamic> GET(String uri, Map param) async {
    String paramString = "";

    param.forEach((key, value) {
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