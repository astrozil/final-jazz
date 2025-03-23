import 'package:equatable/equatable.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';

class RelatedSong extends Equatable {
  final String url;
  final Song song;

  const RelatedSong({required this.url, required this.song});

  RelatedSong copyWith({String? url}) {
    return RelatedSong(
      url: url ?? this.url,
      song: song,
    );
  }

  factory RelatedSong.fromJson(Map<String, dynamic> json) {
    return RelatedSong(
      url: "",
      song: Song.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'song': song.toJson(),
    };
  }

  @override
  List<Object?> get props => [url, song];
}
