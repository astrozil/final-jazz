import 'package:dartz/dartz.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/domain/entities/artist.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import '../../../../core/failure/failure.dart';

import '../repositories/song_repository.dart';

class SearchArtists {
  final SongRepository repository;

  SearchArtists(this.repository);

  Future<List<Artist>?> call(String query) async {

    return await repository.searchArtists(query);


  }
}
