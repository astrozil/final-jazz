import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/playlist_feature/domain/entities/billboard_song.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/add_favourite_song_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/add_song_to_playlist_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/change_playlist_title_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/create_playlist_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/delete_playlist_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/fetch_billboard_songs_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/fetch_favourite_songs_playlist_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/fetch_playlists_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/fetch_suggested_songs_of_favourite_artists_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/fetch_trending_songs_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/remove_favourite_song_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/remove_song_from_playlist_use_case.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:meta/meta.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final FetchTrendingSongsUseCase _fetchTrendingSongsUseCase;
  final FetchBillboardSongsUseCase _fetchBillboardSongsUseCase;
  final FetchSuggestedSongsOfFavouriteArtistsUseCase _fetchSuggestedSongsOfFavouriteArtistsUseCase;
  final FetchFavouriteSongsPlaylistUseCase _fetchFavouriteSongsPlaylistUseCase;
  final AddFavouriteSongUseCase _addFavouriteSongUseCase;
  final RemoveFavouriteSongUseCase _removeFavouriteSongUseCase;
  final FetchPlaylistsUseCase _fetchPlaylistsUseCase;

  final CreatePlaylistUseCase _createPlaylistUseCase;
  final DeletePlaylistUseCase _deletePlaylistUseCase;
  final ChangePlaylistTitleUseCase _changePlaylistTitleUseCase;
  final AddSongToPlaylistUseCase _addSongToPlaylistUseCase;
  final RemoveSongFromPlaylistUseCase _removeSongFromPlaylistUseCase;


  PlaylistBloc({
    required FetchTrendingSongsUseCase fetchTrendingSongsUseCase,
    required FetchBillboardSongsUseCase fetchBillboardSongsUseCase,
    required FetchSuggestedSongsOfFavouriteArtistsUseCase fetchSuggestedSongsOfFavouriteArtistsUseCase,
    required FetchFavouriteSongsPlaylistUseCase fetchFavouriteSongsPlaylistUseCase,
    required AddFavouriteSongUseCase addFavouriteSongUseCase,
    required RemoveFavouriteSongUseCase removeFavouriteSongUseCase,
    required FetchPlaylistsUseCase fetchPlaylistsUseCase,

    required CreatePlaylistUseCase createPlaylistUseCase,
    required DeletePlaylistUseCase deletePlaylistUseCase,
    required ChangePlaylistTitleUseCase changePlaylistTitleUseCase,
    required AddSongToPlaylistUseCase addSongToPlaylistUseCase,
    required RemoveSongFromPlaylistUseCase removeSongFromPlaylistUseCase,
  })  : _fetchTrendingSongsUseCase = fetchTrendingSongsUseCase,
        _fetchBillboardSongsUseCase = fetchBillboardSongsUseCase,
        _fetchSuggestedSongsOfFavouriteArtistsUseCase = fetchSuggestedSongsOfFavouriteArtistsUseCase,
        _fetchFavouriteSongsPlaylistUseCase = fetchFavouriteSongsPlaylistUseCase,
        _addFavouriteSongUseCase = addFavouriteSongUseCase,
        _removeFavouriteSongUseCase = removeFavouriteSongUseCase,
        _fetchPlaylistsUseCase = fetchPlaylistsUseCase,
        _createPlaylistUseCase = createPlaylistUseCase,
        _deletePlaylistUseCase = deletePlaylistUseCase,
        _changePlaylistTitleUseCase = changePlaylistTitleUseCase,
        _addSongToPlaylistUseCase = addSongToPlaylistUseCase,
        _removeSongFromPlaylistUseCase = removeSongFromPlaylistUseCase,
        super(PlaylistInitial()) {
    on<FetchTrendingSongsPlaylistEvent>((event, emit)async {
     emit(PlaylistInitial());



     try{

       final trendingSongsPlaylist = await _fetchTrendingSongsUseCase();
       emit(PlaylistLoaded(
           trendingSongsPlaylist: trendingSongsPlaylist,
           billboardSongsPlaylist: const [],
         suggestedSongsOfFavouriteArtists: const [],
         favouriteSongsPlaylist:const [],
         userPlaylists:const  []
       ));
     }catch(e){
       emit(PlaylistError(errorMessage: e.toString()));
     }
    });

    on<FetchBillboardSongsPlaylistEvent>((event,emit)async{
      emit(PlaylistInitial());
      try{
        final billboardSongsPlaylist = await _fetchBillboardSongsUseCase();
        emit(PlaylistLoaded(
            trendingSongsPlaylist: const [],
            billboardSongsPlaylist: billboardSongsPlaylist,
            suggestedSongsOfFavouriteArtists: const [],
          favouriteSongsPlaylist: const [],
          userPlaylists: const []
        ));
      }catch(e){
        emit(PlaylistError(errorMessage: e.toString()));
      }
    });

    on<FetchSuggestedSongsOfFavouriteArtists>((event,emit)async{
      emit(PlaylistInitial());
      try{
        final suggestedSongsOfFavouriteArtistsPlaylist = await _fetchSuggestedSongsOfFavouriteArtistsUseCase(event.artistIds);
        emit(PlaylistLoaded(
            trendingSongsPlaylist: const [],
            billboardSongsPlaylist: const [],
          suggestedSongsOfFavouriteArtists: suggestedSongsOfFavouriteArtistsPlaylist,
          favouriteSongsPlaylist: const [],
          userPlaylists: const []
        ));
      }catch(e){
        emit(PlaylistError(errorMessage: e.toString()));
      }
    });

    on<AddFavouriteSong>((event,emit)async{
      try{
      await  _addFavouriteSongUseCase(event.songId);
      emit(AddedFavouriteSong());
      }catch(e){
        emit(PlaylistError(errorMessage: e.toString()));
      }
    });
    on<RemoveFavouriteSong>((event,emit)async{
      try{
        await  _removeFavouriteSongUseCase(event.songId);
        emit(RemovedFavouriteSong());
      }catch(e){
        emit(PlaylistError(errorMessage: e.toString()));
      }
    });

    on<FetchFavouriteSongsPlaylistEvent>((event,emit)async{

      emit(PlaylistInitial());
      try{
     AppUser user;
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {

          final docSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(firebaseUser.uid)
              .get();


          if (docSnapshot.exists) {


             user = AppUser.fromJson(docSnapshot.data()!);



          } else {

            throw Exception("User data not found.");
          }
        } else {
          throw Exception("No logged in user.");
        }

        final favouriteSongsPlaylist = await _fetchFavouriteSongsPlaylistUseCase(user.favouriteSongs);
        emit(PlaylistLoaded(
            trendingSongsPlaylist: const [],
            billboardSongsPlaylist: const [],
            suggestedSongsOfFavouriteArtists: const [],
            favouriteSongsPlaylist: favouriteSongsPlaylist,
          userPlaylists: const []
        ));
      }catch(e){
        emit(PlaylistError(errorMessage: e.toString()));
      }
    });
    on<FetchPlaylists>((event,emit)async{
      emit(PlaylistInitial());
      try{
        final  userPlaylists = await _fetchPlaylistsUseCase();
        emit(PlaylistLoaded(
            trendingSongsPlaylist: const [],
            billboardSongsPlaylist: const [],
            suggestedSongsOfFavouriteArtists: const[],
            favouriteSongsPlaylist: const [],
            userPlaylists: userPlaylists?? []
        ));
      }catch(e){
        emit(PlaylistError(errorMessage: e.toString()));
      }
    });
    on<CreatePlaylist>((event,emit)async{
      try{
        await  _createPlaylistUseCase(event.title);
        emit(RemovedFavouriteSong());
      }catch(e){
        emit(PlaylistError(errorMessage: e.toString()));
      }
    });

    on<DeletePlaylist>((event,emit)async{
      try{
        await  _deletePlaylistUseCase(event.playlistId);
        emit(RemovedFavouriteSong());
      }catch(e){
        emit(PlaylistError(errorMessage: e.toString()));
      }
    });

    on<ChangePlaylistTitle>((event,emit)async{
      try{
        await  _changePlaylistTitleUseCase(event.title,event.playlistId);
        emit(RemovedFavouriteSong());
      }catch(e){
        emit(PlaylistError(errorMessage: e.toString()));
      }
    });

    on<AddSongToPlaylist>((event,emit)async{
      try{
        await  _addSongToPlaylistUseCase(event.songId,event.playlistId);
        emit(RemovedFavouriteSong());
      }catch(e){
        emit(PlaylistError(errorMessage: e.toString()));
      }
    });

    on<RemoveSongFromPlaylist>((event,emit)async{
      try{
        await  _removeSongFromPlaylistUseCase(event.songId,event.playlistId);
        emit(RemovedFavouriteSong());
      }catch(e){
        emit(PlaylistError(errorMessage: e.toString()));
      }
    });
  }
}
