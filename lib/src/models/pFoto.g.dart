// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pFoto.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $PFotoLocalAdapter on LocalAdapter<PFoto> {
  static final Map<String, RelationshipMeta> _kPFotoRelationshipMetas = {
    'peremeshenie': RelationshipMeta<PeremesheniyeOborudovaniya>(
      name: 'peremeshenie',
      inverseName: 'fotos',
      type: 'peremesheniyeOborudovaniyas',
      kind: 'BelongsTo',
      instance: (_) => (_ as PFoto).peremeshenie,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kPFotoRelationshipMetas;

  @override
  PFoto deserialize(map) {
    map = transformDeserialize(map);
    return _$PFotoFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$PFotoToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _pFotosFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $PFotoHiveLocalAdapter = HiveLocalAdapter<PFoto> with $PFotoLocalAdapter;

class $PFotoRemoteAdapter = RemoteAdapter<PFoto> with NothingMixin;

final internalPFotosRemoteAdapterProvider = Provider<RemoteAdapter<PFoto>>(
    (ref) => $PFotoRemoteAdapter(
        $PFotoHiveLocalAdapter(ref), InternalHolder(_pFotosFinders)));

final pFotosRepositoryProvider =
    Provider<Repository<PFoto>>((ref) => Repository<PFoto>(ref));

extension PFotoDataRepositoryX on Repository<PFoto> {}

extension PFotoRelationshipGraphNodeX on RelationshipGraphNode<PFoto> {
  RelationshipGraphNode<PeremesheniyeOborudovaniya> get peremeshenie {
    final meta = $PFotoLocalAdapter._kPFotoRelationshipMetas['peremeshenie']
        as RelationshipMeta<PeremesheniyeOborudovaniya>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PFoto _$PFotoFromJson(Map<String, dynamic> json) => PFoto(
      id: json['id'],
      file: json['file'] as String?,
      fileLocal: json['fileLocal'] as String?,
      peremeshenie: BelongsTo<PeremesheniyeOborudovaniya>.fromJson(
          json['peremeshenie'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PFotoToJson(PFoto instance) => <String, dynamic>{
      'id': instance.id,
      'file': instance.file,
      'fileLocal': instance.fileLocal,
      'peremeshenie': instance.peremeshenie,
    };
