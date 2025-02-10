// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currentUser.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $CurrentUserLocalAdapter on LocalAdapter<CurrentUser> {
  static final Map<String, RelationshipMeta> _kCurrentUserRelationshipMetas =
      {};

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kCurrentUserRelationshipMetas;

  @override
  CurrentUser deserialize(map) {
    map = transformDeserialize(map);
    return _$CurrentUserFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$CurrentUserToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _currentUsersFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $CurrentUserHiveLocalAdapter = HiveLocalAdapter<CurrentUser>
    with $CurrentUserLocalAdapter;

class $CurrentUserRemoteAdapter = RemoteAdapter<CurrentUser>
    with JsonServerAdapter<CurrentUser>;

final internalCurrentUsersRemoteAdapterProvider =
    Provider<RemoteAdapter<CurrentUser>>((ref) => $CurrentUserRemoteAdapter(
        $CurrentUserHiveLocalAdapter(ref),
        InternalHolder(_currentUsersFinders)));

final currentUsersRepositoryProvider =
    Provider<Repository<CurrentUser>>((ref) => Repository<CurrentUser>(ref));

extension CurrentUserDataRepositoryX on Repository<CurrentUser> {
  JsonServerAdapter<CurrentUser> get jsonServerAdapter =>
      remoteAdapter as JsonServerAdapter<CurrentUser>;
}

extension CurrentUserRelationshipGraphNodeX
    on RelationshipGraphNode<CurrentUser> {}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentUser _$CurrentUserFromJson(Map<String, dynamic> json) => CurrentUser(
      id: json['id'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    )..mode = json['mode'] as String?;

Map<String, dynamic> _$CurrentUserToJson(CurrentUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'mode': instance.mode,
    };
