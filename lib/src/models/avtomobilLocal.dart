

import 'package:flutter_data/flutter_data.dart';

import 'package:fluttsec/src/models/foto.dart';
import 'package:fluttsec/src/models/oborudovanie.dart';
import 'package:fluttsec/src/models/oborudovanieFoto.dart';
import 'package:fluttsec/src/models/usluga.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:json_annotation/json_annotation.dart';
part 'avtomobilLocal.g.dart';

@JsonSerializable()
@DataRepository([])
class AvtomobilLocal extends DataModel<AvtomobilLocal>  {
  @override
  final String? id;
  final String? nomer;
  final String? marka;
  final String? nomerAG;
  final DateTime? date;
   String? comment;
  final BelongsTo<ZayavkaRemote>? zayavka;

   String? status;
  final HasMany<Foto> fotos = HasMany<Foto>();
  final HasMany<Usluga> performance_service = HasMany<Usluga>();
  final HasMany<Oborudovanie> barcode = HasMany<Oborudovanie>();
  final HasMany<OborudovanieFoto> oborudovanieFotos = HasMany<OborudovanieFoto>();
  AvtomobilLocal( {this.id, required this.nomer, this.marka,this.nomerAG,this.comment, this.status, this.date, BelongsTo<ZayavkaRemote>? zayavka}) :
    zayavka = zayavka ?? BelongsTo();
}

