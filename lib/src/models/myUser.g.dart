// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myUser.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $MyUserLocalAdapter on LocalAdapter<MyUser> {
  static final Map<String, RelationshipMeta> _kMyUserRelationshipMetas = {};

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kMyUserRelationshipMetas;

  @override
  MyUser deserialize(map) {
    map = transformDeserialize(map);
    return _$MyUserFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$MyUserToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _myUsersFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $MyUserHiveLocalAdapter = HiveLocalAdapter<MyUser>
    with $MyUserLocalAdapter;

class $MyUserRemoteAdapter = RemoteAdapter<MyUser> with NothingMixin;

final internalMyUsersRemoteAdapterProvider = Provider<RemoteAdapter<MyUser>>(
    (ref) => $MyUserRemoteAdapter(
        $MyUserHiveLocalAdapter(ref), InternalHolder(_myUsersFinders)));

final myUsersRepositoryProvider =
    Provider<Repository<MyUser>>((ref) => Repository<MyUser>(ref));

extension MyUserDataRepositoryX on Repository<MyUser> {}

extension MyUserRelationshipGraphNodeX on RelationshipGraphNode<MyUser> {}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyUser _$MyUserFromJson(Map<String, dynamic> json) => MyUser(
      json['id'] as String?,
      username: json['username'] as String,
    );

Map<String, dynamic> _$MyUserToJson(MyUser instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
    };
