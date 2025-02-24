import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';

class Artist {
  final String name;
  final String browseId;
  final String category;
  final String radioId;
  final String resultType;
  final String shuffleId;
  final List<YtThumbnail> thumbnails;
  final List<Album> albums;
  final String description;
  final List<Single> singles;

  Artist({
    required this.name,
    required this.browseId,
    required this.category,
    required this.radioId,
    required this.resultType,
    required this.shuffleId,
    required this.thumbnails,
    required this.albums,
    required this.description,
    required this.singles
  });

  Artist copyWith({
    String? name,
    String? browseId,
    String? category,
    String? radioId,
    String? resultType,
    String? shuffleId,
    List<YtThumbnail>? thumbnails,
    List<Album>? albums,
    String? description,
    List<Single>? singles
  }) {
    return Artist(
      name: name ?? this.name,
      browseId: browseId ?? this.browseId,
      category: category ?? this.category,
      radioId: radioId ?? this.radioId,
      resultType: resultType ?? this.resultType,
      shuffleId: shuffleId ?? this.shuffleId,
      thumbnails: thumbnails ?? this.thumbnails,
      albums: albums ?? this.albums,
      description: description ?? this.description,
      singles: singles ?? this.singles
    );
  }
}


class Single {
  final String browseId;
  final YtThumbnail thumbnail;
  final String title;
  final String year;

  Single({
    required this.browseId,
    required this.thumbnail,
    required this.title,
    required this.year,
  });
}