import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/src/remote/login.dart';
import 'package:fluttsec/src/remote/save_chek.dart';
import 'package:fluttsec/src/models/chek.dart';
import 'package:fluttsec/src/models/chekFoto.dart';
import 'package:fluttsec/src/remote/save_with_photos.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<bool> saveChekWithPhotos(Chek chek, WidgetRef ref, mytoken) async {
  bool ok = await login(getFullUsername, password.value);

  for (ChekFoto foto in chek.fotos.toList()) {
    var headers = {
      'Content-Type': 'image/jpeg',
      'Authorization': 'Bearer $mytoken'
    };
    var data = File(foto.fileLocal!).readAsBytesSync();
     var n = foto.fileLocal!.lastIndexOf("/");
    var name = foto.fileLocal!.substring(n+1);

    var dio = Dio();
    var response = await dio.request(
      '${site}rest/files?name='+name,
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
  return saveChek(chek, mytoken);
}
