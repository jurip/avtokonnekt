import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'avtomobilRemote.dart';

part 'avtoFoto.g.dart';

@JsonSerializable()
@DataRepository([])
class AvtoFoto extends DataModel<AvtoFoto> {
  @override
  final String? id;
  String? file;
  final String? fileLocal;
  final BelongsTo<AvtomobilRemote> avtomobil;
  AvtoFoto({id,this.file, this.fileLocal, required this.avtomobil}):id=id??Uuid().v4();
 
}

