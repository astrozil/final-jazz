import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/dependency_injection.dart';
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
import 'package:jazz/features/lyrics_feature/presentation/bloc/lyrics_bloc/lyrics_bloc.dart';
import 'package:jazz/features/search_feature/data/data_sources/youtube_data_source.dart';
import 'package:jazz/features/search_feature/data/repositories_impl/song_repository_impl.dart';
import 'package:jazz/features/search_feature/domain/usecases/search.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/album_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/track_thumbnail_bloc/track_thumbnail_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/currentSongWidgetBloc/current_song_widget_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search/search_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/song/song_bloc.dart';
import 'package:jazz/features/search_feature/presentation/screens/search_screen.dart';
import 'package:jazz/features/stream_feature/data/datasource/mp3StreamDatasource.dart';
import 'package:jazz/features/stream_feature/data/datasource/relatedSongDatasource.dart';
import 'package:jazz/features/stream_feature/data/repositories_impl/streamRepo_impl.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/domain/repositories/streamRepository.dart';
import 'package:jazz/features/stream_feature/domain/usecases/getMp3StreamUsecase.dart';
import 'package:jazz/features/stream_feature/domain/usecases/getRelatedSongUsecase.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

import 'package:metadata_god/metadata_god.dart';




void main()async {
  setup();
  WidgetsFlutterBinding.ensureInitialized();
  await MetadataGod.initialize();





  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});





  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [

        BlocProvider<SongBloc>(
          create: (context) => di<SongBloc>(),

        ),
       BlocProvider<DownloadBloc>(create: (context)=> di<DownloadBloc>()),
        BlocProvider<CurrentSongWidgetBloc>(create: (context)=> di<CurrentSongWidgetBloc>() ),


        BlocProvider<DownloadedSongsBloc>(create:(context)=> di<DownloadedSongsBloc>()),
        BlocProvider<DownloadedOrNotBloc>(create: (context)=> di<DownloadedOrNotBloc>()),

         BlocProvider<LyricsBloc>(create: (context)=> di<LyricsBloc>()),
        BlocProvider<TrackThumbnailBloc>(
          create: (context) => di<TrackThumbnailBloc>(),

        ),
        BlocProvider<AlbumBloc>(create: (context)=> di<AlbumBloc>()),
        BlocProvider<PlayerBloc>(create: (context)=> di<PlayerBloc>()),
        BlocProvider<SearchBloc>(create: (context)=> di<SearchBloc>())
      ],
      child: MaterialApp(
        title: 'Music App',
        home: SearchScreen(),
      ),
    );
  }
}
