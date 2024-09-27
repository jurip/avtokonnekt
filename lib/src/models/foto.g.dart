// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foto.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $FotoLocalAdapter on LocalAdapter<Foto> {
  static final Map<String, RelationshipMeta> _kFotoRelationshipMetas = {
    'avtomobil': RelationshipMeta<AvtomobilRemote>(
      name: 'avtomobil',
      inverseName: 'fotos',
      type: 'avtomobilRemotes',
      kind: 'BelongsTo',
      instance: (_) => (_ as Foto).avtomobil,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kFotoRelationshipMetas;

  @override
  Foto deserialize(map) {
    map = transformDeserialize(map);
    return _$FotoFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$FotoToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _fotosFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $FotoHiveLocalAdapter = HiveLocalAdapter<Foto> with $FotoLocalAdapter;

class $FotoRemoteAdapter = RemoteAdapter<Foto> with NothingMixin;

final internalFotosRemoteAdapterProvider = Provider<RemoteAdapter<Foto>>(
    (ref) => $FotoRemoteAdapter(
        $FotoHiveLocalAdapter(ref), InternalHolder(_fotosFinders)));

final fotosRepositoryProvider =
    Provider<Repository<Foto>>((ref) => Repository<Foto>(ref));

extension FotoDataRepositoryX on Repository<Foto> {}

extension FotoRelationshipGraphNodeX on RelationshipGraphNode<Foto> {
  RelationshipGraphNode<AvtomobilRemote> get avtomobil {
    final meta = $FotoLocalAdapter._kFotoRelationshipMetas['avtomobil']
        as RelationshipMeta<AvtomobilRemote>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Foto _$FotoFromJson(Map<String, dynamic> json) => Foto(
      id: json['id'],
      file: json['file'] as String?,
      fileLocal: json['fileLocal'] as String?,
      avtomobil: BelongsTo<AvtomobilRemote>.fromJson(
          json['avtomobil'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FotoToJson(Foto instance) => <String, dynamic>{
      'id': instance.id,
      'file': instance.file,
      'fileLocal': instance.fileLocal,
      'avtomobil': instance.avtomobil,
    };
