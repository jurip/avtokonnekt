import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/src/models/oborudovanieFoto.dart';
import 'package:fluttsec/src/remote/save_avto.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/foto.dart';



  
Future<bool> sendAvto(
    AvtomobilRemote avto, mytoken) async {
      
 

  for (Foto avtoFoto in avto.fotos.toList()) {
    var headers = {
      'Content-Type': 'image/jpeg',
      'Authorization': 'Bearer $mytoken'
    };
    var data = File(avtoFoto.fileLocal!).readAsBytesSync();

    var dio = Dio();
    var response = await dio.request(
      '${site}rest/files?name=avtofoto.jpg',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 201) {
      print(response.data);
      String f = response.data['fileRef'];
      avtoFoto.file = f;
    } else {
      return false;
    }

  }

  for (OborudovanieFoto oborudovanieFoto in avto.oborudovanieFotos.toList()) {
    var headers = {
      'Content-Type': 'image/jpeg',
      'Authorization': 'Bearer $mytoken'
    };
    var data = File(oborudovanieFoto.fileLocal!).readAsBytesSync();

    var dio = Dio();
    var response = await dio.request(
      '${site}rest/files?name=oborudovanie.jpg',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    if (response.statusCode == 201) {
      print(response.data);
      String f = response.data['fileRef'];
      oborudovanieFoto.file = f;
    } else {
      return false;
    }
  }

  return saveAvto(avto, mytoken);
}
