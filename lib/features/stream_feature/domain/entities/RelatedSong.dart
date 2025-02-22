import 'package:equatable/equatable.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';

class RelatedSong extends Equatable {
  final String url;
  final Song song;

  const RelatedSong({required this.url, required this.song});

  // Method to create a new instance with an updated url
  RelatedSong copyWith({String? url}) {
    return RelatedSong(
      url: url ?? this.url,
      song: song,
    );
  }

  @override
  List<Object?> get props => [url, song];
}
