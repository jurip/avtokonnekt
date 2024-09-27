// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oborudovanieFoto.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $OborudovanieFotoLocalAdapter on LocalAdapter<OborudovanieFoto> {
  static final Map<String, RelationshipMeta>
      _kOborudovanieFotoRelationshipMetas = {
    'avtomobil': RelationshipMeta<AvtomobilRemote>(
      name: 'avtomobil',
      inverseName: 'oborudovanieFotos',
      type: 'avtomobilRemotes',
      kind: 'BelongsTo',
      instance: (_) => (_ as OborudovanieFoto).avtomobil,
    )
  };

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kOborudovanieFotoRelationshipMetas;

  @override
  OborudovanieFoto deserialize(map) {
    map = transformDeserialize(map);
    return _$OborudovanieFotoFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$OborudovanieFotoToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _oborudovanieFotosFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $OborudovanieFotoHiveLocalAdapter = HiveLocalAdapter<OborudovanieFoto>
    with $OborudovanieFotoLocalAdapter;

class $OborudovanieFotoRemoteAdapter = RemoteAdapter<OborudovanieFoto>
    with NothingMixin;

final internalOborudovanieFotosRemoteAdapterProvider =
    Provider<RemoteAdapter<OborudovanieFoto>>((ref) =>
        $OborudovanieFotoRemoteAdapter($OborudovanieFotoHiveLocalAdapter(ref),
            InternalHolder(_oborudovanieFotosFinders)));

final oborudovanieFotosRepositoryProvider =
    Provider<Repository<OborudovanieFoto>>(
        (ref) => Repository<OborudovanieFoto>(ref));

extension OborudovanieFotoDataRepositoryX on Repository<OborudovanieFoto> {}

extension OborudovanieFotoRelationshipGraphNodeX
    on RelationshipGraphNode<OborudovanieFoto> {
  RelationshipGraphNode<AvtomobilRemote> get avtomobil {
    final meta = $OborudovanieFotoLocalAdapter
            ._kOborudovanieFotoRelationshipMetas['avtomobil']
        as RelationshipMeta<AvtomobilRemote>;
    return meta.clone(
        parent: this is RelationshipMeta ? this as RelationshipMeta : null);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OborudovanieFoto _$OborudovanieFotoFromJson(Map<String, dynamic> json) =>
    OborudovanieFoto(
      id: json['id'],
      file: json['file'] as String?,
      fileLocal: json['fileLocal'] as String?,
      avtomobil: BelongsTo<AvtomobilRemote>.fromJson(
          json['avtomobil'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OborudovanieFotoToJson(OborudovanieFoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'file': instance.file,
      'fileLocal': instance.fileLocal,
      'avtomobil': instance.avtomobil,
    };
