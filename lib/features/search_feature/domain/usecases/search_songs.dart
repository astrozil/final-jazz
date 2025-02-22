import 'package:dartz/dartz.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import '../../../../core/failure/failure.dart';

import '../repositories/song_repository.dart';

class SearchSongs {
  final SongRepository repository;

  SearchSongs(this.repository);

  Future<List<Song>?> call(String query) async {

    return await repository.searchSongs(query);


  }
}
