import 'package:bloc/bloc.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/domain/entities/artist.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/search_feature/domain/repositories/song_repository.dart';
import 'package:jazz/features/search_feature/domain/usecases/search_albums.dart';
import 'package:jazz/features/search_feature/domain/usecases/search_artists.dart';
import 'package:jazz/features/search_feature/domain/usecases/search_songs.dart';
import 'package:meta/meta.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchSongs _searchSongs;
  final SearchAlbums _searchAlbums;
  final SearchArtists _searchArtists;

  SearchBloc({ required SearchSongs searchSongs,required SearchAlbums searchAlbums, required SearchArtists searchArtists })
      : _searchSongs = searchSongs,
         _searchAlbums = searchAlbums,
         _searchArtists = searchArtists,
        super(SearchInitial()) {
    on<SearchSongsRequested>(_onSearchSongsRequested);
    on<SearchAlbumsRequested>(_onSearchAlbumsRequested);
    on<SearchArtistsRequested>(_onSearchArtistsRequested);
  }

  Future<void> _onSearchSongsRequested(
      SearchSongsRequested event,
      Emitter<SearchState> emit,
      ) async {
    emit(SearchLoading());
    try {
      final songs = await _searchSongs(event.query);
      if(songs != null){
        emit(SearchLoaded(songs: songs, albums: [], artists: []));
      }

    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  Future<void> _onSearchAlbumsRequested(
      SearchAlbumsRequested event,
      Emitter<SearchState> emit,
      ) async {
    emit(SearchLoading());
    try {
      final albums = await _searchAlbums(event.query);
      if(albums != null){
        emit(SearchLoaded(songs: [], albums: albums, artists: []));
      }

    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  Future<void> _onSearchArtistsRequested(
      SearchArtistsRequested event,
      Emitter<SearchState> emit,
      ) async {
    emit(SearchLoading());
    try {
      final artists = await _searchArtists(event.query);
      if(artists != null){
        emit(SearchLoaded(songs: [], albums: [], artists: artists));
      }

    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }
}
