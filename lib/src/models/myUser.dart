import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';
part 'myUser.g.dart';
@JsonSerializable()
@DataRepository([])
class MyUser extends DataModel<MyUser> {
  @override
  final String? id;
  final String username;
  String? mode = "light"; 
  MyUser(this.id,{required this.username});

  checkIfAuthenticated() {
    return username!=null;
  }
}