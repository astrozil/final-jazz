import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class AppUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final bool signInWithGoogle;
  final String? profilePictureUrl;
  final List<String> favouriteArtists;
  final List<String> favouriteSongs;
  final List<String> songHistory;
  final List<String> playlists;
  final List<String> searchHistory;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;


  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.signInWithGoogle,
    this.profilePictureUrl,
    this.favouriteArtists = const [],
    this.favouriteSongs = const [],
    this.songHistory = const [],
    this.playlists = const [],
    this.searchHistory = const [],
     this.fcmToken,
    required this.createdAt,
    required this.updatedAt,

  });

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);
  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    bool? signInWithGoogle,
    String? profilePictureUrl,
    List<String>? favouriteArtists,
    List<String>? favouriteSongs,
    List<String>? songHistory,
    List<String>? playlists,
    List<String>? searchHistory,
   String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,

  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      signInWithGoogle: signInWithGoogle ?? this.signInWithGoogle,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      favouriteArtists: favouriteArtists ?? this.favouriteArtists,
      favouriteSongs: favouriteSongs ?? this.favouriteSongs,
      songHistory: songHistory ?? this.songHistory,
      playlists: playlists ?? this.playlists,
      searchHistory: searchHistory ?? this.searchHistory,
      fcmToken: fcmToken?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  @override
  List<Object?> get props => [
    id,
    name,
    email,
    profilePictureUrl,
    favouriteArtists,
    favouriteSongs,
    songHistory,
    playlists,
    fcmToken,
    searchHistory,
    createdAt,
    updatedAt,

  ];
}
