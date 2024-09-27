// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'formaAvtomobilRemote.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $FormaAvtomobilRemoteLocalAdapter on LocalAdapter<FormaAvtomobilRemote> {
  static final Map<String, RelationshipMeta>
      _kFormaAvtomobilRemoteRelationshipMetas = {
    'zayavka': RelationshipMeta<ZayavkaRemote>(
      name: 'zayavka',
      type: 'zayavkaRemotes',
      kind: 'BelongsTo',
      instance: (_) => (_ as FormaAvtomobilRemote).zayavka,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kFormaAvtomobilRemoteRelationshipMetas;

  @override
  FormaAvtomobilRemote deserialize(map) {
    map = transformDeserialize(map);
    return _$FormaAvtomobilRemoteFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$FormaAvtomobilRemoteToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _formaAvtomobilRemotesFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $FormaAvtomobilRemoteHiveLocalAdapter = HiveLocalAdapter<
    FormaAvtomobilRemote> with $FormaAvtomobilRemoteLocalAdapter;

class $FormaAvtomobilRemoteRemoteAdapter = RemoteAdapter<FormaAvtomobilRemote>
    with JsonServerAdapter<FormaAvtomobilRemote>;

final internalFormaAvtomobilRemotesRemoteAdapterProvider =
    Provider<RemoteAdapter<FormaAvtomobilRemote>>((ref) =>
        $FormaAvtomobilRemoteRemoteAdapter(
            $FormaAvtomobilRemoteHiveLocalAdapter(ref),
            InternalHolder(_formaAvtomobilRemotesFinders)));

final formaAvtomobilRemotesRepositoryProvider =
    Provider<Repository<FormaAvtomobilRemote>>(
        (ref) => Repository<FormaAvtomobilRemote>(ref));

extension FormaAvtomobilRemoteDataRepositoryX
    on Repository<FormaAvtomobilRemote> {
  JsonServerAdapter<FormaAvtomobilRemote> get jsonServerAdapter =>
      remoteAdapter as JsonServerAdapter<FormaAvtomobilRemote>;
}

extension FormaAvtomobilRemoteRelationshipGraphNodeX
    on RelationshipGraphNode<FormaAvtomobilRemote> {
  RelationshipGraphNode<ZayavkaRemote> get zayavka {
    final meta = $FormaAvtomobilRemoteLocalAdapter
            ._kFormaAvtomobilRemoteRelationshipMetas['zayavka']
        as RelationshipMeta<ZayavkaRemote>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormaAvtomobilRemote _$FormaAvtomobilRemoteFromJson(
        Map<String, dynamic> json) =>
    FormaAvtomobilRemote(
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

Map<String, dynamic> _$FormaAvtomobilRemoteToJson(
        FormaAvtomobilRemote instance) =>
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
