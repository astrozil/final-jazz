import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';

class Artist {
  final String name;
  final String browseId;
  final String category;
  final String radioId;
  final String resultType;
  final String shuffleId;
  final List<YtThumbnail> thumbnails;

  Artist({
    required this.name,
    required this.browseId,
    required this.category,
    required this.radioId,
    required this.resultType,
    required this.shuffleId,
    required this.thumbnails,
  });

  Artist copyWith({
    String? name,
    String? browseId,
    String? category,
    String? radioId,
    String? resultType,
    String? shuffleId,
    List<YtThumbnail>? thumbnails,
  }) {
    return Artist(
      name: name ?? this.name,
      browseId: browseId ?? this.browseId,
      category: category ?? this.category,
      radioId: radioId ?? this.radioId,
      resultType: resultType ?? this.resultType,
      shuffleId: shuffleId ?? this.shuffleId,
      thumbnails: thumbnails ?? this.thumbnails,
    );
  }
}
