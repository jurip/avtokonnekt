import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'avtomobilRemote.dart';

part 'usluga.g.dart';

@JsonSerializable()
@DataRepository([])
class Usluga extends DataModel<Usluga> {
  @override
  final String? id;
  String? title;
  String? code;
  String? dop = "N";

  final BelongsTo<AvtomobilRemote> avtomobil;
  Usluga({id,required this.title,required this.code, required this.avtomobil}):id=id??Uuid().v4();

}

