import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fluttsec/main.dart';

Future<bool> login(String username, String password, String mytoken) async {
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  headers.addAll({'Authorization': 'Bearer ${mytoken}'});

  var data =
      json.encode({"username": "${username}", "password": "${password}"});
  var dio = Dio();
  var response = await dio.request(
    '${site}rest/services/flutterService/login',
    options: Options(
      method: 'POST',
      headers: headers,
    ),
    data: data,
  );

  if (response.statusCode == 200) {
    print(json.encode(response.data));
    if (response.data != "ok") {
      return false;
    }
  } else {
    return false;
  }
  return true;
}
