import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/src/models/peremeshenieOborudovaniya.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'avtomobilRemote.dart';

part 'pFoto.g.dart';

@JsonSerializable()
@DataRepository([])
class PFoto extends DataModel<PFoto> {
  @override
  final String? id;
  String? file;
  final String? fileLocal;
  final BelongsTo<PeremesheniyeOborudovaniya> peremeshenie;
  PFoto({id,this.file, this.fileLocal, required this.peremeshenie}):id=id??Uuid().v4();
 
}

