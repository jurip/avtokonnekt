import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/src/models/peremeshenieOborudovaniya.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'avtomobilRemote.dart';

part 'pOborudovanie.g.dart';

@JsonSerializable()
@DataRepository([])
class POborudovanie extends DataModel<POborudovanie> {
  @override
  final String? id;
  String? code;
  final BelongsTo<PeremesheniyeOborudovaniya> peremeshenie;
  POborudovanie({id, this.code, required this.peremeshenie}):id=id??Uuid().v4();

}

