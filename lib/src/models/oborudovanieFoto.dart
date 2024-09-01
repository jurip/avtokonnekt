import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';

import 'avtomobilRemote.dart';

part 'oborudovanieFoto.g.dart';

@JsonSerializable()
@DataRepository([])
class OborudovanieFoto extends DataModel<OborudovanieFoto> {
  @override
  final String? id;
  String? file;
  final String? fileLocal;
  final BelongsTo<AvtomobilRemote> avtomobil;
  OborudovanieFoto({this.id, this.file,this.fileLocal, required this.avtomobil});

}

