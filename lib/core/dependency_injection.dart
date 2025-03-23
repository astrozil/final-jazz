

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jazz/features/auth_feature/data/data_source/auth_data_source.dart';
import 'package:jazz/features/auth_feature/data/repo_impl/auth_repo_impl.dart';
import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';
import 'package:jazz/features/auth_feature/domain/use_case/change_password_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/create_user_profile_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/get_auth_status_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/google_sign_in_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/logout_use_case.dart';
import 'package:jazz/features/auth_feature/domain/use_case/sign_in_usecase.dart';
import 'package:jazz/features/auth_feature/domain/use_case/sign_up_usecase.dart';
import 'package:jazz/features/auth_feature/domain/use_case/update_user_profile_use_case.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/download_feature/data/datasources/download_datasource.dart';
import 'package:jazz/features/download_feature/data/datasources/downloadedSongsMetadataDatasource.dart';
import 'package:jazz/features/download_feature/data/repositories_impl/download_repository_impl.dart';
import 'package:jazz/features/download_feature/data/repositories_impl/getDownloadedSongDataRepoImpl.dart';

import 'package:jazz/features/download_feature/domain/repositories/download_repository.dart';
import 'package:jazz/features/download_feature/domain/repositories/getDownloadedSongDataRepository.dart';
import 'package:jazz/features/download_feature/domain/usecases/download_songs.dart';
import 'package:jazz/features/download_feature/domain/usecases/getMetadata.dart';
import 'package:jazz/features/download_feature/presentation/bloc/DownloadedOrNotBloc/downloaded_or_not_bloc.dart';
import 'package:jazz/features/download_feature/presentation/bloc/download/download_bloc.dart';
import 'package:jazz/features/download_feature/presentation/bloc/downloadedSongsBloc/downloaded_songs_bloc.dart';
import 'package:jazz/features/lyrics_feature/data/data_source/lyrics_data_source.dart';
import 'package:jazz/features/lyrics_feature/data/repo_impl/lyrics_repo_impl.dart';
import 'package:jazz/features/lyrics_feature/domain/repositories/lyrics_repsitory.dart';
import 'package:jazz/features/lyrics_feature/domain/usecases/get_lyrics_usecase.dart';
import 'package:jazz/features/lyrics_feature/presentation/bloc/lyrics_bloc/lyrics_bloc.dart';
import 'package:jazz/features/playlist_feature/data/data_source/billboard_data_source.dart';
import 'package:jazz/features/playlist_feature/data/data_source/favourite_playlist_data_source.dart';
import 'package:jazz/features/playlist_feature/data/data_source/suggested_songs_of_favourite_artists.dart';
import 'package:jazz/features/playlist_feature/data/data_source/trending_data_source.dart';
import 'package:jazz/features/playlist_feature/data/data_source/user_playlist_data_source.dart';
import 'package:jazz/features/playlist_feature/data/repo_impl/playlist_repo_impl.dart';
import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';
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
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:jazz/features/search_feature/data/data_sources/album_data_source.dart';
import 'package:jazz/features/search_feature/data/data_sources/artist_data_source.dart';
import 'package:jazz/features/search_feature/data/data_sources/youtube_data_source.dart';
import 'package:jazz/features/search_feature/data/repositories_impl/song_repository_impl.dart';
import 'package:jazz/features/search_feature/domain/repositories/song_repository.dart';
import 'package:jazz/features/search_feature/domain/usecases/fetch_artist.dart';
import 'package:jazz/features/search_feature/domain/usecases/fetch_track_thumbnail.dart';
import 'package:jazz/features/search_feature/domain/usecases/search_album.dart';
import 'package:jazz/features/search_feature/domain/usecases/search.dart';
import 'package:jazz/features/search_feature/domain/usecases/search_albums.dart';
import 'package:jazz/features/search_feature/domain/usecases/search_artists.dart';
import 'package:jazz/features/search_feature/domain/usecases/search_songs.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/album_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/track_thumbnail_bloc/track_thumbnail_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/artist_bloc/artist_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/currentSongWidgetBloc/current_song_widget_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search/search_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/song/song_bloc.dart';
import 'package:jazz/features/stream_feature/data/datasource/mp3StreamDatasource.dart';
import 'package:jazz/features/stream_feature/data/datasource/relatedSongDatasource.dart';
import 'package:jazz/features/stream_feature/data/repositories_impl/streamRepo_impl.dart';
import 'package:jazz/features/stream_feature/domain/repositories/streamRepository.dart';
import 'package:jazz/features/stream_feature/domain/usecases/getMp3StreamUsecase.dart';
import 'package:jazz/features/stream_feature/domain/usecases/getRelatedSongUsecase.dart';

