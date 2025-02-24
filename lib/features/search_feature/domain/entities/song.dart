import 'package:equatable/equatable.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';

class Song extends Equatable {
  final String url;
  final String title;
  final String artist;
 final String resultType;
  final String id;
  final String category;
  final String browseId;
  final YtThumbnails thumbnails;


  Song({
    required this.url,
    required this.title,
    required this.artist,
    required this.id,
    required this.category,
    required this.browseId,
    required this.thumbnails,
    required this.resultType

  });
  Song copyWith({
    String? url,
    String? title,
    String? artist,
    String? id,
    String? category,
    String? resultType,
    String? browseId,
    YtThumbnails? thumbnails,
  }) {
    return Song(
      url: url ?? this.url,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      id: id ?? this.id,
      resultType: resultType ?? this.resultType,
      category: category ?? this.category,
      browseId: browseId ?? this.browseId,
      thumbnails: thumbnails ?? this.thumbnails,
    );
  }

  @override

  List<Object?> get props => [id];
}
