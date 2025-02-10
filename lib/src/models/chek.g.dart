// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chek.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $ChekLocalAdapter on LocalAdapter<Chek> {
  static final Map<String, RelationshipMeta> _kChekRelationshipMetas = {
    'fotos': RelationshipMeta<ChekFoto>(
      name: 'fotos',
      inverseName: 'chek',
      type: 'chekFotos',
      kind: 'HasMany',
      instance: (_) => (_ as Chek).fotos,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kChekRelationshipMetas;

  @override
  Chek deserialize(map) {
    map = transformDeserialize(map);
    return _$ChekFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$ChekToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _cheksFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $ChekHiveLocalAdapter = HiveLocalAdapter<Chek> with $ChekLocalAdapter;

class $ChekRemoteAdapter = RemoteAdapter<Chek> with NothingMixin;

final internalCheksRemoteAdapterProvider = Provider<RemoteAdapter<Chek>>(
    (ref) => $ChekRemoteAdapter(
        $ChekHiveLocalAdapter(ref), InternalHolder(_cheksFinders)));

final cheksRepositoryProvider =
    Provider<Repository<Chek>>((ref) => Repository<Chek>(ref));

extension ChekDataRepositoryX on Repository<Chek> {}

extension ChekRelationshipGraphNodeX on RelationshipGraphNode<Chek> {
  RelationshipGraphNode<ChekFoto> get fotos {
    final meta = $ChekLocalAdapter._kChekRelationshipMetas['fotos']
        as RelationshipMeta<ChekFoto>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chek _$ChekFromJson(Map<String, dynamic> json) => Chek(
      id: json['id'] as String?,
      comment: json['comment'] as String?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      username: json['username'] as String?,
      status: json['status'] as String? ?? "NOVAYA",
    )..qr = json['qr'] as String?;

Map<String, dynamic> _$ChekToJson(Chek instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'comment': instance.comment,
      'date': instance.date?.toIso8601String(),
      'status': instance.status,
      'qr': instance.qr,
    };
