// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duty.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $DutyLocalAdapter on LocalAdapter<Duty> {
  static final Map<String, RelationshipMeta> _kDutyRelationshipMetas = {};

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kDutyRelationshipMetas;

  @override
  Duty deserialize(map) {
    map = transformDeserialize(map);
    return _$DutyFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$DutyToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _dutiesFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $DutyHiveLocalAdapter = HiveLocalAdapter<Duty> with $DutyLocalAdapter;

class $DutyRemoteAdapter = RemoteAdapter<Duty> with JsonServerAdapter<Duty>;

final internalDutiesRemoteAdapterProvider = Provider<RemoteAdapter<Duty>>(
    (ref) => $DutyRemoteAdapter(
        $DutyHiveLocalAdapter(ref), InternalHolder(_dutiesFinders)));

final dutiesRepositoryProvider =
    Provider<Repository<Duty>>((ref) => Repository<Duty>(ref));

extension DutyDataRepositoryX on Repository<Duty> {
  JsonServerAdapter<Duty> get jsonServerAdapter =>
      remoteAdapter as JsonServerAdapter<Duty>;
}

extension DutyRelationshipGraphNodeX on RelationshipGraphNode<Duty> {}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Duty _$DutyFromJson(Map<String, dynamic> json) => Duty(
      id: json['id'] as String?,
      date_from: json['date_from'] == null
          ? null
          : DateTime.parse(json['date_from'] as String),
      date_until: json['date_until'] == null
          ? null
          : DateTime.parse(json['date_until'] as String),
      status: json['status'] as String?,
      fio: json['fio'] as String?,
    );

Map<String, dynamic> _$DutyToJson(Duty instance) => <String, dynamic>{
      'id': instance.id,
      'date_from': instance.date_from?.toIso8601String(),
      'date_until': instance.date_until?.toIso8601String(),
      'status': instance.status,
      'fio': instance.fio,
    };
