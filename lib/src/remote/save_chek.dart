import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/src/models/chek.dart';
import 'package:fluttsec/src/models/chekFoto.dart';

Future<bool> saveChek(Chek a, mytoken) async {
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  headers.addAll({'Authorization': 'Bearer $mytoken'});

  var date = DateTime.now().toIso8601String();
  var fotos = [];
  for (ChekFoto f in a.fotos.toList()) {
    if (f.file != null) fotos.add({"file": f.file});
  }

  var data = json.encode({
    "chek": {
      "date": "$date",
      "fotos": fotos,
      "comment": a.comment,
      "username": company.value+"|"+user.value,
      "tenantAttribute":company.value

    }
  });
  var dio = Dio();
  var response = await dio.request(
    '${site}rest/services/flutterService/saveChek',
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
