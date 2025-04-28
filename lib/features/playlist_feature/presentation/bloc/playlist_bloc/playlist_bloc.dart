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
import 'package:jazz/features/playlist_feature/domain/use_cases/fetch_playlist_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/fetch_playlists_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/fetch_recommended_songs_playlist_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/fetch_suggested_songs_of_favourite_artists_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/fetch_trending_songs_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/remove_favourite_song_use_case.dart';
import 'package:jazz/features/playlist_feature/domain/use_cases/remove_song_from_playlist_use_case.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:meta/meta.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistLoaded> {
  final FetchTrendingSongsUseCase _fetchTrendingSongsUseCase;
  final FetchBillboardSongsUseCase _fetchBillboardSongsUseCase;
  final FetchSuggestedSongsOfFavouriteArtistsUseCase _fetchSuggestedSongsOfFavouriteArtistsUseCase;
  final FetchFavouriteSongsPlaylistUseCase _fetchFavouriteSongsPlaylistUseCase;
  final FetchRecommendedSongsPlaylistUseCase _fetchRecommendedSongsPlaylistUseCase;
  final AddFavouriteSongUseCase _addFavouriteSongUseCase;
  final RemoveFavouriteSongUseCase _removeFavouriteSongUseCase;
  final FetchPlaylistsUseCase _fetchPlaylistsUseCase;
 final FetchPlaylistUseCase _fetchPlaylistUseCase;
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
    required FetchRecommendedSongsPlaylistUseCase fetchRecommendedSongsPlaylistUseCase,
    required AddFavouriteSongUseCase addFavouriteSongUseCase,
    required RemoveFavouriteSongUseCase removeFavouriteSongUseCase,
    required FetchPlaylistsUseCase fetchPlaylistsUseCase,
   required FetchPlaylistUseCase fetchPlaylistUseCase,
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
        _fetchPlaylistUseCase = fetchPlaylistUseCase,
        _createPlaylistUseCase = createPlaylistUseCase,
        _deletePlaylistUseCase = deletePlaylistUseCase,
        _changePlaylistTitleUseCase = changePlaylistTitleUseCase,
        _addSongToPlaylistUseCase = addSongToPlaylistUseCase,
        _removeSongFromPlaylistUseCase = removeSongFromPlaylistUseCase,
       _fetchRecommendedSongsPlaylistUseCase = fetchRecommendedSongsPlaylistUseCase,
        super(PlaylistLoaded(
        isLoading: true,
          trendingSongsPlaylist: const [],
          billboardSongsPlaylist: const [],
          songsFromSongIdList: const [],
          suggestedSongsOfFavouriteArtists: const [],
          recommendedSongsPlaylist:  const [],
          favouriteSongsPlaylist: const [],
          userPlaylists: const [],
          userPlaylist: const {})) {
    on<FetchTrendingSongsPlaylistEvent>((event, emit)async {

    emit(state.copyWith(isLoading: true));


     try{

       final trendingSongsPlaylist = await _fetchTrendingSongsUseCase();

       emit(state.copyWith(isLoading: false,trendingSongsPlaylist: trendingSongsPlaylist));
     }catch(e){
      print(e.toString());
     }
    });

    on<FetchBillboardSongsPlaylistEvent>((event,emit)async{
      emit(state.copyWith(isLoading: true));
      try{
        final billboardSongsPlaylist = await _fetchBillboardSongsUseCase();
        emit(state.copyWith(
            isLoading: false,
            billboardSongsPlaylist: billboardSongsPlaylist));
      }catch(e){
       print(e.toString());
      }
    });

    on<FetchSuggestedSongsOfFavouriteArtists>((event,emit)async{
      emit(state.copyWith(isLoading: true));
      try{
        final suggestedSongsOfFavouriteArtistsPlaylist = await _fetchSuggestedSongsOfFavouriteArtistsUseCase(event.artistIds);
        emit(state.copyWith(
            isLoading: false,
            suggestedSongsOfFavouriteArtists: suggestedSongsOfFavouriteArtistsPlaylist));
      }catch(e){
       print(e.toString());
      }
    });
    on<FetchRecommendedSongsPlaylist>((event,emit)async{
      emit(state.copyWith(isLoading: true));
      try{
        final recommendedSongsPlaylist = await _fetchRecommendedSongsPlaylistUseCase();
        emit(state.copyWith(
            isLoading: false,
            recommendedSongsPlaylist: recommendedSongsPlaylist));
      }catch(e){
        print(e.toString());
      }
    });
    on<AddFavouriteSong>((event,emit)async{
      try{
      await  _addFavouriteSongUseCase(event.songId);

      }catch(e){
       print(e.toString());
      }
    });
    on<RemoveFavouriteSong>((event,emit)async{
      try{
        await  _removeFavouriteSongUseCase(event.songId);

      }catch(e){
       print(e.toString());
      }
    });

    on<FetchFavouriteSongsPlaylistEvent>((event,emit)async{

      emit(state.copyWith(isLoading: true));
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
        emit(state.copyWith(
            isLoading: false,
            favouriteSongsPlaylist: favouriteSongsPlaylist));
      }catch(e){

      }
    });
    on<FetchPlaylists>((event,emit)async{
      emit(state.copyWith(isLoading: true));
      try{
        final  userPlaylists = await _fetchPlaylistsUseCase();
        emit(state.copyWith(
            isLoading: false,
            userPlaylists: userPlaylists));
      }catch(e){
        print(e.toString());
      }
    });
   on<FetchSongsFromSongIdList>((event,emit)async{
     emit(state.copyWith(isLoading: true));
     try{
       final songsFromSongIdList = await _fetchFavouriteSongsPlaylistUseCase(event.songIdList);
       emit(state.copyWith(isLoading: false,songsFromSongIdList: songsFromSongIdList));
     }catch(e){
       print(e.toString());
     }
   });
    on<FetchPlaylist>((event,emit)async{
      emit(state.copyWith(isLoading: true));
      try{
        final  userPlaylist = await _fetchPlaylistUseCase(event.playlistId);
        emit(state.copyWith(
            isLoading: false,
            userPlaylist: userPlaylist));
      }catch(e){
        print(e.toString());
      }
    });
    on<CreatePlaylist>((event,emit)async{
      try{
        await  _createPlaylistUseCase(event.title);
        add(FetchPlaylists());

      }catch(e){
        print(e.toString());
      }
    });

    on<DeletePlaylist>((event,emit)async{
      try{
        await  _deletePlaylistUseCase(event.playlistId);
        add(FetchPlaylists());
      }catch(e){
        print(e.toString());
      }
    });

    on<ChangePlaylistTitle>((event,emit)async{
      try{
        await  _changePlaylistTitleUseCase(event.title,event.playlistId);

      }catch(e){
        print(e.toString());
      }
    });

    on<AddSongToPlaylist>((event,emit)async{
      try{
        await  _addSongToPlaylistUseCase(event.songId,event.playlistId);
        add(FetchPlaylists());
      }catch(e){
        print(e.toString());
      }
    });

    on<RemoveSongFromPlaylist>((event,emit)async{
      try{
        await  _removeSongFromPlaylistUseCase(event.songId,event.playlistId);
        add(FetchPlaylists());
      }catch(e){
        print(e.toString());
      }
    });
  }
}
