// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avtomobilLocal.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $AvtomobilLocalLocalAdapter on LocalAdapter<AvtomobilLocal> {
  static final Map<String, RelationshipMeta> _kAvtomobilLocalRelationshipMetas =
      {
    'zayavka': RelationshipMeta<ZayavkaRemote>(
      name: 'zayavka',
      type: 'zayavkaRemotes',
      kind: 'BelongsTo',
      instance: (_) => (_ as AvtomobilLocal).zayavka,
    ),
    'fotos': RelationshipMeta<Foto>(
      name: 'fotos',
      type: 'fotos',
      kind: 'HasMany',
      instance: (_) => (_ as AvtomobilLocal).fotos,
    ),
    'performance_service': RelationshipMeta<Usluga>(
      name: 'performance_service',
      type: 'uslugas',
      kind: 'HasMany',
      instance: (_) => (_ as AvtomobilLocal).performance_service,
    ),
    'barcode': RelationshipMeta<Oborudovanie>(
      name: 'barcode',
      type: 'oborudovanies',
      kind: 'HasMany',
      instance: (_) => (_ as AvtomobilLocal).barcode,
    ),
    'oborudovanieFotos': RelationshipMeta<OborudovanieFoto>(
      name: 'oborudovanieFotos',
      type: 'oborudovanieFotos',
      kind: 'HasMany',
      instance: (_) => (_ as AvtomobilLocal).oborudovanieFotos,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kAvtomobilLocalRelationshipMetas;

  @override
  AvtomobilLocal deserialize(map) {
    map = transformDeserialize(map);
    return _$AvtomobilLocalFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$AvtomobilLocalToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _avtomobilLocalsFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $AvtomobilLocalHiveLocalAdapter = HiveLocalAdapter<AvtomobilLocal>
    with $AvtomobilLocalLocalAdapter;

class $AvtomobilLocalRemoteAdapter = RemoteAdapter<AvtomobilLocal>
    with NothingMixin;

final internalAvtomobilLocalsRemoteAdapterProvider =
    Provider<RemoteAdapter<AvtomobilLocal>>((ref) =>
        $AvtomobilLocalRemoteAdapter($AvtomobilLocalHiveLocalAdapter(ref),
            InternalHolder(_avtomobilLocalsFinders)));

final avtomobilLocalsRepositoryProvider = Provider<Repository<AvtomobilLocal>>(
    (ref) => Repository<AvtomobilLocal>(ref));

extension AvtomobilLocalDataRepositoryX on Repository<AvtomobilLocal> {}

extension AvtomobilLocalRelationshipGraphNodeX
    on RelationshipGraphNode<AvtomobilLocal> {
  RelationshipGraphNode<ZayavkaRemote> get zayavka {
    final meta =
        $AvtomobilLocalLocalAdapter._kAvtomobilLocalRelationshipMetas['zayavka']
            as RelationshipMeta<ZayavkaRemote>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }

  RelationshipGraphNode<Foto> get fotos {
    final meta = $AvtomobilLocalLocalAdapter
        ._kAvtomobilLocalRelationshipMetas['fotos'] as RelationshipMeta<Foto>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }

  RelationshipGraphNode<Usluga> get performance_service {
    final meta = $AvtomobilLocalLocalAdapter
            ._kAvtomobilLocalRelationshipMetas['performance_service']
        as RelationshipMeta<Usluga>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }

  RelationshipGraphNode<Oborudovanie> get barcode {
    final meta =
        $AvtomobilLocalLocalAdapter._kAvtomobilLocalRelationshipMetas['barcode']
            as RelationshipMeta<Oborudovanie>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }

  RelationshipGraphNode<OborudovanieFoto> get oborudovanieFotos {
    final meta = $AvtomobilLocalLocalAdapter
            ._kAvtomobilLocalRelationshipMetas['oborudovanieFotos']
        as RelationshipMeta<OborudovanieFoto>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvtomobilLocal _$AvtomobilLocalFromJson(Map<String, dynamic> json) =>
    AvtomobilLocal(
      id: json['id'] as String?,
      nomer: json['nomer'] as String?,
      marka: json['marka'] as String?,
      nomerAG: json['nomerAG'] as String?,
      comment: json['comment'] as String?,
      status: json['status'] as String?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      zayavka: json['zayavka'] == null
          ? null
          : BelongsTo<ZayavkaRemote>.fromJson(
              json['zayavka'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AvtomobilLocalToJson(AvtomobilLocal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nomer': instance.nomer,
      'marka': instance.marka,
      'nomerAG': instance.nomerAG,
      'date': instance.date?.toIso8601String(),
      'comment': instance.comment,
      'zayavka': instance.zayavka,
      'status': instance.status,
    };
