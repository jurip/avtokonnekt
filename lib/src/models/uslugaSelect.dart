import 'dart:async';

import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../main.dart';

part 'uslugaSelect.g.dart';

@JsonSerializable()
@DataRepository([JsonServerAdapter])
class UslugaSelect extends DataModel<UslugaSelect> {
  @override
  final String? id;
  final String? title;
  final String? code;
  final String? prioritet;
  UslugaSelect({this.id, required this.title, required this.code, required this.prioritet});
 


}
mixin JsonServerAdapter<T extends DataModel<T>> on RemoteAdapter<T> {

  @override
  FutureOr<Map<String, dynamic>> get defaultParams =>
      {'company': company.value};
  @override
  String urlForFindAll(Map<String, dynamic> params) =>
      'services/flutterService/getAllUslugas';
  @override
  String get baseUrl => '${site}rest/';

  @override
  FutureOr<Map<String, String>> get defaultHeaders async {
    return await super.defaultHeaders..addAll({'Authorization': 'Bearer ${token.value}'});
  }


}

