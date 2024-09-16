import 'dart:async';
import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/main.dart';
import 'package:fluttsec/src/models/calendarEvent.dart';
import 'package:fluttsec/src/models/avtomobilRemote.dart';
import 'package:json_annotation/json_annotation.dart';
part 'zayavkaRemote.g.dart';

@JsonSerializable()
@DataRepository([JsonServerAdapter])
class ZayavkaRemote extends DataModel<ZayavkaRemote> {
  @override
  final String? id;
  final String? nomer;
  final DateTime? nachalo;
  final DateTime? end_date_time;
  final String? client;
  final String? adres;
  final String? contact_name;
  final String? contact_number;
  final String? message;
  final String? comment_address;
  final String? manager_name;
  final String? manager_number;
  final String? service;
  final String? lat;
  final String? lng;
 String? status;
  final HasMany<AvtomobilRemote>? avtomobili;
  final HasMany<CalendarEvent> events = HasMany<CalendarEvent>();

   ZayavkaRemote({this.avtomobili, this.id, this.nomer ,this.nachalo, this.client, this.adres, this.contact_name,
     this.contact_number, this.end_date_time, this.message, this.service,
       this.comment_address, this.manager_name, this.manager_number, this.lat, this.lng, this.status});

}
mixin JsonServerAdapter<T extends DataModel<T>> on RemoteAdapter<T> {
 
  @override
  String urlForSave(id, Map<String, dynamic> params) => "entities/Zayavka";

  @override
  FutureOr<Map<String, dynamic>> get defaultParams => 
  {'username': user.value};
  @override
  String urlForFindAll(Map<String, dynamic> params) => 
  'services/flutterService/getAllReadyZayavkas';
  @override
  String get baseUrl => '${site}rest/';
  
  @override
   FutureOr<Map<String, String>> get defaultHeaders async {
     return await super.defaultHeaders..addAll({'Authorization': 'Bearer ${token.value}'});
   }


 
}