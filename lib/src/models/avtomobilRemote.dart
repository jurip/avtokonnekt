
import 'dart:async';

import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/src/models/avtoFoto.dart';
import 'package:fluttsec/src/models/foto.dart';
import 'package:fluttsec/src/models/oborudovanie.dart';
import 'package:fluttsec/src/models/oborudovanieFoto.dart';
import 'package:fluttsec/src/models/user.dart';
import 'package:fluttsec/src/models/usluga.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:json_annotation/json_annotation.dart';
part 'avtomobilRemote.g.dart';

@JsonSerializable()
@DataRepository([JsonServerAdapter])
class AvtomobilRemote extends DataModel<AvtomobilRemote> {
  static String VYPOLNENA = "VYPOLNENA";
  static String  POSLANA_V_BIPIUM = "POSLANA_V_BIPIUM";
  @override
  final String? id;
  final String? nomer;
  final String? marka;
  final String? nomerAG;
  DateTime? date = DateTime.now();
  DateTime? nachaloRabot;
   String? comment;
   String? lat ="0";
   String? lng = "0";
  final BelongsTo<ZayavkaRemote>? zayavka;

   String? status = AvtomobilRemote.NOVAYA;
  final HasMany<AvtoFoto> avtoFoto = HasMany<AvtoFoto>();
  final HasMany<Foto> fotos = HasMany<Foto>();
  final HasMany<Usluga> performance_service = HasMany<Usluga>();
  final HasMany<User> users = HasMany<User>();
  final HasMany<Oborudovanie> barcode = HasMany<Oborudovanie>();
  final HasMany<OborudovanieFoto> oborudovanieFotos = HasMany<OborudovanieFoto>();
  
  static String NOVAYA = "NOVAYA";
  AvtomobilRemote( {this.id, required this.nomer, this.marka,this.nomerAG,this.comment, this.status, this.date, BelongsTo<ZayavkaRemote>? zayavka}) :
    zayavka = zayavka ?? BelongsTo();

  bool isOpen(){
     return status != AvtomobilRemote.VYPOLNENA;
  }
}

mixin JsonServerAdapter<T extends DataModel<T>> on RemoteAdapter<T> {

  @override
  DataRequestMethod methodForSave(id, Map<String, dynamic> params) {
    // TODO: implement methodForSave
    return DataRequestMethod.POST;
  }
 
  @override
  String urlForSave(id, Map<String, dynamic> params) => "services/flutterService/saveAvto";

  @override
  FutureOr<Map<String, dynamic>> get defaultParams => 
  {'username': company.value+"|"+user.value};
  
  @override
  String get baseUrl => '${site}rest/';
  
  @override
   FutureOr<Map<String, String>> get defaultHeaders async {
     return await super.defaultHeaders..addAll({'Authorization': 'Bearer ${token.value}'});
   }
}


