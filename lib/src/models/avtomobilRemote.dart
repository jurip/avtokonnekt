
import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/src/models/foto.dart';
import 'package:fluttsec/src/models/oborudovanie.dart';
import 'package:fluttsec/src/models/usluga.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:json_annotation/json_annotation.dart';
part 'avtomobilRemote.g.dart';

@JsonSerializable()
@DataRepository([])
class AvtomobilRemote extends DataModel<AvtomobilRemote> {
  @override
  final String? id;
  final String? nomer;
  final String? marka;
  final DateTime? date;
  final BelongsTo<ZayavkaRemote> zayavka;

   String? status;
  final HasMany<Foto> fotos = HasMany<Foto>();
  final HasMany<Usluga> performance_service = HasMany<Usluga>();
  final HasMany<Oborudovanie> barcode = HasMany<Oborudovanie>();

  AvtomobilRemote( {this.id, required this.zayavka, required this.nomer, this.marka,required this.status, this.date});
  AvtomobilRemote complete(){
    return AvtomobilRemote(id:this.id, zayavka: this.zayavka, nomer: this.nomer,marka:this.marka, status: "GOTOVAYA", date:DateTime.now()).withKeyOf(this);
  }

}
