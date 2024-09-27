
import 'dart:async';

import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/src/models/foto.dart';
import 'package:fluttsec/src/models/oborudovanie.dart';
import 'package:fluttsec/src/models/oborudovanieFoto.dart';
import 'package:fluttsec/src/models/pFoto.dart';
import 'package:fluttsec/src/models/pOborudovanie.dart';
import 'package:fluttsec/src/models/usluga.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:json_annotation/json_annotation.dart';
part 'peremeshenieOborudovaniya.g.dart';

@JsonSerializable()
@DataRepository([JsonServerAdapter])
class PeremesheniyeOborudovaniya extends DataModel<PeremesheniyeOborudovaniya> {
  @override
  final String? id;
  final DateTime? date;
  String? comment;
  
  String? status;
  final HasMany<PFoto> fotos = HasMany<PFoto>();
  final HasMany<POborudovanie> barcode = HasMany<POborudovanie>();
  PeremesheniyeOborudovaniya( {this.id,this.comment, this.status, this.date});
   
}

mixin JsonServerAdapter<T extends DataModel<T>> on RemoteAdapter<T> {

 
  @override
  FutureOr<Map<String, dynamic>> get defaultParams => 
  {'username': company.value+"|"+ user.value};
  
  @override
  String get baseUrl => '${site}rest/';
  
  @override
   FutureOr<Map<String, String>> get defaultHeaders async {
     return await super.defaultHeaders..addAll({'Authorization': 'Bearer ${token.value}'});
   }
}


