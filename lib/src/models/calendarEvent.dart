
import 'package:flutter_data/flutter_data.dart';
import 'package:fluttsec/src/models/zayavkaRemote.dart';
import 'package:json_annotation/json_annotation.dart';
part 'calendarEvent.g.dart';

@JsonSerializable()
@DataRepository([])
class CalendarEvent extends DataModel<CalendarEvent> {
  @override
  final String? id;
  final String calId;
  final BelongsTo<ZayavkaRemote> zayavka;


  CalendarEvent( {this.id, required this.zayavka, required this.calId});

}
