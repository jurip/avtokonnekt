import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/src/models/avtoFoto.dart';
import 'package:fluttsec/src/models/oborudovanieFoto.dart';
import 'package:fluttsec/src/remote/login.dart';
import 'package:fluttsec/src/remote/save_avto.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/foto.dart';



  
Future<bool> sendAvto(
    AvtomobilRemote avto) async {
      
  bool ok = await login(getFullUsername, password.value);

   for (Foto avtoFoto in avto.fotos.toList()) {
  
    Response response = await sendFile(avtoFoto.fileLocal!);

    if (response.statusCode == 201) {
      print(response.data);
      String f = response.data['fileRef'];
      avtoFoto.file = f;
    } else {
      return false;
    }

  }

  for (AvtoFoto avtoFoto in avto.avtoFoto.toList()) {
    var response = await sendFile(avtoFoto.fileLocal!);
    if (response.statusCode == 201) {
      print(response.data);
      String f = response.data['fileRef'];
      avtoFoto.file = f;
    } else {
      return false;
    }

  }

 

  for (OborudovanieFoto oborudovanieFoto in avto.oborudovanieFotos.toList()) {
    var response = await sendFile(oborudovanieFoto.fileLocal!);

    if (response.statusCode == 201) {
      print(response.data);
      String f = response.data['fileRef'];
      oborudovanieFoto.file = f;
    } else {
      return false;
    }
  }

  return saveAvto(avto);
}


Future<Response> sendFile(String fileLocal) async {
  var data = File(fileLocal!).readAsBytesSync();

    var dio = Dio();
      var n = fileLocal!.lastIndexOf("/");
 var name = fileLocal!.substring(n+1);
    var response = await dio.request(
      '${site}rest/files?name='+name,
      options: Options(
        method: 'POST',
        headers: getHeaders(),
      ),
      data: data,
    );
    return response;
}

String get getFullUsername => company.value +"|"+user.value;

Map<String, String> getHeaders() {
   var headers = {
    'Content-Type': 'image/jpeg',
    'Authorization': 'Bearer ${token.value}'
  };
  return headers;
}
