import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';

Future<bool> updateZayavka(ZayavkaRemote zayavka, String mytoken, String status) async {
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
