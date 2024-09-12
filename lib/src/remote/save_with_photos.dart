import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/src/models/oborudovanieFoto.dart';
import 'package:fluttsec/src/remote/save_avto.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/foto.dart';

Future<bool> sendAvto(
    AvtomobilRemote avto, mytoken) async {
  for (Foto foto in avto.fotos.toList()) {
    var headers = {
      'Content-Type': 'image/jpeg',
      'Authorization': 'Bearer $mytoken'
    };
    var data = File(foto.fileLocal!).readAsBytesSync();

    var dio = Dio();
    var response = await dio.request(
      '${site}rest/files?name=cat-via-direct-request.jpg',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 201) {
      print(response.data);
      String f = response.data['fileRef'];
      foto.file = f;
    } else {
      return false;
    }
  }

  for (OborudovanieFoto foto in avto.oborudovanieFotos.toList()) {
    var headers = {
      'Content-Type': 'image/jpeg',
      'Authorization': 'Bearer $mytoken'
    };
    var data = File(foto.fileLocal!).readAsBytesSync();

    var dio = Dio();
    var response = await dio.request(
      '${site}rest/files?name=cat-via-direct-request.jpg',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 201) {
      print(response.data);
      String f = response.data['fileRef'];
      foto.file = f;
    } else {
      return false;
    }
  }

  return saveAvto(avto, mytoken);
}