import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';



final di = GetIt.instance;

 void setup({
  required FirebaseAuth firebaseAuth,
  required GoogleSignIn googleSignIn,
 required FirebaseFirestore firebaseFirestore
 }){
   // Register Data Sources
   di.registerLazySingleton<DownloadDataSource>(() => DownloadDataSource());
   di.registerLazySingleton<YouTubeDataSource>(() => YouTubeDataSource());
   di.registerLazySingleton<Mp3streamDatasource>(() => Mp3streamDatasource());
   di.registerLazySingleton<RelatedSongDatasource>(() => RelatedSongDatasource(di<Mp3streamDatasource>()));
   di.registerLazySingleton<DownloadedSongsMetadataDataSource>(() => DownloadedSongsMetadataDataSource());
  di.registerLazySingleton<LyricsDataSource>(()=> LyricsDataSource());
  di.registerLazySingleton<AlbumDatasource>(()=> AlbumDatasource());
  di.registerLazySingleton<ArtistDataSource>(()=> ArtistDataSource());
  di.registerLazySingleton<TrendingDataSource>(()=> TrendingDataSource());
  di.registerLazySingleton<BillboardDataSource>(()=> BillboardDataSource());
  di.registerLazySingleton<AuthDataSource>(()=> AuthDataSource(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
      firebaseFirestore: firebaseFirestore
  ));
  di.registerLazySingleton<SuggestedSongsOfFavouriteArtistsDataSource>(()=> SuggestedSongsOfFavouriteArtistsDataSource());
  di.registerLazySingleton<FavouritePlaylistDataSource>(()=> FavouritePlaylistDataSource(fireStore: firebaseFirestore, firebaseAuth: firebaseAuth));
  di.registerLazySingleton<UserPlaylistDataSource>(()=> UserPlaylistDataSource(fireStore: firebaseFirestore, firebaseAuth: firebaseAuth));
   // Register Repositories
   di.registerLazySingleton<DownloadRepository>(() => DownloadRepositoryImpl(di<DownloadDataSource>()));
   di.registerLazySingleton<SongRepository>(() => SongRepositoryImpl(dataSource: di<YouTubeDataSource>(),albumDatasource: di<AlbumDatasource>(),artistDataSource: di<ArtistDataSource>()));
   di.registerLazySingleton<StreamRepository>(() => StreamRepoImpl(di<Mp3streamDatasource>(), di<RelatedSongDatasource>()));
   di.registerLazySingleton<GetDownloadedSongDataRepository>(() => GetDownloadedSongDataRepoImpl(downloadedSongsMetadataDataSource: di<DownloadedSongsMetadataDataSource>()));
   di.registerLazySingleton<LyricsRepository>(()=> LyricsRepoImpl(lyricsDataSource: di<LyricsDataSource>()));
   di.registerLazySingleton<PlaylistRepo>(()=> PlaylistRepoImpl(
       trendingDataSource: di<TrendingDataSource>(),
       billboardDataSource: di<BillboardDataSource>(),
       suggestedSongsOfFavouriteArtistsDataSource: di<SuggestedSongsOfFavouriteArtistsDataSource>(),
      favouritePlaylistDataSource: di<FavouritePlaylistDataSource>(),
    userPlaylistDataSource: di<UserPlaylistDataSource>()
   ));
   di.registerLazySingleton<AuthRepository>(()=> AuthRepositoryImpl(di<AuthDataSource>()));
   // Register Use Cases
   di.registerLazySingleton<DownloadSongs>(() => DownloadSongs(di<DownloadRepository>()));
   di.registerLazySingleton<Search>(() => Search(di<SongRepository>()));
   di.registerLazySingleton<GetMp3StreamUseCase>(() => GetMp3StreamUseCase(di<StreamRepository>()));
   di.registerLazySingleton<GetRelatedSongUseCase>(() => GetRelatedSongUseCase(di<StreamRepository>()));
   di.registerLazySingleton<GetMetadata>(() => GetMetadata(getDownloadedSongDataRepository: di<GetDownloadedSongDataRepository>()));
    di.registerLazySingleton<GetLyrics>(()=> GetLyrics(di<LyricsRepository>()));
    di.registerLazySingleton<SearchAlbumUseCase>(()=> SearchAlbumUseCase(songRepository: di<SongRepository>()));
    di.registerLazySingleton<FetchTrackThumbnailUseCase>(()=> FetchTrackThumbnailUseCase(songRepository: di<SongRepository>()));
    di.registerLazySingleton<SearchSongs>(()=> SearchSongs(di<SongRepository>()));
   di.registerLazySingleton<SearchAlbums>(()=> SearchAlbums(di<SongRepository>()));
   di.registerLazySingleton<SearchArtists>(()=> SearchArtists(di<SongRepository>()));
   di.registerLazySingleton<FetchArtistUseCase>(()=> FetchArtistUseCase(songRepository: di<SongRepository>()));
   di.registerLazySingleton<FetchTrendingSongsUseCase>(()=> FetchTrendingSongsUseCase(playlistRepo: di<PlaylistRepo>()));
   di.registerLazySingleton<FetchBillboardSongsUseCase>(()=> FetchBillboardSongsUseCase(playlistRepo: di<PlaylistRepo>()));
   di.registerLazySingleton<SignUpUseCase>(()=> SignUpUseCase(di<AuthRepository>()));
   di.registerLazySingleton<SignInUseCase>(()=> SignInUseCase(di<AuthRepository>()));
   di.registerLazySingleton<SignInWithGoogleUseCase>(()=> SignInWithGoogleUseCase(di<AuthRepository>()));
   di.registerLazySingleton<GetAuthStatusUseCase>(()=> GetAuthStatusUseCase(di<AuthRepository>()));
   di.registerLazySingleton<LogoutUseCase>(()=> LogoutUseCase(di<AuthRepository>()));
   di.registerLazySingleton<CreateUserProfileUseCase>(()=> CreateUserProfileUseCase(di<AuthRepository>()));
   di.registerLazySingleton<UpdateUserProfileUseCase>(()=> UpdateUserProfileUseCase(authRepository: di<AuthRepository>()));
   di.registerLazySingleton<ChangePasswordUseCase>(()=> ChangePasswordUseCase(authRepository: di<AuthRepository>()));
   di.registerLazySingleton<FetchSuggestedSongsOfFavouriteArtistsUseCase>(()=> FetchSuggestedSongsOfFavouriteArtistsUseCase(playlistRepo: di<PlaylistRepo>()));
   di.registerLazySingleton<AddFavouriteSongUseCase>(()=> AddFavouriteSongUseCase(playlistRepo: di<PlaylistRepo>()));
   di.registerLazySingleton<RemoveFavouriteSongUseCase>(()=> RemoveFavouriteSongUseCase(playlistRepo: di<PlaylistRepo>()));
   di.registerLazySingleton<FetchFavouriteSongsPlaylistUseCase>(()=>FetchFavouriteSongsPlaylistUseCase(playlistRepo: di<PlaylistRepo>()));
   di.registerLazySingleton<FetchPlaylistsUseCase>(()=> FetchPlaylistsUseCase(playlistRepo: di<PlaylistRepo>()));
   di.registerLazySingleton<CreatePlaylistUseCase>(()=> CreatePlaylistUseCase(playlistRepo: di<PlaylistRepo>()));
   di.registerLazySingleton<DeletePlaylistUseCase>(()=> DeletePlaylistUseCase(playlistRepo: di<PlaylistRepo>()));
   di.registerLazySingleton<ChangePlaylistTitleUseCase>(()=> ChangePlaylistTitleUseCase(playlistRepo: di<PlaylistRepo>()));
   di.registerLazySingleton<AddSongToPlaylistUseCase>(()=> AddSongToPlaylistUseCase(playlistRepo: di<PlaylistRepo>()));
   di.registerLazySingleton<RemoveSongFromPlaylistUseCase>(()=> RemoveSongFromPlaylistUseCase(playlistRepo: di<PlaylistRepo>()));

   // Register Blocs
   di.registerLazySingleton<DownloadBloc>(() => DownloadBloc(di<DownloadSongs>()));

   di.registerLazySingleton<SongBloc>(() => SongBloc(di<Search>()));
   di.registerLazySingleton<CurrentSongWidgetBloc>(() => CurrentSongWidgetBloc());

   di.registerLazySingleton<DownloadedSongsBloc>(() => DownloadedSongsBloc(getMetadata: di<GetMetadata>()));
   di.registerLazySingleton<DownloadedOrNotBloc>(() => DownloadedOrNotBloc());

   di.registerLazySingleton<LyricsBloc>(()=> LyricsBloc(getLyrics: di<GetLyrics>()));
   di.registerLazySingleton<TrackThumbnailBloc>(()=> TrackThumbnailBloc(fetchTrackThumbnailUseCase: di<FetchTrackThumbnailUseCase>()) );
   di.registerLazySingleton<AlbumBloc>(()=> AlbumBloc(searchAlbumUseCase: di<SearchAlbumUseCase>(),trackThumbnailBloc: di<TrackThumbnailBloc>()));
   di.registerLazySingleton<PlayerBloc>(()=> PlayerBloc(
       getMp3StreamUseCase: di<GetMp3StreamUseCase>(),
       getRelatedSongUseCase: di<GetRelatedSongUseCase>(),
       getLyrics: di<GetLyrics>()));
   di.registerLazySingleton(()=> SearchBloc(searchSongs: di<SearchSongs>(), searchAlbums: di<SearchAlbums>(), searchArtists: di<SearchArtists>()));
   di.registerLazySingleton<ArtistBloc>(()=> ArtistBloc(fetchArtistUseCase: di<FetchArtistUseCase>()));
   di.registerLazySingleton<PlaylistBloc>(()=> PlaylistBloc(
       fetchTrendingSongsUseCase: di<FetchTrendingSongsUseCase>(),
       fetchBillboardSongsUseCase:di<FetchBillboardSongsUseCase>(),
      fetchSuggestedSongsOfFavouriteArtistsUseCase: di<FetchSuggestedSongsOfFavouriteArtistsUseCase>(),
    addFavouriteSongUseCase: di<AddFavouriteSongUseCase>(),
    removeFavouriteSongUseCase: di<RemoveFavouriteSongUseCase>(),
    fetchFavouriteSongsPlaylistUseCase: di<FetchFavouriteSongsPlaylistUseCase>(),
    fetchPlaylistsUseCase: di<FetchPlaylistsUseCase>(),
    createPlaylistUseCase: di<CreatePlaylistUseCase>(),
    deletePlaylistUseCase: di<DeletePlaylistUseCase>(),
    changePlaylistTitleUseCase: di<ChangePlaylistTitleUseCase>(),
    addSongToPlaylistUseCase: di<AddSongToPlaylistUseCase>(),
    removeSongFromPlaylistUseCase: di<RemoveSongFromPlaylistUseCase>()
   ));
   di.registerLazySingleton<AuthBloc>(()=> AuthBloc(
       signUpUseCase: di<SignUpUseCase>(),
       signInUseCase: di<SignInUseCase>(),
       signInWithGoogleUseCase: di<SignInWithGoogleUseCase>(),
      getAuthStatusUseCase: di<GetAuthStatusUseCase>(),
    logoutUseCase: di<LogoutUseCase>(),
    createUserProfileUseCase: di<CreateUserProfileUseCase>(),
    updateUserProfileUseCase: di<UpdateUserProfileUseCase>(),
    changePasswordUseCase: di<ChangePasswordUseCase>()
   ));
 }