// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usluga.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $UslugaLocalAdapter on LocalAdapter<Usluga> {
  static final Map<String, RelationshipMeta> _kUslugaRelationshipMetas = {
    'avtomobil': RelationshipMeta<AvtomobilRemote>(
      name: 'avtomobil',
      inverseName: 'performance_service',
      type: 'avtomobilRemotes',
      kind: 'BelongsTo',
      instance: (_) => (_ as Usluga).avtomobil,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kUslugaRelationshipMetas;

  @override
  Usluga deserialize(map) {
    map = transformDeserialize(map);
    return _$UslugaFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$UslugaToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _uslugasFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $UslugaHiveLocalAdapter = HiveLocalAdapter<Usluga>
    with $UslugaLocalAdapter;

class $UslugaRemoteAdapter = RemoteAdapter<Usluga> with NothingMixin;

final internalUslugasRemoteAdapterProvider = Provider<RemoteAdapter<Usluga>>(
    (ref) => $UslugaRemoteAdapter(
        $UslugaHiveLocalAdapter(ref), InternalHolder(_uslugasFinders)));

final uslugasRepositoryProvider =
    Provider<Repository<Usluga>>((ref) => Repository<Usluga>(ref));

extension UslugaDataRepositoryX on Repository<Usluga> {}

extension UslugaRelationshipGraphNodeX on RelationshipGraphNode<Usluga> {
  RelationshipGraphNode<AvtomobilRemote> get avtomobil {
    final meta = $UslugaLocalAdapter._kUslugaRelationshipMetas['avtomobil']
        as RelationshipMeta<AvtomobilRemote>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usluga _$UslugaFromJson(Map<String, dynamic> json) => Usluga(
      id: json['id'] as String?,
      title: json['title'] as String?,
      avtomobil: BelongsTo<AvtomobilRemote>.fromJson(
          json['avtomobil'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UslugaToJson(Usluga instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'avtomobil': instance.avtomobil,
    };
