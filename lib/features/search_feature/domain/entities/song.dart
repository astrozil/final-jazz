import 'package:equatable/equatable.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';

class Song extends Equatable {
  final String url;
  final String title;
  final String artist;

  final String id;
  final String kind;
  final String browseId;
  final YtThumbnails thumbnails;


  Song({
    required this.url,
    required this.title,
    required this.artist,
    required this.id,
    required this.kind,
    required this.browseId,
    required this.thumbnails,

  });
  Song copyWith({
    String? url,
    String? title,
    String? artist,
    String? id,
    String? kind,
    String? browseId,
    YtThumbnails? thumbnails,
  }) {
    return Song(
      url: url ?? this.url,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      id: id ?? this.id,
      kind: kind ?? this.kind,
      browseId: browseId ?? this.browseId,
      thumbnails: thumbnails ?? this.thumbnails,
    );
  }

  @override

  List<Object?> get props => [id];
}
