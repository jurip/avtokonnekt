import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:fluttsec/src/models/foto.dart';
import 'package:fluttsec/src/models/oborudovanie.dart';
import 'package:fluttsec/src/models/oborudovanieFoto.dart';
import 'package:fluttsec/src/models/usluga.dart';

Future<bool> saveAvto(AvtomobilRemote a, mytoken) async {
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  headers.addAll({'Authorization': 'Bearer $mytoken'});
  var aid = a.id;
  var marka = a.marka;
  var nomer = a.nomer;
  var nomerAG = a.nomerAG;
  var comment = a.comment;
  var date = DateTime.now().toIso8601String();
  var status = "VYPOLNENA";
  var zayavkaId = a.zayavka!.value?.id;
  var fotos = [];
  var oborudovanieFotos = [];
  for (Foto f in a.fotos.toList()) {
    if (f.file != null) fotos.add({"file": f.file});
  }
  for (OborudovanieFoto f in a.oborudovanieFotos.toList()) {
    if (f.file != null) oborudovanieFotos.add({"file": f.file});
  }
  var performance_service = [];
  for (Usluga f in a.performance_service.toList()) {
    performance_service.add({"title": f.code, "dop": f.dop});
  }
  var barcode = [];
  for (Oborudovanie f in a.barcode.toList()) {
    barcode.add({"code": f.code});
  }

  var data = json.encode({
    "avto": {
      "id": aid,
      "zayavka": {"id": "$zayavkaId"},
      "marka": "$marka",
      "nomer": "$nomer",
      "nomerAG": "$nomerAG",
      "comment": "$comment",
      "date": "$date",
      "fotos": fotos,
      "oborudovanieFotos": oborudovanieFotos,
      "barcode": barcode,
      "performance_service": performance_service,
      "status": status,
      "username": company.value+"|"+user.value,
      "tenantAttribute":company.value
    }
  });
  var dio = Dio();
  var response = await dio.request(
    '${site}rest/services/flutterService/saveAvto',
    options: Options(
      method: 'POST',
      headers: headers,
    ),
    data: data,
  );

  if (response.statusCode == 200) {
    print(json.encode(response.data));
    if(response.data == true)
    return true;
  } 
  return false;
}
