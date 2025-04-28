import 'package:jazz/features/search_feature/domain/repositories/song_repository.dart';

class GetSuggestionsUseCase {
  final SongRepository songRepository;

  GetSuggestionsUseCase({required this.songRepository});

  Future<List> execute({required String query})async{
    return songRepository.getSuggestions(query);
  }

}