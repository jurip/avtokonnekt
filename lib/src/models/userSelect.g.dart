// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userSelect.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $UserSelectLocalAdapter on LocalAdapter<UserSelect> {
  static final Map<String, RelationshipMeta> _kUserSelectRelationshipMetas = {};

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kUserSelectRelationshipMetas;

  @override
  UserSelect deserialize(map) {
    map = transformDeserialize(map);
    return _$UserSelectFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$UserSelectToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _userSelectsFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $UserSelectHiveLocalAdapter = HiveLocalAdapter<UserSelect>
    with $UserSelectLocalAdapter;

class $UserSelectRemoteAdapter = RemoteAdapter<UserSelect>
    with JsonServerAdapter<UserSelect>;

final internalUserSelectsRemoteAdapterProvider =
    Provider<RemoteAdapter<UserSelect>>((ref) => $UserSelectRemoteAdapter(
        $UserSelectHiveLocalAdapter(ref), InternalHolder(_userSelectsFinders)));

final userSelectsRepositoryProvider =
    Provider<Repository<UserSelect>>((ref) => Repository<UserSelect>(ref));

extension UserSelectDataRepositoryX on Repository<UserSelect> {
  JsonServerAdapter<UserSelect> get jsonServerAdapter =>
      remoteAdapter as JsonServerAdapter<UserSelect>;
}

extension UserSelectRelationshipGraphNodeX
    on RelationshipGraphNode<UserSelect> {}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSelect _$UserSelectFromJson(Map<String, dynamic> json) => UserSelect(
      id: json['id'] as String?,
      username: json['username'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );

Map<String, dynamic> _$UserSelectToJson(UserSelect instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
    };
