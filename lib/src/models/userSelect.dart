import 'dart:async';

import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../main.dart';

part 'userSelect.g.dart';

@JsonSerializable()
@DataRepository([JsonServerAdapter])
class UserSelect extends DataModel<UserSelect> {
  @override
  final String? id;
  final String? username;
  final String? firstName;
  final String? lastName;
  UserSelect({this.id, required this.username, required this.firstName, required this.lastName});
 


}
mixin JsonServerAdapter<T extends DataModel<T>> on RemoteAdapter<T> {

  @override
  FutureOr<Map<String, dynamic>> get defaultParams =>
      {'company': company.value};
  @override
  String urlForFindAll(Map<String, dynamic> params) =>
      'services/flutterService/getAllUsers';
  @override
  String get baseUrl => '${site}rest/';

  @override
  FutureOr<Map<String, String>> get defaultHeaders async {
    return await super.defaultHeaders..addAll({'Authorization': 'Bearer ${token.value}'});
  }


}

