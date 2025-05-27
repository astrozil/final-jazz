import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/core/widgets/confirm_widget.dart';
import 'package:jazz/features/playlist_feature/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class UserPlaylistScreen extends StatefulWidget {
  const UserPlaylistScreen({super.key});

  @override
  State<UserPlaylistScreen> createState() => _UserPlaylistScreenState();
}

class _UserPlaylistScreenState extends State<UserPlaylistScreen> {
  final TextEditingController _controller = TextEditingController();
  final Set<String> _selectedPlaylists = {};
  bool _isSelectionMode = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Create New Playlist'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Enter playlist name',
              prefixIcon: Icon(Icons.playlist_add),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<PlaylistBloc>().add(CreatePlaylist(_controller.text));
                _controller.clear();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteSelected() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Playlists"),
        content: Text(
          "Are you sure you want to delete ${_selectedPlaylists.length} selected playlist${_selectedPlaylists.length > 1 ? 's' : ''}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteSelected();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _deleteSelected() {
    for (final id in _selectedPlaylists) {
      context.read<PlaylistBloc>().add(DeletePlaylist(id));
    }
    setState(() {
      _selectedPlaylists.clear();
      _isSelectionMode = false;
    });
  }

  void _handleLongPress(String id) {
    setState(() {
      _isSelectionMode = true;
      _selectedPlaylists.add(id);
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedPlaylists.contains(id)) {
        _selectedPlaylists.remove(id);
        if (_selectedPlaylists.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedPlaylists.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.primaryBackgroundColor,

      appBar: AppBar(
      centerTitle: true,
        backgroundColor: AppColors.primaryBackgroundColor,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_new_outlined,color: Colors.white,),
        ),
        title: Text("Playlists",style: TextStyle(color: Colors.white),),

      ),
      body: Column(
        children: [
          SizedBox(height: 10.h,),
GestureDetector(
  onTap: (){
    Navigator.pushNamed(context, Routes.newPlaylistScreen);
  },
  child: ListTile(


    leading: Container(
      height: 60.h,
      width: 60.w,
      decoration: BoxDecoration(
        color: AppColors.primaryForegroundColor,
        borderRadius: BorderRadius.circular(15.r)
      ),
      child: Icon(Icons.add,size: 30.sp,color: Colors.white,),
    ),
    title: Text("Create...",style: TextStyle(color: Colors.white,fontSize: 18.sp),),
  ),
),
          SizedBox(height: 10.h,),
          BlocBuilder<PlaylistBloc, PlaylistState>(
            builder: (context, state) {
              if (state is PlaylistInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PlaylistLoaded && !state.isLoading) {
                final playlists = state.userPlaylists;

                if (playlists.isEmpty) {

                }

                return Expanded(
                  child: ListView.builder(
                  
                  
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      final id = playlist['playlistId'];
                      final isSelected = _selectedPlaylists.contains(id);
                  
                      return GestureDetector(
                        onTap: (){
                          // context.read<PlaylistBloc>().add(FetchPlaylist(playlistId: playlist["playlistId"]));
                          context.read<PlaylistBloc>().add(FetchSongsFromSongIdList(songIdList: playlist['tracks'],playlistId: playlist["playlistId"]));
                          Navigator.pushNamed(context, Routes.specifiedUserPlaylist,);
                        },
                        child: ListTile(
                          leading: Image.asset("assets/icons/playlist.png",color: AppColors.secondaryForegroundColor,height: 60.h,width: 60.w,fit: BoxFit.contain,),
                          title: Text(playlist['title'],style: TextStyle(color: Colors.white),),
                          subtitle: Text("${playlist['tracks'].length} tracks",style: TextStyle(color: Colors.white.withOpacity(0.7)),),
                           trailing: GestureDetector(
                             onTap: (){
                  
                             },
                             child: GestureDetector(
                                 onTap: (){
                                   showModalBottomSheet(context: context,


                                       enableDrag: true,

                                       backgroundColor: Color.fromRGBO(
                                           37, 39, 40, 1),
                                       shape: RoundedRectangleBorder(
                                           borderRadius:
                                           BorderRadius.vertical(
                                               top:
                                               Radius.circular(
                                                   20))),
                                       builder: (context){
                                       return Column(
                                         mainAxisSize: MainAxisSize.min,
                                         children: [
                                           Padding(
                                             padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                             child: Row(

                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                               children: [
                                                 SizedBox(width: 80.w,),
                                                 Container(
                                                   margin: const EdgeInsets.only(top: 8),
                                                   height: 4,
                                                   width: 40,
                                                   decoration: BoxDecoration(
                                                     color: Colors.grey[300],
                                                     borderRadius: BorderRadius.circular(2),
                                                   ),
                                                 ),
                                                 TextButton(
                                                   onPressed: () {
                                                     Navigator.pop(context);
                                                   },
                                                   child:  Text('Cancel',style: TextStyle(color: Colors.white.withOpacity(0.8)),),
                                                 ),
                                               ],
                                             ),
                                           ),
                                           SizedBox(height: 30.h,),
                                         Padding(
                                         padding: const EdgeInsets.all(16.0),
                                         child: InkWell(
                                         splashFactory: NoSplash.splashFactory,
                                         highlightColor: Colors.transparent,
                                         onTap: (){
                                         Navigator.pop(context);
                                         Navigator.pushNamed(context, Routes.userPlaylistTitleUpdateScreen,arguments: {"playlistTitle": playlist["title"] ,"playlistId": playlist["playlistId"]});
                                         },
                                         child: Row(
                                         children: [
                                         Icon(Icons.edit,color: Colors.white,),
                                         SizedBox(width: 20.w,),
                                         Text("Edit the playlist", style: TextStyle(color: Colors.white, fontSize: 18.sp ),)
                                         ],
                                         ),
                                         ),
                                         ),
                                           Padding(
                                             padding: const EdgeInsets.all(16.0),
                                             child: InkWell(
                                               splashFactory: NoSplash.splashFactory,
                                               highlightColor: Colors.transparent,
                                               onTap: (){
                                                 showDialog(context: context, builder: (context){
                                                   return confirmWidget(context: context,
                                                       title: "Delete playlist?",
                                                       text: "This playlist will be permanently deleted.",
                                                       confirmButton: ElevatedButton(
                                                           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                           onPressed: (){
                                                             Navigator.pop(context);
                                                             Navigator.pop(context);
                                                             context.read<PlaylistBloc>().add(DeletePlaylist(playlist["playlistId"]));
                                                             context.read<PlaylistBloc>().add(FetchPlaylists());
                                                           },
                                                           child: Text("Delete",style: TextStyle(color: Colors.white),)));
                                                 });
                                               },
                                               child: Row(
                                                 children: [
                                                 Image.asset("assets/icons/delete.png",color: Colors.red,height: 30.h,width: 30.w,),
                                                   SizedBox(width: 20.w,),
                                                   Text("Delete the playlist", style: TextStyle(color: Colors.white, fontSize: 18.sp ),)
                                                 ],
                                               ),
                                             ),
                                           ),
                                           SizedBox(height: 50.h,)
                                         ],
                                       );
                                       });
                                 },
                                 child: Icon(Icons.more_horiz_outlined,color: Colors.white,)),
                           ),
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),

    );
  }
}
