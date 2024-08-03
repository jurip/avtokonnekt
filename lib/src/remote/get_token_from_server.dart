import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fluttsec/main.dart';

Future<String> getTokenFromServer() async {
  String username = 'my-client';
  String password = 'my-secret';
  String basicAuth =
      'Basic ${base64.encode(utf8.encode('$username:$password'))}';
  print(basicAuth);
  var dio = Dio();
  var data = "grant_type=client_credentials";
  var headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Authorization': basicAuth
  };
  var response = await dio.request('${site}oauth2/token',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data);

  return response.data['access_token'];
}
