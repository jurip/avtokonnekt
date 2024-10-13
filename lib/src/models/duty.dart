import 'dart:async';

import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../main.dart';

part 'duty.g.dart';

@JsonSerializable()
@DataRepository([JsonServerAdapter])
class Duty extends DataModel<Duty> {
  @override
  final String? id;
  final DateTime? date_from;
   final DateTime? date_until;
  final String? status;
   final String? fio;

  Duty({this.id, this.date_from,this.date_until, this.status, this.fio});

}
mixin JsonServerAdapter<T extends DataModel<T>> on RemoteAdapter<T> {
 
  @override
  String urlForSave(id, Map<String, dynamic> params) => "entities/Duty" ;

  @override
  FutureOr<Map<String, dynamic>> get defaultParams => 
  {'username': company.value +"|"+ user.value};
  @override
  String urlForFindAll(Map<String, dynamic> params) => 
  'services/flutterService/loadDuties';
  @override
  String get baseUrl => '${site}rest/';
  
  @override
   FutureOr<Map<String, String>> get defaultHeaders async {
     return await super.defaultHeaders..addAll({'Authorization': 'Bearer ${token.value}'});
   }


 
}
