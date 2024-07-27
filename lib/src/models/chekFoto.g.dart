// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chekFoto.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $ChekFotoLocalAdapter on LocalAdapter<ChekFoto> {
  static final Map<String, RelationshipMeta> _kChekFotoRelationshipMetas = {
    'chek': RelationshipMeta<Chek>(
      name: 'chek',
      inverseName: 'fotos',
      type: 'cheks',
      kind: 'BelongsTo',
      instance: (_) => (_ as ChekFoto).chek,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kChekFotoRelationshipMetas;

  @override
  ChekFoto deserialize(map) {
    map = transformDeserialize(map);
    return _$ChekFotoFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$ChekFotoToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _chekFotosFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $ChekFotoHiveLocalAdapter = HiveLocalAdapter<ChekFoto>
    with $ChekFotoLocalAdapter;

class $ChekFotoRemoteAdapter = RemoteAdapter<ChekFoto> with NothingMixin;

final internalChekFotosRemoteAdapterProvider =
    Provider<RemoteAdapter<ChekFoto>>((ref) => $ChekFotoRemoteAdapter(
        $ChekFotoHiveLocalAdapter(ref), InternalHolder(_chekFotosFinders)));

final chekFotosRepositoryProvider =
    Provider<Repository<ChekFoto>>((ref) => Repository<ChekFoto>(ref));

extension ChekFotoDataRepositoryX on Repository<ChekFoto> {}

extension ChekFotoRelationshipGraphNodeX on RelationshipGraphNode<ChekFoto> {
  RelationshipGraphNode<Chek> get chek {
    final meta = $ChekFotoLocalAdapter._kChekFotoRelationshipMetas['chek']
        as RelationshipMeta<Chek>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChekFoto _$ChekFotoFromJson(Map<String, dynamic> json) => ChekFoto(
      id: json['id'] as String?,
      file: json['file'] as String?,
      fileLocal: json['fileLocal'] as String?,
      chek: BelongsTo<Chek>.fromJson(json['chek'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChekFotoToJson(ChekFoto instance) => <String, dynamic>{
      'id': instance.id,
      'file': instance.file,
      'fileLocal': instance.fileLocal,
      'chek': instance.chek,
    };
