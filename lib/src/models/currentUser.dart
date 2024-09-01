import 'dart:async';

import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../main.dart';

part 'currentUser.g.dart';

@JsonSerializable()
@DataRepository([JsonServerAdapter])
class CurrentUser extends DataModel<CurrentUser> {
  @override
  final String? id;
  final String firstName;
   final String lastName;

  CurrentUser({this.id,required this.firstName,required this.lastName});

}
mixin JsonServerAdapter<T extends DataModel<T>> on RemoteAdapter<T> {
 
  @override
  FutureOr<Map<String, dynamic>> get defaultParams => 
  {'username': user.value};
  @override
  String urlForFindAll(Map<String, dynamic> params) => 
  'services/flutterService/loadUser';
  @override
  String get baseUrl => '${site}rest/';
  
  @override
   FutureOr<Map<String, String>> get defaultHeaders async {
     return await super.defaultHeaders..addAll({'Authorization': 'Bearer ${token.value}'});
   }


 
}
