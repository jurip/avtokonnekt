
import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';
part 'myToken.g.dart';
@JsonSerializable()
@DataRepository([])
class MyToken extends DataModel<MyToken> {
  @override
  final String? id;
  final String nomer;
  MyToken(this.id,{required this.nomer});
}