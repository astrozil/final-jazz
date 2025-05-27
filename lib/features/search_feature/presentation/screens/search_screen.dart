import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/dependency_injection.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/core/widgets/app_with_player.dart';
import 'package:jazz/core/widgets/song_widget.dart';

import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/download_feature/data/datasources/download_datasource.dart';
import 'package:jazz/features/download_feature/domain/entities/download_request.dart';
import 'package:jazz/features/download_feature/presentation/bloc/DownloadedOrNotBloc/downloaded_or_not_bloc.dart';
import 'package:jazz/features/download_feature/presentation/bloc/download/download_bloc.dart';
import 'package:jazz/features/download_feature/presentation/bloc/downloadedSongsBloc/downloaded_songs_bloc.dart';
import 'package:jazz/features/download_feature/presentation/screens/download_screen.dart';
import 'package:jazz/features/download_feature/presentation/screens/downloaded_songs_screen.dart';
import 'package:jazz/features/internet_connection_checker/presentation/screens/internet_connection_wrapper.dart';
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/billboard_songs_playlist_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/suggested_songs_of_favourite_artists_playlist_screen.dart';
import 'package:jazz/features/playlist_feature/presentation/screens/trending_songs_playlist_screen.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/search_feature/domain/usecases/search.dart';
import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/album_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/artist_bloc/artist_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/currentSongWidgetBloc/current_song_widget_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search/search_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search_suggestion_bloc/search_suggestion_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/song/song_bloc.dart';
import 'package:jazz/features/search_feature/presentation/screens/album_Screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/albums_result_screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/artist_detail_screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/artists_result_screen.dart';
import 'package:jazz/features/search_feature/presentation/screens/collapsed_current_song.dart';
import 'package:jazz/features/search_feature/presentation/screens/expanded_current_song.dart';
import 'package:jazz/features/search_feature/presentation/screens/songs_result_screen.dart';
import 'package:jazz/features/search_feature/presentation/widgets/search_suggestion_widget.dart';
import 'package:jazz/features/search_feature/presentation/widgets/user_selection_bottom_sheet.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';
import 'package:jazz/features/stream_feature/presentation/screens/streamScreen.dart';

