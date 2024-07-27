import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';

import 'avtomobilRemote.dart';
import 'chek.dart';

part 'chekFoto.g.dart';

@JsonSerializable()
@DataRepository([])
class ChekFoto extends DataModel<ChekFoto> {
  @override
  final String? id;
  String? file;
  final String? fileLocal;
  final BelongsTo<Chek> chek;
  ChekFoto({this.id,this.file, this.fileLocal, required this.chek});
  ChekFoto addFile(String f) {
    return ChekFoto(id: this.id,file:f,fileLocal:  this.fileLocal,chek:  this.chek);
  }
}

