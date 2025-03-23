// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      signInWithGoogle: json['signInWithGoogle'] as bool,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      favouriteArtists: (json['favouriteArtists'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      favouriteSongs: (json['favouriteSongs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      songHistory: (json['songHistory'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      playlists: (json['playlists'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      searchHistory: (json['searchHistory'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'signInWithGoogle': instance.signInWithGoogle,
      'profilePictureUrl': instance.profilePictureUrl,
      'favouriteArtists': instance.favouriteArtists,
      'favouriteSongs': instance.favouriteSongs,
      'songHistory': instance.songHistory,
      'playlists': instance.playlists,
      'searchHistory': instance.searchHistory,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