import '../../../../core/widgets/custom_snack_bar.dart';
import '../widgets/share_user_selection.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>{
  final TextEditingController _controller = TextEditingController();
  final DraggableScrollableController _scrollableController = DraggableScrollableController();
  final FocusNode _focusNode = FocusNode();

  // Recent searches and suggestions state
  List<String> _recentSearches = [];
  List<String> _suggestions = [];
  List<String> _filteredRecentSearches = [];
  bool _isTyping = false;
  bool _showSearchResults = false;

  void _expandBox() {
    _scrollableController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Load recent searches from Firebase
  Future<void> _loadRecentSearches() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc = await FirebaseFirestore.instance.collection("Users").doc(userId).get();
        if (doc.exists && doc.data()?['searchHistory'] != null) {
          setState(() {
            _recentSearches = List<String>.from(doc.data()!['searchHistory']).reversed.take(10).toList();
          });
        }
      }
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  // Remove recent search
  Future<void> _removeRecentSearch(String searchTerm) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance.collection("Users").doc(userId).update({
          "searchHistory": FieldValue.arrayRemove([searchTerm])
        });
        setState(() {
          _recentSearches.remove(searchTerm);
        });
      }
    } catch (e) {
      print('Error removing search term: $e');
    }
  }

  // FIXED: Generate suggestions based on input and remove duplicates with recent searches
  void _generateSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _filteredRecentSearches = [];
        _isTyping = false;
      });
      return;
    }

    setState(() {
      _isTyping = true;

      // Filter recent searches that match the query
      _filteredRecentSearches = _recentSearches
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Generate common suggestions
      List<String> commonSuggestions = [
        query,
        '${query} songs',
        '${query} artist',
        '${query} album',
        '${query} lyrics',
      ];

      // FIXED: Remove duplicates - filter out suggestions that are already in recent searches
      _suggestions = commonSuggestions
          .where((suggestion) => !_recentSearches.any((recent) =>
      recent.toLowerCase() == suggestion.toLowerCase()))
          .take(6)
          .toList();
    });
  }

  // Build recent searches widget (when not typing)
  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No recent searches',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Recent Searches',
            style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7)),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentSearches.length,
          itemBuilder: (context, index) {
            final searchTerm = _recentSearches[index];
            return ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: Text(searchTerm,style: TextStyle(color: Colors.grey),),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => _removeRecentSearch(searchTerm),
              ),
              onTap: () {
                _controller.text = searchTerm;
                _performSearch(searchTerm);
              },
            );
          },
        ),
      ],
    );
  }

  // FIXED: Build suggestions widget (when typing) - shows filtered recent + unique suggestions
  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show filtered recent searches first (if any)
        if (_filteredRecentSearches.isNotEmpty) ...[

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredRecentSearches.length,
            itemBuilder: (context, index) {
              final searchTerm = _filteredRecentSearches[index];
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(searchTerm,style: TextStyle(color: Colors.grey),),
                trailing: IconButton(
                  icon: const Icon(Icons.north_west, color: Colors.grey),
                  onPressed: () {
                    _controller.text = searchTerm;
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                  },
                ),
                onTap: () {
                  _controller.text = searchTerm;
                  _performSearch(searchTerm);
                },
              );
            },
          ),
        ],

        // Show unique suggestions
        if (_suggestions.isNotEmpty) ...[
          if (_filteredRecentSearches.isNotEmpty)

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _suggestions[index];
              return ListTile(
                leading: const Icon(Icons.search, color: Colors.grey),
                title: Text(suggestion,style: TextStyle(color: Colors.grey),),
                trailing: const Icon(Icons.north_west, color: Colors.grey),
                onTap: () {
                  _controller.text = suggestion;
                  _performSearch(suggestion);
                },
              );
            },
          ),
        ],
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    _loadRecentSearches();

    _controller.addListener(() {
      _generateSuggestions(_controller.text);
    });

    _scrollableController.addListener(() {
      if (_scrollableController.size > 0.15) {
        context.read<CurrentSongWidgetBloc>().add(CurrentSongWidgetExpandEvent());
      } else if (_scrollableController.size < 0.14) {
        context.read<CurrentSongWidgetBloc>().add(CurrentSongWidgetCollapseEvent());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollableController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _showSearchResults = true;
      _isTyping = false;
    });

    context.read<SongBloc>().add(SearchForSongs(query));
    context.read<SearchSuggestionBloc>().add(ClearSearchSuggestionsEvent());

    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection("Users").doc(userId).update({
      "searchHistory": FieldValue.arrayUnion([query])
    });

    _loadRecentSearches();
    _focusNode.unfocus();
  }

  void showUserSelectionBottomSheet(BuildContext context,Song song) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return UserSelectionBottomSheet(song: song,);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di<DownloadBloc>(),
      child: InternetConnectionWrapper(
        child: Scaffold(
          backgroundColor: AppColors.primaryBackgroundColor,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              SafeArea(
                child: BlocListener<DownloadBloc, DownloadState>(
                  listener: (context, state) {
                    if (state is DownloadOnProgress){
                      print("Progress : ${state.progress}");
                    }else if (state is DownloadPaused){
                      print("Paused");
                    }
                    else if (state is DownloadFinished){
                      print("Downloading Finished");
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      SizedBox(height: 16.h,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text("Explore",style: TextStyle(color: Colors.white,fontSize: 20),),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(25.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Search for songs, artists, albums...',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[600],
                                size: 24,
                              ),
                              suffixIcon: _controller.text.isNotEmpty
                                  ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() {
                                    _isTyping = false;
                                    _showSearchResults = false;
                                  });
                                },
                              )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onSubmitted: (value) {
                              _performSearch(value);
                            },
                          ),
                        ),
                      ),

                      // Main Content Area
                      Expanded(
                        child: _buildMainContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_showSearchResults) {
      return BlocBuilder<SongBloc, SongState>(
        builder: (context, state) {
          if (state is SongLoading) {
            return  Center(child: CircularProgressIndicator(color: Colors.white,));
          } else if (state is SongLoaded) {
            List<Song> songs = state.songs.where((s)=> s.category == "Songs").toList();
            dynamic topResult = state.songs.where((s)=> s.category == "Top result").toList().isNotEmpty ?state.songs.where((s)=> s.category == "Top result").first: null ;
            List albums = state.songs.where((s)=> s.category == "Albums").toList();
            List artists = state.songs.where((s)=> s.category == "Artists").toList();

            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                if(topResult != null)
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Top Result", style: TextStyle(fontSize: 22, color: Colors.white)),
                        ),
                      ),
                      ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(topResult.thumbnails.defaultThumbnail.url, width: 50, height: 50, fit: BoxFit.cover),
                        ),
                        title: topResult.resultType != "artist" ?  Text(topResult.title,style: TextStyle(color: Colors.white),): Text(topResult.artists.map((artist)=> artist["name"]).join(","),style: TextStyle(color: Colors.white),),
                        subtitle:topResult.resultType != "artist" ?
                        Text("${topResult.resultType == 'video' ? "song" : topResult.resultType} • ${topResult.artists.map((artist)=> artist['name']).join(",")}", style: TextStyle(color: Colors.white.withOpacity(0.7)),)
                            : Text(topResult.resultType,style: TextStyle(color: Colors.white.withOpacity(0.7)),),
                        onTap: (){
                          if(topResult.resultType == "song" || topResult.resultType == "video"){
                            final isFromAlbum = context.read<PlayerBloc>().state.isFromAlbum;
                            if(isFromAlbum){
                              context.read<PlayerBloc>().add(UpdateStateEvent(state: context.read<PlayerBloc>().state.copyWith(isFromAlbum: false)));
                            }
                            context.read<PlayerBloc>().add(PlaySongEvent(song: dartz.left(topResult)));
                          }else if(topResult.resultType == "album"){
                            context.read<AlbumBloc>().add(SearchAlbum(albumId: topResult.browseId));
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return const AlbumScreen();
                            }));
                          }else if(topResult.resultType == "artist"){
                            context.read<ArtistBloc>().add(FetchArtistEvent(artistId: topResult.browseId));
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return  ArtistDetailScreen(artistId: topResult.browseId,);
                            }));
                          }
                        },
                      ),
                    ],
                  ),

                // Songs Section

               _buildSectionHeaderWithViewAll(context, "Songs", (){
                 context.read<SearchBloc>().add(SearchSongsRequested(query: _controller.text));
                           Navigator.pushNamed(context, Routes.songsResultScreen);
               }),

                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: songs.length <5 ? songs.length: 5,
                    itemBuilder: (context, index) {

                      final Song song = songs[index];
                      return songWidget(context: context, song: song);
                    }),

                // Albums Section
                if(albums.isNotEmpty) ...[
                   _buildSectionHeaderWithViewAll(context, "Albums", (){

                   }),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 250.h,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount: albums.length<5 ? albums.length : 5,
                          itemBuilder: (context,index){
                            final Song album = albums[index];
                            return   GestureDetector(
                              onTap: (){
                                context.read<AlbumBloc>().add(SearchAlbum(albumId: album.browseId));
                                Navigator.pushNamed(context, Routes.albumScreen);
                              },
                              child: Container(
                                width: 170.w,
                                margin: const EdgeInsets.only(right: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 160,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(album.thumbnails.highThumbnail.url),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      album.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      album.artists.map((artist)=> artist['name']).join(","),
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                ],

                // Artists Section
                if(artists.isNotEmpty) ...[
                  _buildSectionHeaderWithViewAll(context, "Artists", (){

                  }),
          Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
          height: 250.h,
          child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: artists.length<5 ? artists.length : 5,
          itemBuilder: (context,index){
          final Song artist = artists[index];
          return   GestureDetector(
          onTap: (){

          context.read<ArtistBloc>().add(FetchArtistEvent(artistId: artist.browseId));
          Navigator.pushNamed(context, Routes.artistDetailScreen,arguments: {"artistId": artist.browseId});
          },
          child: Container(
          width: 170.w,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(
          height: 160,
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
          image: NetworkImage(artist.thumbnails.highThumbnail.url),
          fit: BoxFit.cover,
          ),
          ),
          ),
          const SizedBox(height: 12),

          Text(
          artist.artists.map((artist)=> artist['name']).join(","),
          style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          ),

          ],
          ),
          ),
          );
          }),
          ),
          ),
                ],
              ],
            );
          } else if (state is SongError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      );
    } else if (_isTyping && (_filteredRecentSearches.isNotEmpty || _suggestions.isNotEmpty)) {
      return _buildSuggestions();
    } else {
      return _buildRecentSearches();
    }
  }
  Widget _buildSectionHeaderWithViewAll(BuildContext context, String title, VoidCallback onViewAllTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,

            ),
          ),
          GestureDetector(
            onTap: onViewAllTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'VIEW ALL',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
