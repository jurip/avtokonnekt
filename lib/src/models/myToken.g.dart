// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myToken.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $MyTokenLocalAdapter on LocalAdapter<MyToken> {
  static final Map<String, RelationshipMeta> _kMyTokenRelationshipMetas = {};

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kMyTokenRelationshipMetas;

  @override
  MyToken deserialize(map) {
    map = transformDeserialize(map);
    return _$MyTokenFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$MyTokenToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _myTokensFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $MyTokenHiveLocalAdapter = HiveLocalAdapter<MyToken>
    with $MyTokenLocalAdapter;

class $MyTokenRemoteAdapter = RemoteAdapter<MyToken> with NothingMixin;

final internalMyTokensRemoteAdapterProvider = Provider<RemoteAdapter<MyToken>>(
    (ref) => $MyTokenRemoteAdapter(
        $MyTokenHiveLocalAdapter(ref), InternalHolder(_myTokensFinders)));

final myTokensRepositoryProvider =
    Provider<Repository<MyToken>>((ref) => Repository<MyToken>(ref));

extension MyTokenDataRepositoryX on Repository<MyToken> {}

extension MyTokenRelationshipGraphNodeX on RelationshipGraphNode<MyToken> {}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyToken _$MyTokenFromJson(Map<String, dynamic> json) => MyToken(
      json['id'] as String?,
      nomer: json['nomer'] as String,
    );

Map<String, dynamic> _$MyTokenToJson(MyToken instance) => <String, dynamic>{
      'id': instance.id,
      'nomer': instance.nomer,
    };
