
import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:json_annotation/json_annotation.dart';


part 'user.g.dart';

@JsonSerializable()
@DataRepository([])
class User extends DataModel<User> {
  @override
  final String? id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final BelongsTo<AvtomobilRemote> avtomobil;
  User({this.id, required this.username, required this.firstName, required this.lastName, required this.avtomobil});
 
}


