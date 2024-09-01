import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';

import 'avtomobilRemote.dart';

part 'foto.g.dart';

@JsonSerializable()
@DataRepository([])
class Foto extends DataModel<Foto> {
  @override
  final String? id;
  String? file;
  final String? fileLocal;
  final BelongsTo<AvtomobilRemote> avtomobil;
  Foto({this.id,this.file, this.fileLocal, required this.avtomobil});
 
}

