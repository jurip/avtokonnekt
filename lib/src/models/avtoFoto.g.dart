// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avtoFoto.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $AvtoFotoLocalAdapter on LocalAdapter<AvtoFoto> {
  static final Map<String, RelationshipMeta> _kAvtoFotoRelationshipMetas = {
    'avtomobil': RelationshipMeta<AvtomobilRemote>(
      name: 'avtomobil',
      inverseName: 'avtoFoto',
      type: 'avtomobilRemotes',
      kind: 'BelongsTo',
      instance: (_) => (_ as AvtoFoto).avtomobil,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kAvtoFotoRelationshipMetas;

  @override
  AvtoFoto deserialize(map) {
    map = transformDeserialize(map);
    return _$AvtoFotoFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$AvtoFotoToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _avtoFotosFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $AvtoFotoHiveLocalAdapter = HiveLocalAdapter<AvtoFoto>
    with $AvtoFotoLocalAdapter;

class $AvtoFotoRemoteAdapter = RemoteAdapter<AvtoFoto> with NothingMixin;

final internalAvtoFotosRemoteAdapterProvider =
    Provider<RemoteAdapter<AvtoFoto>>((ref) => $AvtoFotoRemoteAdapter(
        $AvtoFotoHiveLocalAdapter(ref), InternalHolder(_avtoFotosFinders)));

final avtoFotosRepositoryProvider =
    Provider<Repository<AvtoFoto>>((ref) => Repository<AvtoFoto>(ref));

extension AvtoFotoDataRepositoryX on Repository<AvtoFoto> {}

extension AvtoFotoRelationshipGraphNodeX on RelationshipGraphNode<AvtoFoto> {
  RelationshipGraphNode<AvtomobilRemote> get avtomobil {
    final meta = $AvtoFotoLocalAdapter._kAvtoFotoRelationshipMetas['avtomobil']
        as RelationshipMeta<AvtomobilRemote>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvtoFoto _$AvtoFotoFromJson(Map<String, dynamic> json) => AvtoFoto(
      id: json['id'],
      file: json['file'] as String?,
      fileLocal: json['fileLocal'] as String?,
      avtomobil: BelongsTo<AvtomobilRemote>.fromJson(
          json['avtomobil'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AvtoFotoToJson(AvtoFoto instance) => <String, dynamic>{
      'id': instance.id,
      'file': instance.file,
      'fileLocal': instance.fileLocal,
      'avtomobil': instance.avtomobil,
    };
