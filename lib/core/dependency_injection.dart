

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
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
import 'package:jazz/features/search_feature/data/data_sources/album_data_source.dart';
import 'package:jazz/features/search_feature/data/data_sources/youtube_data_source.dart';
import 'package:jazz/features/search_feature/data/repositories_impl/song_repository_impl.dart';
import 'package:jazz/features/search_feature/domain/repositories/song_repository.dart';
import 'package:jazz/features/search_feature/domain/usecases/fetch_track_thumbnail.dart';
import 'package:jazz/features/search_feature/domain/usecases/search_album.dart';
import 'package:jazz/features/search_feature/domain/usecases/search.dart';
import 'package:jazz/features/search_feature/domain/usecases/search_albums.dart';
import 'package:jazz/features/search_feature/domain/usecases/search_artists.dart';
import 'package:jazz/features/search_feature/domain/usecases/search_songs.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/album_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/track_thumbnail_bloc/track_thumbnail_bloc.dart';
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

 void setup(){
   // Register Data Sources
   di.registerLazySingleton<DownloadDataSource>(() => DownloadDataSource());
   di.registerLazySingleton<YouTubeDataSource>(() => YouTubeDataSource());
   di.registerLazySingleton<Mp3streamDatasource>(() => Mp3streamDatasource());
   di.registerLazySingleton<RelatedSongDatasource>(() => RelatedSongDatasource(di<Mp3streamDatasource>()));
   di.registerLazySingleton<DownloadedSongsMetadataDataSource>(() => DownloadedSongsMetadataDataSource());
  di.registerLazySingleton<LyricsDataSource>(()=> LyricsDataSource());
  di.registerLazySingleton<AlbumDatasource>(()=> AlbumDatasource());
   // Register Repositories
   di.registerLazySingleton<DownloadRepository>(() => DownloadRepositoryImpl(di<DownloadDataSource>()));
   di.registerLazySingleton<SongRepository>(() => SongRepositoryImpl(dataSource: di<YouTubeDataSource>(),albumDatasource: di<AlbumDatasource>()));
   di.registerLazySingleton<StreamRepository>(() => StreamRepoImpl(di<Mp3streamDatasource>(), di<RelatedSongDatasource>()));
   di.registerLazySingleton<GetDownloadedSongDataRepository>(() => GetDownloadedSongDataRepoImpl(downloadedSongsMetadataDataSource: di<DownloadedSongsMetadataDataSource>()));
   di.registerLazySingleton<LyricsRepository>(()=> LyricsRepoImpl(lyricsDataSource: di<LyricsDataSource>()));
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
 }