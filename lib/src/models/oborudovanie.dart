import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';

import 'avtomobilRemote.dart';

part 'oborudovanie.g.dart';

@JsonSerializable()
@DataRepository([])
class Oborudovanie extends DataModel<Oborudovanie> {
  @override
  final String? id;
  String? code;
  final BelongsTo<AvtomobilRemote> avtomobil;
  Oborudovanie({this.id, this.code, required this.avtomobil});

}

