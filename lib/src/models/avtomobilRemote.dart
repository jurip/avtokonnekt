
import 'dart:async';

import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/src/models/foto.dart';
import 'package:fluttsec/src/models/oborudovanie.dart';
import 'package:fluttsec/src/models/oborudovanieFoto.dart';
import 'package:fluttsec/src/models/usluga.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:json_annotation/json_annotation.dart';
part 'avtomobilRemote.g.dart';

@JsonSerializable()
@DataRepository([JsonServerAdapter])
class AvtomobilRemote extends DataModel<AvtomobilRemote> {
  @override
  final String? id;
  final String? nomer;
  final String? marka;
  final String? nomerAG;
  final DateTime? date;
  final BelongsTo<ZayavkaRemote>? zayavka;

   String? status;
  final HasMany<Foto> fotos = HasMany<Foto>();
  final HasMany<Usluga> performance_service = HasMany<Usluga>();
  final HasMany<Oborudovanie> barcode = HasMany<Oborudovanie>();
  final HasMany<OborudovanieFoto> oborudovanieFotos = HasMany<OborudovanieFoto>();
  AvtomobilRemote( {this.id, required this.nomer, this.marka,this.nomerAG, this.status, this.date, BelongsTo<ZayavkaRemote>? zayavka}) :
    zayavka = zayavka ?? BelongsTo();
}

mixin JsonServerAdapter<T extends DataModel<T>> on RemoteAdapter<T> {
 
  @override
  String urlForSave(id, Map<String, dynamic> params) => "entities/Avtomobil";

  @override
  FutureOr<Map<String, dynamic>> get defaultParams => 
  {'username': user.value};
  
  @override
  String get baseUrl => '${site}rest/';
  
  @override
   FutureOr<Map<String, String>> get defaultHeaders async {
     return await super.defaultHeaders..addAll({'Authorization': 'Bearer ${token.value}'});
   }
}


