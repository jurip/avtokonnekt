import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:fluttsec/src/remote/login.dart';
import 'package:fluttsec/src/remote/save_with_photos.dart';

Future<bool> updateZayavka(ZayavkaRemote zayavka, String mytoken, String status) async {
    bool ok = await login(getFullUsername, password.value);
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  headers.addAll({'Authorization': 'Bearer $mytoken'});

  var data = json.encode({
    "zayavka": {"id": "${zayavka.id}", "status": status, }
  });
  var dio = Dio();
  var response = await dio.request(
    '${site}rest/services/flutterService/sendZayavkaUpdate',
    options: Options(
      method: 'POST',
      headers: headers,
    ),
    data: data,
  );

  if (response.statusCode == 200) {
    print(json.encode(response.data));
  } else {
    return false;
  }
  return true;
}
