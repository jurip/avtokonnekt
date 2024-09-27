// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peremeshenieOborudovaniya.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $PeremesheniyeOborudovaniyaLocalAdapter
    on LocalAdapter<PeremesheniyeOborudovaniya> {
  static final Map<String, RelationshipMeta>
      _kPeremesheniyeOborudovaniyaRelationshipMetas = {
    'fotos': RelationshipMeta<PFoto>(
      name: 'fotos',
      inverseName: 'peremeshenie',
      type: 'pFotos',
      kind: 'HasMany',
      instance: (_) => (_ as PeremesheniyeOborudovaniya).fotos,
    ),
    'barcode': RelationshipMeta<POborudovanie>(
      name: 'barcode',
      inverseName: 'peremeshenie',
      type: 'pOborudovanies',
      kind: 'HasMany',
      instance: (_) => (_ as PeremesheniyeOborudovaniya).barcode,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kPeremesheniyeOborudovaniyaRelationshipMetas;

  @override
  PeremesheniyeOborudovaniya deserialize(map) {
    map = transformDeserialize(map);
    return _$PeremesheniyeOborudovaniyaFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$PeremesheniyeOborudovaniyaToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _peremesheniyeOborudovaniyasFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $PeremesheniyeOborudovaniyaHiveLocalAdapter = HiveLocalAdapter<
    PeremesheniyeOborudovaniya> with $PeremesheniyeOborudovaniyaLocalAdapter;

class $PeremesheniyeOborudovaniyaRemoteAdapter = RemoteAdapter<
        PeremesheniyeOborudovaniya>
    with JsonServerAdapter<PeremesheniyeOborudovaniya>;

final internalPeremesheniyeOborudovaniyasRemoteAdapterProvider =
    Provider<RemoteAdapter<PeremesheniyeOborudovaniya>>((ref) =>
        $PeremesheniyeOborudovaniyaRemoteAdapter(
            $PeremesheniyeOborudovaniyaHiveLocalAdapter(ref),
            InternalHolder(_peremesheniyeOborudovaniyasFinders)));

final peremesheniyeOborudovaniyasRepositoryProvider =
    Provider<Repository<PeremesheniyeOborudovaniya>>(
        (ref) => Repository<PeremesheniyeOborudovaniya>(ref));

extension PeremesheniyeOborudovaniyaDataRepositoryX
    on Repository<PeremesheniyeOborudovaniya> {
  JsonServerAdapter<PeremesheniyeOborudovaniya> get jsonServerAdapter =>
      remoteAdapter as JsonServerAdapter<PeremesheniyeOborudovaniya>;
}

extension PeremesheniyeOborudovaniyaRelationshipGraphNodeX
    on RelationshipGraphNode<PeremesheniyeOborudovaniya> {
  RelationshipGraphNode<PFoto> get fotos {
    final meta = $PeremesheniyeOborudovaniyaLocalAdapter
            ._kPeremesheniyeOborudovaniyaRelationshipMetas['fotos']
        as RelationshipMeta<PFoto>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }

  RelationshipGraphNode<POborudovanie> get barcode {
    final meta = $PeremesheniyeOborudovaniyaLocalAdapter
            ._kPeremesheniyeOborudovaniyaRelationshipMetas['barcode']
        as RelationshipMeta<POborudovanie>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeremesheniyeOborudovaniya _$PeremesheniyeOborudovaniyaFromJson(
        Map<String, dynamic> json) =>
    PeremesheniyeOborudovaniya(
      id: json['id'] as String?,
      comment: json['comment'] as String?,
      status: json['status'] as String?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$PeremesheniyeOborudovaniyaToJson(
        PeremesheniyeOborudovaniya instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date?.toIso8601String(),
      'comment': instance.comment,
      'status': instance.status,
    };
