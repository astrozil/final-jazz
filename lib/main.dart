import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:jazz/core/dependency_injection.dart';
import 'package:jazz/core/router.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/domain/repo/auth_repository.dart';
import 'package:jazz/features/auth_feature/domain/repo/push_notification_repository.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/friend_request_bloc/friend_request_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/notification_bloc/notification_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/search_users_bloc/search_users_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/screens/friend_requests_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/set_favourite_artists_screen.dart';
import 'package:jazz/features/auth_feature/presentation/screens/set_name_screen.dart';
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
import 'package:jazz/features/internet_connection_checker/presentation/bloc/internet_connection_checker_bloc.dart';
import 'package:jazz/features/internet_connection_checker/presentation/bloc/internet_connection_checker_event.dart';
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
import 'package:jazz/features/search_feature/presentation/bloc/search_suggestion_bloc/search_suggestion_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/song/song_bloc.dart';
import 'package:jazz/features/search_feature/presentation/screens/search_screen.dart';
import 'package:jazz/features/song_share_feature/presentation/bloc/shared_song_bloc/shared_song_bloc.dart';
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


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  // You can handle background messages here or leave it to the system
}

void main()async {



  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    // Use debug provider during development
    androidProvider: AndroidProvider.debug,
    // For iOS
    appleProvider: AppleProvider.deviceCheck,
    // For web applications

  );
  await Supabase.initialize(
    url: 'https://rzxhrjumfyhngxgqekpz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ6eGhyanVtZnlobmd4Z3Fla3B6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE0OTk4MzgsImV4cCI6MjA1NzA3NTgzOH0.NymQ8TfKAYsDVr2ad5fPPfgKS9HjURGFdZDrUTjIXPs',
  );
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
 GoogleSignIn googleSignIn = GoogleSignIn();
 FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
 FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();
 FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  setup(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
      firebaseFirestore: firebaseFirestore,
      firebaseMessaging: firebaseMessaging,
      localNotification: localNotificationsPlugin
  );
  final AppRouter appRouter = AppRouter();
  await MetadataGod.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  final pushNotificationRepository = di<PushNotificationRepository>();
  await pushNotificationRepository.initialize();





  runApp( MyApp(appRouter: appRouter,));
}

class MyApp extends StatefulWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setupFcmListeners();
  }

  Future<void> _initializeApp() async {

    _currentUserId = FirebaseAuth.instance.currentUser!.uid; // Replace with actual user ID

    // Update FCM token in the database
    if (_currentUserId != null) {
      _updateFcmToken();

      // Set user ID in the BLoCs
      di<FriendRequestBloc>().add(SetCurrentUserIdEvent(_currentUserId!));
      di<NotificationBloc>().add(SetCurrentUserIdNotificationEvent(_currentUserId!));
     di<SharedSongBloc>().add(SetCurrentUserIdSharedSongEvent(_currentUserId!));
    }
  }
  Future<void> _updateFcmToken() async {
    if (_currentUserId == null) return;

    final pushNotificationRepository = di<PushNotificationRepository>();
    final token = await pushNotificationRepository.getFcmToken();
    if (token != null) {
      final userRepository = di<AuthRepository>();
      await userRepository.updateFcmToken(_currentUserId!, token);
    }
  }
  void _setupFcmListeners() {
    // Handle FCM message when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {

        _handleMessage(message);
      }
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      // Handle FCM message when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Set up local notification tap handler
      FlutterLocalNotificationsPlugin().initialize(
        InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),

        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // This handles when user taps on notification
          if(response.payload!.contains("friend_request")){
            _navigatorKey.currentState?.pushNamed(Routes.friendRequestsScreen);
          }else if(response.payload!.contains("shared_song")){
            _navigatorKey.currentState?.pushNamed(Routes.sharedSongsScreen);
          }
        },
      );
    });


  }
  void navigateToFriendRequestsScreen() {
    // Navigate to friend requests screen using the navigator key
    _navigatorKey.currentState?.pushNamed(Routes.friendRequestsScreen);
  }
  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      _showLocalNotification(message);
    }
  }
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    final platformDetails = NotificationDetails(android: androidDetails);

    FlutterLocalNotificationsPlugin().show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      payload: json.encode(message.data),
    );
  }

  void _handleMessage(RemoteMessage message) {
    // Navigate based on the notification type
    final data = message.data;
    if (data.containsKey('type')) {
      final type = data['type'];
      if (type == 'friend_request') {
        _navigatorKey.currentState?.pushNamed(Routes.friendRequestsScreen);
      } else if (type == 'request_accepted') {
        // Navigate to friends list or user profile
      } else if (type == 'shared_song') {
        // If we have a song ID, navigate to that song's details
        if (data.containsKey('songId')) {
          // You would need to fetch the song details first
          // This is a simplified example
          _navigatorKey.currentState?.pushNamed(Routes.sharedSongsScreen);
        }
      }
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;

    if (notification != null) {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      di<FlutterLocalNotificationsPlugin>();

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'friend_request_channel',
        'Friend Requests',
        channelDescription: 'Notifications for friend requests',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: data['type'],
      );

      // Set up notification tap handler
      flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload == 'friend_request') {
            _navigatorKey.currentState?.pushNamed(Routes.friendRequestsScreen);
          }
        },
      );
    }
  }

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
        BlocProvider<AuthBloc>(create: (context)=> di<AuthBloc>()..add(CheckAuthUserStatus())),
        BlocProvider<SearchUsersBloc>(create: (context)=> di<SearchUsersBloc>()),
        BlocProvider<FriendRequestBloc>(create: (context)=> di<FriendRequestBloc>()),
        BlocProvider<NotificationBloc>(create: (context)=> di<NotificationBloc>()),
        BlocProvider<SharedSongBloc>(create: (context)=> di<SharedSongBloc>()),
        BlocProvider<SearchSuggestionBloc>(create: (context)=> di<SearchSuggestionBloc>()),
        BlocProvider<InternetConnectionBloc>(create: (context)=> di<InternetConnectionBloc>()..add(CheckInternetConnection())),
        BlocProvider<UserBloc>(create: (context)=> di<UserBloc>())
      ],
      child: ScreenUtilInit(
        designSize: const Size(426,928),
        minTextAdapt: true,
        builder: (_,context) {
          return MaterialApp(
            theme: ThemeData(
              fontFamily: "Cal Sans"
            ),
            debugShowCheckedModeBanner: false,
            navigatorKey: _navigatorKey,
            title: 'Music App',
            onGenerateRoute: widget.appRouter.onGenerateRoute,
            initialRoute: Routes.splashScreen,
            // home: SetFavouriteArtistsScreen(),
          );
        }
      ),
    );
  }
}
