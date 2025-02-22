

import 'package:dartz/dartz.dart';
import 'package:jazz/core/failure/failure.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/domain/entities/artist.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';

abstract class SongRepository {
  Future<List<Song>?> search(String query);
  Future<List<Song>?> searchSongs(String query);
  Future<List<Album>?> searchAlbums(String query);
  Future<List<Artist>?> searchArtists(String query);
  Future<Either<Failure,Album>> searchAlbum(String albumId);
  Future<Either<Failure,YtThumbnail>> fetchTrackThumbnail(String   songId);
}

    