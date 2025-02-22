import 'package:dartz/dartz.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import '../../../../core/failure/failure.dart';

import '../repositories/song_repository.dart';

class SearchAlbums {
  final SongRepository repository;

  SearchAlbums(this.repository);

  Future<List<Album>?> call(String query) async {

      return await repository.searchAlbums(query);


  }
}
