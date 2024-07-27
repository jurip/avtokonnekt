// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oborudovanie.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $OborudovanieLocalAdapter on LocalAdapter<Oborudovanie> {
  static final Map<String, RelationshipMeta> _kOborudovanieRelationshipMetas = {
    'avtomobil': RelationshipMeta<AvtomobilRemote>(
      name: 'avtomobil',
      inverseName: 'barcode',
      type: 'avtomobilRemotes',
      kind: 'BelongsTo',
      instance: (_) => (_ as Oborudovanie).avtomobil,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kOborudovanieRelationshipMetas;

  @override
  Oborudovanie deserialize(map) {
    map = transformDeserialize(map);
    return _$OborudovanieFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$OborudovanieToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _oborudovaniesFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $OborudovanieHiveLocalAdapter = HiveLocalAdapter<Oborudovanie>
    with $OborudovanieLocalAdapter;

class $OborudovanieRemoteAdapter = RemoteAdapter<Oborudovanie>
    with NothingMixin;

final internalOborudovaniesRemoteAdapterProvider =
    Provider<RemoteAdapter<Oborudovanie>>((ref) => $OborudovanieRemoteAdapter(
        $OborudovanieHiveLocalAdapter(ref),
        InternalHolder(_oborudovaniesFinders)));

final oborudovaniesRepositoryProvider =
    Provider<Repository<Oborudovanie>>((ref) => Repository<Oborudovanie>(ref));

extension OborudovanieDataRepositoryX on Repository<Oborudovanie> {}

extension OborudovanieRelationshipGraphNodeX
    on RelationshipGraphNode<Oborudovanie> {
  RelationshipGraphNode<AvtomobilRemote> get avtomobil {
    final meta =
        $OborudovanieLocalAdapter._kOborudovanieRelationshipMetas['avtomobil']
            as RelationshipMeta<AvtomobilRemote>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Oborudovanie _$OborudovanieFromJson(Map<String, dynamic> json) => Oborudovanie(
      id: json['id'] as String?,
      code: json['code'] as String?,
      avtomobil: BelongsTo<AvtomobilRemote>.fromJson(
          json['avtomobil'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OborudovanieToJson(Oborudovanie instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'avtomobil': instance.avtomobil,
    };
