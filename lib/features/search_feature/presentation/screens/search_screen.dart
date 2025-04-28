import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/dependency_injection.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/core/widgets/app_with_player.dart';

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
// import 'package:jazz/features/stream_feature/presentation/bloc/mp3StreamBloc/mp3_stream_bloc.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';

import 'package:jazz/features/stream_feature/presentation/screens/streamScreen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>{
  final TextEditingController _controller = TextEditingController();
  final DraggableScrollableController _scrollableController = DraggableScrollableController();
  final FocusNode _focusNode = FocusNode();




  void _expandBox() {
    _scrollableController.animateTo(
      1.0, // Full expansion
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
  // void _collapseBox() {
  //   _scrollableController.animateTo(
  //     0.13, // Collapse back to minimum size
  //     duration: Duration(milliseconds: 500),
  //     curve: Curves.easeInOut,
  //   );
  // }
 @override
 void initState() {
    // TODO: implement initState
    super.initState();
    _scrollableController.addListener(() {
      // Check the size of the sheet
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

    context.read<SongBloc>().add(SearchForSongs(query));
    context.read<SearchSuggestionBloc>().add(ClearSearchSuggestionsEvent());
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection("Users").doc(userId).update({
      "searchHistory": FieldValue.arrayUnion([query])
    });

    _focusNode.unfocus();
  }
  void showUserSelectionBottomSheet(BuildContext context,Song song) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
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

  child: InternetConnectionWrapper (
    child: Scaffold(

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
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              decoration: InputDecoration(
                                hintText: 'Search YouTube',
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: () async{

                                    _performSearch(_controller.text);
                                  },
                                ),
                              ),
                              onSubmitted: (value) {
                                _performSearch(value);
                              },
                            ),
                          ),
                          ElevatedButton(onPressed: (){
                  Navigator.pushNamed(context, Routes.profileScreen);
                          }, child: Icon(Icons.person))
                        ],
                      ),

                    ),
                    SearchSuggestion(
                      controller: _controller,
                      focusNode: _focusNode,
                      onSearch: (query){
                      _performSearch(query);
                      },
                    ),
                    Expanded(
                      child: BlocBuilder<SongBloc, SongState>(
                        builder: (context, state) {
                          if (state is SongLoading) {
                            return Center(child: CircularProgressIndicator());
                          } else if (state is SongLoaded) {

                            List<Song> songs = state.songs.where((s)=> s.category == "Songs").toList();
                            dynamic topResult =   state.songs.where((s)=> s.category == "Top result").toList().isNotEmpty ?state.songs.where((s)=> s.category == "Top result").first: null ;
                            List videos = state.songs.where((s)=> s.category == "Videos").toList();
                            List albums = state.songs.where((s)=> s.category == "Albums").toList();
                            List artists = state.songs.where((s)=> s.category == "Artists").toList();
                            List featured_playlists = state.songs.where((s)=> s.category == "Featured Playlists").toList();
                            List community_playlists = state.songs.where((s)=> s.category == "Community Playlists").toList();
                          return ListView(
                            children: [
                             if(topResult != null)
                               Column(
                                 children: [
                                   Text("Top Result"),
                                   ListTile(
                                     leading: Image.network(topResult.thumbnails.defaultThumbnail.url),
                                     title: topResult.resultType != "artist" ?  Text(topResult.title): Text(topResult.artists.first['name']),
                                     subtitle:topResult.resultType != "artist" ?
                                     Text("${topResult.resultType == 'video' ? "song" : topResult.resultType} . ${topResult.artists.first['name']}")
                                         : Text(topResult.resultType),
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
                                           return AlbumScreen();
                                         }));
                                       }else if(topResult.resultType == "artist"){
                                         context.read<ArtistBloc>().add(FetchArtistEvent(artistId: topResult.browseId));
                                         Navigator.push(context, MaterialPageRoute(builder: (context){
                                           return ArtistDetailScreen();
                                         }));
                                       }
                                     },
                                   ),
                                 ],
                               ),



                              Row(
                                children: [
                                  Text("Songs"),
                                  ElevatedButton(onPressed: (){
                                  context.read<SearchBloc>().add(SearchSongsRequested(query: _controller.text));
                                  Navigator.push(context, MaterialPageRoute(builder: (context){
                                    return SongsResultScreen();
                                  }));
                                  }, child: Text("See all"))
                                ],
                              ),

                              ListView.builder(
                                shrinkWrap: true,
                                  itemCount: songs.length <3? songs.length : 3,
                                  itemBuilder: (context,index){
                                  var song = songs[index];
                                    return InkWell(
                                      onTap: (){
                                        // context.read<RelatedSongBloc>().add(FetchRelatedSongEvent(song.id));
                                        // Navigator.push(context, MaterialPageRoute(builder: (context){
                                        //   return StreamScreen();
                                        // }));
                                        final isFromAlbum = context.read<PlayerBloc>().state.isFromAlbum;
                                        if(isFromAlbum){
                                          context.read<PlayerBloc>().add(UpdateStateEvent(state: context.read<PlayerBloc>().state.copyWith(isFromAlbum: false)));
                                        }
                                        context.read<PlayerBloc>().add(PlaySongEvent(song: dartz.left(song)));
                                      },
                                      child: ListTile(
                                          leading: ClipRRect(child: Image(image: NetworkImage(song.thumbnails.defaultThumbnail.url)),borderRadius: BorderRadius.circular(5),),
                                          title: Text(song.title),
                                          subtitle: Text( song.artists
                                              .map((artist) => artist['name'] as String)
                                              .join(', '),),
                                          trailing:
                                          ElevatedButton(onPressed: (){
                                            context.read<DownloadedOrNotBloc>().add(CheckIfDownloadedEvent(song.id,song.title,song.artists.first['name']));
                                            showModalBottomSheet(
                                              context: context,
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                              ),
                                              builder: (BuildContext contextt) {
                                                return Container(
                                                  width: double.infinity,
                                                  height: 300,
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                                  ),
                                                  child: Column(

                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [

                                                      BlocBuilder<DownloadedOrNotBloc, DownloadedOrNotState>(
                                                        builder: (context, state) {
                                                          return ElevatedButton(
                                                            onPressed: () {
                                                              if(state is DownloadedSongState){
                                                                context.read<DownloadedOrNotBloc>().add(DeleteDownloadedSongEvent(song.id, song.title,song.artists.first['name']));
                                                                Navigator.pop(context);
                                                              }else if(state is NotDownloadedSongState){
                                                                context.read<DownloadBloc>().add(
                                                                    DownloadSongEvent(DownloadRequest(videoID:song.id,title: song.title,artist: song.artists.first['name'],thumbnail:song.thumbnails.defaultThumbnail.url,videoUrl: song.url)));
                                                              }
                                                            },
                                                            child: state is DownloadedSongState? const Text('Remove from download'): const Text("Download"),
                                                          );
                                                        },
                                                      ),
                                                      ElevatedButton(onPressed: (){
                                                        context.read<DownloadedSongsBloc>().add(GetDownloadedSongsEvent());
                                                        Navigator.push(context, MaterialPageRoute(builder: (context){
                                                          return DownloadedSongsScreen();
                                                        }));
                                                      }, child: Text("Go To Downloaded Songs")),
                                                      ElevatedButton(onPressed: (){
                                                        showUserSelectionBottomSheet(context,song);
                                                      }, child: Text("Share")),

                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          }, child: Text("More"))



                                      ),
                                    );
                                  }),
                              Row(
                                children: [
                                  Text("Albums"),
                                  ElevatedButton(onPressed: (){
                                    context.read<SearchBloc>().add(SearchAlbumsRequested(query: _controller.text));
                                    Navigator.push(context, MaterialPageRoute(builder: (context){
                                      return AlbumsResultScreen();
                                    }));
                                  }, child: Text("See all"))
                                ],
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: albums.length<3 ? albums.length : 3,
                                  itemBuilder: (context,index){
                                    return InkWell(
                                      onTap: (){

                                        context.read<AlbumBloc>().add(SearchAlbum(albumId: albums[index].browseId));
                                        Navigator.push(context, MaterialPageRoute(builder: (context){
                                          return AlbumScreen();
                                        }));
                                      },
                                      child: ListTile(
                                        leading: Image.network(albums[index].thumbnails.defaultThumbnail.url),
                                        title: Text(albums[index].title),
                                      ),
                                    );
                                  }),
                              Row(
                                children: [
                                  Text("Artists"),
                                  ElevatedButton(onPressed: (){
                                    context.read<SearchBloc>().add(SearchArtistsRequested(query: _controller.text));
                                    Navigator.push(context, MaterialPageRoute(builder: (context){
                                      return ArtistsResultScreen();
                                    }));
                                  }, child: Text("See all"))
                                ],
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: artists.length <3 ? artists.length: 3,
                                  itemBuilder: (context,index){
                                    return ListTile(
                                      leading: Image.network(artists[index].thumbnails.defaultThumbnail.url),
                                      title: Text(artists[index].artists.first['name']),
                                      onTap: (){
                                        context.read<ArtistBloc>().add(FetchArtistEvent(artistId: artists[index].browseId));
                                        Navigator.push(context, MaterialPageRoute(builder: (context){
                                          return ArtistDetailScreen();
                                        }));
                                      },
                                    );
                                  }),
                            ],
                          );

                          } else if (state is SongError) {
                            return Center(child: Text(state.message));
                          }
                          return Center(child: Column(
                            children: [
                              ElevatedButton(onPressed: (){
                              context.read<PlaylistBloc>().add(FetchTrendingSongsPlaylistEvent());
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> const TrendingSongsPlaylistScreen()));
                              }, child:Text("Trending Songs Playlist") ),
                              ElevatedButton(onPressed: (){
                                context.read<PlaylistBloc>().add(FetchBillboardSongsPlaylistEvent());
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> const BillboardSongsPlaylistScreen()));
                              }, child:Text("Billboard Songs Playlist") ),
                              ElevatedButton(onPressed: () {
                                context.read<PlaylistBloc>().add(FetchFavouriteSongsPlaylistEvent());
                                Navigator.pushNamed(context, Routes.favouriteSongsPlaylistScreen);
                              }
                                  , child: Text("Favourite Songs")),
                              ElevatedButton(onPressed: (){
                                context.read<PlaylistBloc>().add(FetchPlaylists());
                                Navigator.pushNamed(context, Routes.userPlaylistScreen);
                              }, child: Text("Playlists")),
                              ElevatedButton(onPressed: (){
                                context.read<PlaylistBloc>().add(FetchRecommendedSongsPlaylist());
                               Navigator.pushNamed(context, Routes.recommendedSongsPlaylistScreen);
                              }, child: Text("Recommended Songs")),
                              ElevatedButton(onPressed: (){
                                Navigator.pushNamed(context, Routes.userSearchScreen);
                              }, child: Text("Search Users")),
                              BlocListener<AuthBloc, AuthState>(
    listener: (context, state) {
     if(state is UserDataFetched){
       final artistIds = state.user.favouriteArtists.join(",");
       context.read<PlaylistBloc>().add(FetchSuggestedSongsOfFavouriteArtists(artistIds:artistIds ));
     }
    },
    child: ElevatedButton(onPressed: (){
                               context.read<AuthBloc>().add(FetchUserDataEvent());
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> const SuggestedSongsOfFavouriteArtistsPlaylistScreen()));
                              }, child:Text("Suggested Songs Playlist") ),
    )
                            ],
                          ));
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),
      //
            BlocBuilder<PlayerBloc, Player>(
        builder: (context, state) {

     if(state is PlayerState) {

    if(state.currentSong != null){
     return Positioned.fill(

       child: DraggableScrollableSheet(
         controller: _scrollableController,
         minChildSize: 0.13,
         maxChildSize: 1.0,
         initialChildSize: 0.13,
         snap: true,
         snapSizes: const [0.13, 1.0],
         builder: (context, scrollController) {
           return GestureDetector(

             onTap: () {
               if (_scrollableController.size == 0.13) {
                 _expandBox();
               }
             },

             child: Container(
               color: Colors.white,

               child: ListView(
                 controller: scrollController,
                 children: [


                   BlocBuilder<CurrentSongWidgetBloc, CurrentSongWidgetState>(
                     builder: (context, state) {
                       if (state is CurrentSongWidgetCollapseState) {
                         return const CollapsedCurrentSong();
                       } else if (state is CurrentSongWidgetExpandState) {
                         return  ExpandedCurrentSong();
                       }
                       return const SizedBox();
                     },
                   ),

                 ],
               ),
             ),
           );
         },
       ),
     );
     }}
         return const SizedBox();
        },
      ),
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return AppWithPlayer(child: DownloadScreen());
          }));
        }),

      ),
  ),
);
  }
}