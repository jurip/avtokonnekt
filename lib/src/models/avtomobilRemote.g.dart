// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avtomobilRemote.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $AvtomobilRemoteLocalAdapter on LocalAdapter<AvtomobilRemote> {
  static final Map<String, RelationshipMeta>
      _kAvtomobilRemoteRelationshipMetas = {
    'zayavka': RelationshipMeta<ZayavkaRemote>(
      name: 'zayavka',
      inverseName: 'avtomobili',
      type: 'zayavkaRemotes',
      kind: 'BelongsTo',
      instance: (_) => (_ as AvtomobilRemote).zayavka,
    ),
    'fotos': RelationshipMeta<Foto>(
      name: 'fotos',
      inverseName: 'avtomobil',
      type: 'fotos',
      kind: 'HasMany',
      instance: (_) => (_ as AvtomobilRemote).fotos,
    ),
    'performance_service': RelationshipMeta<Usluga>(
      name: 'performance_service',
      inverseName: 'avtomobil',
      type: 'uslugas',
      kind: 'HasMany',
      instance: (_) => (_ as AvtomobilRemote).performance_service,
    ),
    'barcode': RelationshipMeta<Oborudovanie>(
      name: 'barcode',
      inverseName: 'avtomobil',
      type: 'oborudovanies',
      kind: 'HasMany',
      instance: (_) => (_ as AvtomobilRemote).barcode,
    ),
    'oborudovanieFotos': RelationshipMeta<OborudovanieFoto>(
      name: 'oborudovanieFotos',
      inverseName: 'avtomobil',
      type: 'oborudovanieFotos',
      kind: 'HasMany',
      instance: (_) => (_ as AvtomobilRemote).oborudovanieFotos,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kAvtomobilRemoteRelationshipMetas;

  @override
  AvtomobilRemote deserialize(map) {
    map = transformDeserialize(map);
    return _$AvtomobilRemoteFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$AvtomobilRemoteToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _avtomobilRemotesFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $AvtomobilRemoteHiveLocalAdapter = HiveLocalAdapter<AvtomobilRemote>
    with $AvtomobilRemoteLocalAdapter;

class $AvtomobilRemoteRemoteAdapter = RemoteAdapter<AvtomobilRemote>
    with JsonServerAdapter<AvtomobilRemote>;

final internalAvtomobilRemotesRemoteAdapterProvider =
    Provider<RemoteAdapter<AvtomobilRemote>>((ref) =>
        $AvtomobilRemoteRemoteAdapter($AvtomobilRemoteHiveLocalAdapter(ref),
            InternalHolder(_avtomobilRemotesFinders)));

final avtomobilRemotesRepositoryProvider =
    Provider<Repository<AvtomobilRemote>>(
        (ref) => Repository<AvtomobilRemote>(ref));

extension AvtomobilRemoteDataRepositoryX on Repository<AvtomobilRemote> {
  JsonServerAdapter<AvtomobilRemote> get jsonServerAdapter =>
      remoteAdapter as JsonServerAdapter<AvtomobilRemote>;
}

extension AvtomobilRemoteRelationshipGraphNodeX
    on RelationshipGraphNode<AvtomobilRemote> {
  RelationshipGraphNode<ZayavkaRemote> get zayavka {
    final meta = $AvtomobilRemoteLocalAdapter
            ._kAvtomobilRemoteRelationshipMetas['zayavka']
        as RelationshipMeta<ZayavkaRemote>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }

  RelationshipGraphNode<Foto> get fotos {
    final meta = $AvtomobilRemoteLocalAdapter
        ._kAvtomobilRemoteRelationshipMetas['fotos'] as RelationshipMeta<Foto>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }

  RelationshipGraphNode<Usluga> get performance_service {
    final meta = $AvtomobilRemoteLocalAdapter
            ._kAvtomobilRemoteRelationshipMetas['performance_service']
        as RelationshipMeta<Usluga>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }

  RelationshipGraphNode<Oborudovanie> get barcode {
    final meta = $AvtomobilRemoteLocalAdapter
            ._kAvtomobilRemoteRelationshipMetas['barcode']
        as RelationshipMeta<Oborudovanie>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }

  RelationshipGraphNode<OborudovanieFoto> get oborudovanieFotos {
    final meta = $AvtomobilRemoteLocalAdapter
            ._kAvtomobilRemoteRelationshipMetas['oborudovanieFotos']
        as RelationshipMeta<OborudovanieFoto>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvtomobilRemote _$AvtomobilRemoteFromJson(Map<String, dynamic> json) =>
    AvtomobilRemote(
      id: json['id'] as String?,
      nomer: json['nomer'] as String?,
      marka: json['marka'] as String?,
      nomerAG: json['nomerAG'] as String?,
      status: json['status'] as String?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      zayavka: json['zayavka'] == null
          ? null
          : BelongsTo<ZayavkaRemote>.fromJson(
              json['zayavka'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AvtomobilRemoteToJson(AvtomobilRemote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nomer': instance.nomer,
      'marka': instance.marka,
      'nomerAG': instance.nomerAG,
      'date': instance.date?.toIso8601String(),
      'zayavka': instance.zayavka,
      'status': instance.status,
    };
