import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

class Album {
  final String artist;
  final String artistId;
  final String description;
  final String duration;
  final YtThumbnail ytThumbnail;
  final String title;
  final int trackCount;
  final List<RelatedSong> tracks;
  final String year;
  final String type;
  final String browseId;

  Album({
    required this.artist,
    required this.artistId,
    required this.description,
    required this.duration,
    required this.ytThumbnail,
    required this.title,
    required this.trackCount,
    required this.tracks,
    required this.year,
    required this.type,
    required this.browseId,
  });

  Album copyWith({
    String? artist,
    String? artistId,
    String? description,
    String? duration,
    YtThumbnail? ytThumbnail,
    String? title,
    int? trackCount,
    List<RelatedSong>? tracks,
    String? year,
    String? type,
    String? browseId,
  }) {
    return Album(
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      ytThumbnail: ytThumbnail ?? this.ytThumbnail,
      title: title ?? this.title,
      trackCount: trackCount ?? this.trackCount,
      tracks: tracks ?? this.tracks,
      year: year ?? this.year,
      type: type ?? this.type,
      browseId: browseId ?? this.browseId,
    );
  }

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      artist: json['artist'] as String? ?? "",
      artistId: json['artistId'] as String? ?? "",
      description: json['description'] as String? ?? "",
      duration: json['duration'] as String? ?? "",
      ytThumbnail: YtThumbnail.fromJson(
        json['thumbnails'][0] as Map<String,dynamic>? ?? {},
      ),
      title: json['title'] as String? ?? "",
      trackCount: json['trackCount'] as int? ?? 0,
      tracks: (json['tracks'] as List<dynamic>? ?? [])
          .map((e) => RelatedSong.fromJson(e as Map<String, dynamic>))
          .toList(),
      year: json['year'] as String? ?? "",
      type: json['type'] as String? ?? "",
      browseId: json['browseId'] as String? ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artist': artist,
      'artistId': artistId,
      'description': description,
      'duration': duration,
      'thumbnail': ytThumbnail.toJson(),
      'title': title,
      'trackCount': trackCount,
      'tracks': tracks.map((e) => e.toJson()).toList(),
      'year': year,
      'type': type,
      'browseId': browseId,
    };
  }
}
