import 'dart:async';

import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/src/models/chekFoto.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../main.dart';

part 'chek.g.dart';

@JsonSerializable()
@DataRepository([])
class Chek extends DataModel<Chek> {
  @override
  final String? id;
  final String? username;
  final String? comment;
  final DateTime? date;
  String? status;
  final HasMany<ChekFoto> fotos = HasMany<ChekFoto>();

  Chek({this.id, this.comment,this.date, this.username, this.status="NOVAYA"});
  Chek complete(){
    return Chek(id: this.id,
    comment: this.comment,
    date: DateTime.now(), 
    status: "GOTOVAYA",
     username: this.username).withKeyOf(this);
  }

}

