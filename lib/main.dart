import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jazz/core/dependency_injection.dart';
import 'package:jazz/core/router.dart';
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
import 'package:jazz/features/lyrics_feature/presentation/bloc/lyrics_bloc/lyrics_bloc.dart';
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:jazz/features/search_feature/data/data_sources/youtube_data_source.dart';
import 'package:jazz/features/search_feature/data/repositories_impl/song_repository_impl.dart';
import 'package:jazz/features/search_feature/domain/usecases/search.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/album_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/track_thumbnail_bloc/track_thumbnail_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/artist_bloc/artist_bloc.dart';
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
import 'package:jazz/firebase_options.dart';

import 'package:metadata_god/metadata_god.dart';
import 'package:supabase_flutter/supabase_flutter.dart';




void main()async {



  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://rzxhrjumfyhngxgqekpz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ6eGhyanVtZnlobmd4Z3Fla3B6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE0OTk4MzgsImV4cCI6MjA1NzA3NTgzOH0.NymQ8TfKAYsDVr2ad5fPPfgKS9HjURGFdZDrUTjIXPs',
  );
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
 GoogleSignIn googleSignIn = GoogleSignIn();
 FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  setup(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
      firebaseFirestore: firebaseFirestore
  );
  final AppRouter appRouter = AppRouter();
  await MetadataGod.initialize();





  runApp( MyApp(appRouter: appRouter,));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});





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
        BlocProvider<SearchBloc>(create: (context)=> di<SearchBloc>()),
        BlocProvider<ArtistBloc>(create: (context)=> di<ArtistBloc>()),
        BlocProvider<PlaylistBloc>(create: (context)=> di<PlaylistBloc>()),
        BlocProvider<AuthBloc>(create: (context)=> di<AuthBloc>()..add(CheckAuthUserStatus()))
      ],
      child: MaterialApp(
        title: 'Music App',
        onGenerateRoute: appRouter.onGenerateRoute,
      ),
    );
  }
}
