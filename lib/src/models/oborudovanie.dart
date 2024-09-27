import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'avtomobilRemote.dart';

part 'oborudovanie.g.dart';

@JsonSerializable()
@DataRepository([])
class Oborudovanie extends DataModel<Oborudovanie> {
  @override
  final String? id;
  String? code;
  final BelongsTo<AvtomobilRemote> avtomobil;
  Oborudovanie({id, this.code, required this.avtomobil}):id=id??Uuid().v4();

}

