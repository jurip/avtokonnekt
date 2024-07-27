// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendarEvent.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $CalendarEventLocalAdapter on LocalAdapter<CalendarEvent> {
  static final Map<String, RelationshipMeta> _kCalendarEventRelationshipMetas =
      {
    'zayavka': RelationshipMeta<ZayavkaRemote>(
      name: 'zayavka',
      inverseName: 'events',
      type: 'zayavkaRemotes',
      kind: 'BelongsTo',
      instance: (_) => (_ as CalendarEvent).zayavka,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kCalendarEventRelationshipMetas;

  @override
  CalendarEvent deserialize(map) {
    map = transformDeserialize(map);
    return _$CalendarEventFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$CalendarEventToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _calendarEventsFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $CalendarEventHiveLocalAdapter = HiveLocalAdapter<CalendarEvent>
    with $CalendarEventLocalAdapter;

class $CalendarEventRemoteAdapter = RemoteAdapter<CalendarEvent>
    with NothingMixin;

final internalCalendarEventsRemoteAdapterProvider =
    Provider<RemoteAdapter<CalendarEvent>>((ref) => $CalendarEventRemoteAdapter(
        $CalendarEventHiveLocalAdapter(ref),
        InternalHolder(_calendarEventsFinders)));

final calendarEventsRepositoryProvider = Provider<Repository<CalendarEvent>>(
    (ref) => Repository<CalendarEvent>(ref));

extension CalendarEventDataRepositoryX on Repository<CalendarEvent> {}

extension CalendarEventRelationshipGraphNodeX
    on RelationshipGraphNode<CalendarEvent> {
  RelationshipGraphNode<ZayavkaRemote> get zayavka {
    final meta =
        $CalendarEventLocalAdapter._kCalendarEventRelationshipMetas['zayavka']
            as RelationshipMeta<ZayavkaRemote>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEvent _$CalendarEventFromJson(Map<String, dynamic> json) =>
    CalendarEvent(
      id: json['id'] as String?,
      zayavka: BelongsTo<ZayavkaRemote>.fromJson(
          json['zayavka'] as Map<String, dynamic>),
      calId: json['calId'] as String,
    );

Map<String, dynamic> _$CalendarEventToJson(CalendarEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'calId': instance.calId,
      'zayavka': instance.zayavka,
    };
