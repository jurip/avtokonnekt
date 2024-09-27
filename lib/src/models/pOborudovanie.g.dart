// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pOborudovanie.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $POborudovanieLocalAdapter on LocalAdapter<POborudovanie> {
  static final Map<String, RelationshipMeta> _kPOborudovanieRelationshipMetas =
      {
    'peremeshenie': RelationshipMeta<PeremesheniyeOborudovaniya>(
      name: 'peremeshenie',
      inverseName: 'barcode',
      type: 'peremesheniyeOborudovaniyas',
      kind: 'BelongsTo',
      instance: (_) => (_ as POborudovanie).peremeshenie,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kPOborudovanieRelationshipMetas;

  @override
  POborudovanie deserialize(map) {
    map = transformDeserialize(map);
    return _$POborudovanieFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$POborudovanieToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _pOborudovaniesFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $POborudovanieHiveLocalAdapter = HiveLocalAdapter<POborudovanie>
    with $POborudovanieLocalAdapter;

class $POborudovanieRemoteAdapter = RemoteAdapter<POborudovanie>
    with NothingMixin;

final internalPOborudovaniesRemoteAdapterProvider =
    Provider<RemoteAdapter<POborudovanie>>((ref) => $POborudovanieRemoteAdapter(
        $POborudovanieHiveLocalAdapter(ref),
        InternalHolder(_pOborudovaniesFinders)));

final pOborudovaniesRepositoryProvider = Provider<Repository<POborudovanie>>(
    (ref) => Repository<POborudovanie>(ref));

extension POborudovanieDataRepositoryX on Repository<POborudovanie> {}

extension POborudovanieRelationshipGraphNodeX
    on RelationshipGraphNode<POborudovanie> {
  RelationshipGraphNode<PeremesheniyeOborudovaniya> get peremeshenie {
    final meta = $POborudovanieLocalAdapter
            ._kPOborudovanieRelationshipMetas['peremeshenie']
        as RelationshipMeta<PeremesheniyeOborudovaniya>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

POborudovanie _$POborudovanieFromJson(Map<String, dynamic> json) =>
    POborudovanie(
      id: json['id'],
      code: json['code'] as String?,
      peremeshenie: BelongsTo<PeremesheniyeOborudovaniya>.fromJson(
          json['peremeshenie'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$POborudovanieToJson(POborudovanie instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'peremeshenie': instance.peremeshenie,
    };
