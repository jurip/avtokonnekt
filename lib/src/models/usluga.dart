import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';

import 'avtomobilRemote.dart';

part 'usluga.g.dart';

@JsonSerializable()
@DataRepository([])
class Usluga extends DataModel<Usluga> {
  @override
  final String? id;
  String? title;
  final BelongsTo<AvtomobilRemote> avtomobil;
  Usluga({this.id, this.title, required this.avtomobil});

}

