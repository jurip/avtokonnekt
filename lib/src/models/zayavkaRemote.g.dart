// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zayavkaRemote.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $ZayavkaRemoteLocalAdapter on LocalAdapter<ZayavkaRemote> {
  static final Map<String, RelationshipMeta> _kZayavkaRemoteRelationshipMetas =
      {
    'avtomobili': RelationshipMeta<AvtomobilRemote>(
      name: 'avtomobili',
      inverseName: 'zayavka',
      type: 'avtomobilRemotes',
      kind: 'HasMany',
      instance: (_) => (_ as ZayavkaRemote).avtomobili,
    ),
    'events': RelationshipMeta<CalendarEvent>(
      name: 'events',
      inverseName: 'zayavka',
      type: 'calendarEvents',
      kind: 'HasMany',
      instance: (_) => (_ as ZayavkaRemote).events,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kZayavkaRemoteRelationshipMetas;

  @override
  ZayavkaRemote deserialize(map) {
    map = transformDeserialize(map);
    return _$ZayavkaRemoteFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$ZayavkaRemoteToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _zayavkaRemotesFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $ZayavkaRemoteHiveLocalAdapter = HiveLocalAdapter<ZayavkaRemote>
    with $ZayavkaRemoteLocalAdapter;

class $ZayavkaRemoteRemoteAdapter = RemoteAdapter<ZayavkaRemote>
    with JsonServerAdapter<ZayavkaRemote>;

final internalZayavkaRemotesRemoteAdapterProvider =
    Provider<RemoteAdapter<ZayavkaRemote>>((ref) => $ZayavkaRemoteRemoteAdapter(
        $ZayavkaRemoteHiveLocalAdapter(ref),
        InternalHolder(_zayavkaRemotesFinders)));

final zayavkaRemotesRepositoryProvider = Provider<Repository<ZayavkaRemote>>(
    (ref) => Repository<ZayavkaRemote>(ref));

extension ZayavkaRemoteDataRepositoryX on Repository<ZayavkaRemote> {
  JsonServerAdapter<ZayavkaRemote> get jsonServerAdapter =>
      remoteAdapter as JsonServerAdapter<ZayavkaRemote>;
}

extension ZayavkaRemoteRelationshipGraphNodeX
    on RelationshipGraphNode<ZayavkaRemote> {
  RelationshipGraphNode<AvtomobilRemote> get avtomobili {
    final meta = $ZayavkaRemoteLocalAdapter
            ._kZayavkaRemoteRelationshipMetas['avtomobili']
        as RelationshipMeta<AvtomobilRemote>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }

  RelationshipGraphNode<CalendarEvent> get events {
    final meta =
        $ZayavkaRemoteLocalAdapter._kZayavkaRemoteRelationshipMetas['events']
            as RelationshipMeta<CalendarEvent>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZayavkaRemote _$ZayavkaRemoteFromJson(Map<String, dynamic> json) =>
    ZayavkaRemote(
      json['id'] as String?,
      nomer: json['nomer'] as String?,
      nachalo: json['nachalo'] == null
          ? null
          : DateTime.parse(json['nachalo'] as String),
      client: json['client'] as String?,
      adres: json['adres'] as String?,
      contact_name: json['contact_name'] as String?,
      contact_number: json['contact_number'] as String?,
      end_date_time: json['end_date_time'] == null
          ? null
          : DateTime.parse(json['end_date_time'] as String),
      message: json['message'] as String?,
      service: json['service'] as String?,
      avtomobili: HasMany<AvtomobilRemote>.fromJson(
          json['avtomobili'] as Map<String, dynamic>),
      events: HasMany<CalendarEvent>.fromJson(
          json['events'] as Map<String, dynamic>),
      comment_address: json['comment_address'] as String?,
      manager_name: json['manager_name'] as String?,
      manager_number: json['manager_number'] as String?,
    );

Map<String, dynamic> _$ZayavkaRemoteToJson(ZayavkaRemote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nomer': instance.nomer,
      'nachalo': instance.nachalo?.toIso8601String(),
      'end_date_time': instance.end_date_time?.toIso8601String(),
      'client': instance.client,
      'adres': instance.adres,
      'contact_name': instance.contact_name,
      'contact_number': instance.contact_number,
      'message': instance.message,
      'comment_address': instance.comment_address,
      'manager_name': instance.manager_name,
      'manager_number': instance.manager_number,
      'service': instance.service,
      'avtomobili': instance.avtomobili,
      'events': instance.events,
    };
