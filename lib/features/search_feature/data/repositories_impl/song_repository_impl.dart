import 'package:dartz/dartz.dart';
import 'package:jazz/core/failure/failure.dart';
import 'package:jazz/features/search_feature/data/data_sources/album_data_source.dart';
import 'package:jazz/features/search_feature/data/data_sources/artist_data_source.dart';
import 'package:jazz/features/search_feature/data/data_sources/youtube_data_source.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/domain/entities/artist.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';


import '../../domain/repositories/song_repository.dart';


class SongRepositoryImpl implements SongRepository {
  final YouTubeDataSource dataSource;
  final AlbumDatasource albumDatasource;
  final ArtistDataSource artistDataSource;
  SongRepositoryImpl({required this.dataSource,required this.albumDatasource,required this.artistDataSource});

  @override
  Future<List<Song>?> search(String query) async {
    List<Song>? songs =  await dataSource.search(query) as List<Song>;

    if(songs != null){
      return songs;
    }
    return null;
  }

  @override
  Future<Either<Failure, Album>> searchAlbum(String albumId) {
    return  albumDatasource.searchAlbumMetadata(albumId);
  }

  @override
  Future<Either<Failure, YtThumbnail>> fetchTrackThumbnail(String songId) {

   return albumDatasource.fetchTrackThumbnail(songId);
  }

  @override
  Future<List<Album>?> searchAlbums(String query)async {
    return await dataSource.searchAlbums(query);
  }

  @override
  Future<List<Artist>?> searchArtists(String query)async {
    return await dataSource.searchArtists(query);
  }

  @override
  Future<List<Song>?> searchSongs(String query) {
    return dataSource.searchSongs(query);
  }

  @override
  Future<Artist> fetchArtist(String artistId) {
    return artistDataSource.fetchArtist(artistId);
  }
}
