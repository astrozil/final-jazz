import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/dependency_injection.dart';
import 'package:jazz/core/routes.dart';

import 'package:jazz/core/widgets/song_widget.dart';
import 'package:jazz/features/download_feature/presentation/bloc/download/download_bloc.dart';

import 'package:jazz/features/internet_connection_checker/presentation/screens/internet_connection_wrapper.dart';

import 'package:jazz/features/search_feature/domain/entities/song.dart';

import 'package:jazz/features/search_feature/presentation/bloc/albumBloc/album_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/artist_bloc/artist_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/currentSongWidgetBloc/current_song_widget_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search/search_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search_suggestion_bloc/search_suggestion_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/song/song_bloc.dart';
import 'package:jazz/features/search_feature/presentation/screens/album_Screen.dart';

import 'package:jazz/features/search_feature/presentation/screens/artist_detail_screen.dart';

import 'package:jazz/features/search_feature/presentation/widgets/user_selection_bottom_sheet.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

import '../../../../core/widgets/section_header_with_view_all.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>{
  final TextEditingController _controller = TextEditingController();
  final DraggableScrollableController _scrollableController = DraggableScrollableController();
  final FocusNode _focusNode = FocusNode();

  // Recent searches state
  List<String> _recentSearches = [];
  List<String> _filteredRecentSearches = [];
  bool _isTyping = false;
  bool _showSearchResults = false;

  Future<void> _loadRecentSearches() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final doc = await FirebaseFirestore.instance.collection("Users").doc(userId).get();
      if (doc.exists && doc.data()?['searchHistory'] != null) {
        setState(() {
          // FIXED: Limit to 5 recent searches
          _recentSearches = List<String>.from(doc.data()!['searchHistory']).reversed.take(5).toList();
        });
      }
    }
  }

  // Remove recent search
  Future<void> _removeRecentSearch(String searchTerm) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance.collection("Users").doc(userId).update({
        "searchHistory": FieldValue.arrayRemove([searchTerm])
      });
      setState(() {
        _recentSearches.remove(searchTerm);
      });
    }
  }

  // Handle text input changes
  void _onTextChanged(String query) {
    setState(() {
      _isTyping = query.isNotEmpty;

      if (query.isEmpty) {
        _filteredRecentSearches = [];
        context.read<SearchSuggestionBloc>().add(ClearSearchSuggestionsEvent());
      } else {
        // Filter recent searches that match the query
        _filteredRecentSearches = _recentSearches
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();

        // Get suggestions from bloc
        context.read<SearchSuggestionBloc>().add(GetSearchSuggestionEvent( query));
      }
    });
  }

  // Build recent searches widget (when not typing) - FIXED: Limited to 5 items
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
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Recent Searches',
            style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7)),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // FIXED: Limit itemCount to maximum 5 items
          itemCount: math.min(_recentSearches.length, 5),
          itemBuilder: (context, index) {
            final searchTerm = _recentSearches[index];
            return ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: Text(searchTerm,style: const TextStyle(color: Colors.grey),),
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

  // Build suggestions widget (when typing) - shows filtered recent + bloc suggestions
  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show filtered recent searches first (if any)
        if (_filteredRecentSearches.isNotEmpty) ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // FIXED: Also limit filtered recent searches to 5
            itemCount: math.min(_filteredRecentSearches.length, 5),
            itemBuilder: (context, index) {
              final searchTerm = _filteredRecentSearches[index];
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(searchTerm,style: const TextStyle(color: Colors.grey),),
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

        // Show bloc suggestions
        BlocBuilder<SearchSuggestionBloc, SearchSuggestionState>(
          builder: (context, state) {
            if (state is SearchSuggestionLoading) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              );
            } else if (state is SearchSuggestionLoaded) {
              final suggestions = state.suggestions.cast<String>();

              // Filter out suggestions that are already in recent searches to avoid duplicates
              final uniqueSuggestions = suggestions
                  .where((suggestion) => !_recentSearches.any((recent) =>
              recent.toLowerCase() == suggestion.toLowerCase()))
                  .toList();

              if (uniqueSuggestions.isEmpty) {
                return const SizedBox.shrink();
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: uniqueSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = uniqueSuggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.search, color: Colors.grey),
                    title: Text(suggestion, style: const TextStyle(color: Colors.grey),),
                    trailing: IconButton(
                      icon: const Icon(Icons.north_west, color: Colors.grey),
                      onPressed: () {
                        _controller.text = suggestion;
                        _controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: _controller.text.length),
                        );
                      },
                    ),
                    onTap: () {
                      _controller.text = suggestion;
                      _performSearch(suggestion);
                    },
                  );
                },
              );
            } else if (state is SearchSuggestionError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading suggestions: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    _loadRecentSearches();

    _controller.addListener(() {
      _onTextChanged(_controller.text);
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
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
                                context.read<SearchSuggestionBloc>().add(ClearSearchSuggestionsEvent());
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
    );
  }

  Widget _buildMainContent() {
    if (_showSearchResults) {
      return BlocBuilder<SongBloc, SongState>(
        builder: (context, state) {
          if (state is SongLoading) {
            return  const Center(child: CircularProgressIndicator(color: Colors.white,));
          } else if (state is SongLoaded) {
            List<Song> songs = state.songs.where((s)=> s.category == "Songs").toList();
            dynamic topResult = state.songs.where((s)=> s.category == "Top result").toList().isNotEmpty ?state.songs.where((s)=> s.category == "Top result").first: null ;
            List albums = state.songs.where((s)=> s.category == "Albums").toList();
            List artists = state.songs.where((s)=> s.category == "Artists").toList();

            return ListView(
              physics: const BouncingScrollPhysics(),
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
                        title: topResult.resultType != "artist" ?  Text(topResult.title,style: const TextStyle(color: Colors.white),): Text(topResult.artists.map((artist)=> artist["name"]).join(","),style: const TextStyle(color: Colors.white),),
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
                            Navigator.pushNamed(context, Routes.albumScreen);
                          }else if(topResult.resultType == "artist"){
                            context.read<ArtistBloc>().add(FetchArtistEvent(artistId: topResult.artists[0]['id']));
                            Navigator.pushNamed(context, Routes.artistDetailScreen,arguments: {"artistId":topResult.artists[0]['id']});
                          }
                        },
                      ),
                    ],
                  ),

                // Songs Section
                buildSectionHeaderWithViewAll(context, "Songs", (){
                  context.read<SearchBloc>().add(SearchSongsRequested(query: _controller.text));
                  Navigator.pushNamed(context, Routes.songsResultScreen);
                }),

                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: songs.length <5 ? songs.length: 5,
                    itemBuilder: (context, index) {

                      final Song song = songs[index];
                      return songWidget(context: context, song: song);
                    }),

                // Albums Section
                if(albums.isNotEmpty) ...[
                  buildSectionHeaderWithViewAll(context, "Albums", (){
                    context.read<SearchBloc>().add(SearchAlbumsRequested(query: _controller.text));
                    Navigator.pushNamed(context, Routes.albumsResultScreen);
                  }),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 250.h,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
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
                  buildSectionHeaderWithViewAll(context, "Artists", (){
                    context.read<SearchBloc>().add(SearchArtistsRequested(query: _controller.text));
                    Navigator.pushNamed(context, Routes.artistsResultScreen);
                  }),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 250.h,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
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
    } else if (_isTyping && (_filteredRecentSearches.isNotEmpty || _controller.text.isNotEmpty)) {
      return _buildSuggestions();
    } else {
      return _buildRecentSearches();
    }
  }
}
