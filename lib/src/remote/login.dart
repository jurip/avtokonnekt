import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/src/remote/get_token_from_server.dart';

Future<bool> login(String username, String password) async {
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  headers.addAll({'Authorization': 'Bearer ${token.value}'});

  var data =
      json.encode({"username": "${username}", "password": "${password}"});
  var dio = Dio();
  var response;
  try{
 response = await dio.request(
    '${site}rest/services/flutterService/login',
    options: Options(
      method: 'POST',
      headers: headers,
    ),
    data: data,
  );
  }catch(e){
     if (e.toString().contains("401")) {
      token.value = await getTokenFromServer();
headers.addAll({'Authorization': 'Bearer ${token.value}'});

response = await dio.request(
    '${site}rest/services/flutterService/login',
    options: Options(
      method: 'POST',
      headers: headers,
    ),
    data: data,
  );
     }

  }

  if (response.statusCode == 200) {
    print(json.encode(response.data));
    return response.data == "ok";
  }
  
  return false;
  }
