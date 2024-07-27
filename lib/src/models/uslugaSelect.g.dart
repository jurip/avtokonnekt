// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uslugaSelect.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $UslugaSelectLocalAdapter on LocalAdapter<UslugaSelect> {
  static final Map<String, RelationshipMeta> _kUslugaSelectRelationshipMetas =
      {};

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kUslugaSelectRelationshipMetas;

  @override
  UslugaSelect deserialize(map) {
    map = transformDeserialize(map);
    return _$UslugaSelectFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$UslugaSelectToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _uslugaSelectsFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $UslugaSelectHiveLocalAdapter = HiveLocalAdapter<UslugaSelect>
    with $UslugaSelectLocalAdapter;

class $UslugaSelectRemoteAdapter = RemoteAdapter<UslugaSelect>
    with JsonServerAdapter<UslugaSelect>;

final internalUslugaSelectsRemoteAdapterProvider =
    Provider<RemoteAdapter<UslugaSelect>>((ref) => $UslugaSelectRemoteAdapter(
        $UslugaSelectHiveLocalAdapter(ref),
        InternalHolder(_uslugaSelectsFinders)));

final uslugaSelectsRepositoryProvider =
    Provider<Repository<UslugaSelect>>((ref) => Repository<UslugaSelect>(ref));

extension UslugaSelectDataRepositoryX on Repository<UslugaSelect> {
  JsonServerAdapter<UslugaSelect> get jsonServerAdapter =>
      remoteAdapter as JsonServerAdapter<UslugaSelect>;
}

extension UslugaSelectRelationshipGraphNodeX
    on RelationshipGraphNode<UslugaSelect> {}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UslugaSelect _$UslugaSelectFromJson(Map<String, dynamic> json) => UslugaSelect(
      id: json['id'] as String?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$UslugaSelectToJson(UslugaSelect instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
    };
