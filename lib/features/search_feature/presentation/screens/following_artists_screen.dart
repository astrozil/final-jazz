import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/app_color.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/artist_bloc/artist_bloc.dart';

class FollowingArtistsScreen extends StatefulWidget {
  const FollowingArtistsScreen({super.key});

  @override
  State<FollowingArtistsScreen> createState() => _FollowingArtistsScreenState();
}

class _FollowingArtistsScreenState extends State<FollowingArtistsScreen> {
  @override
  void initState() {
    context.read<AuthBloc>().add(FetchUserDataEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UserDataFetched){
          context.read<ArtistBloc>().add(FetchArtistsEvent(artistIdList: state.user.favouriteArtists));
          print(state.user.favouriteArtists);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackgroundColor,
       appBar: AppBar(
         backgroundColor: AppColors.primaryBackgroundColor,
         title: Text("Following Artists",style: TextStyle(fontSize: 20,color: Colors.white),),
         leading: GestureDetector(
           onTap: (){
             Navigator.pop(context);
           },
           child: Icon(Icons.arrow_back_ios_new_outlined,color: Colors.white,),
         ),
       ),
        body: BlocBuilder<ArtistBloc, ArtistFetchSuccess>(

          builder: (context, state) {
            if(state.isLoading){
              return Center(child: CircularProgressIndicator(color: Colors.white,),);
            }else if(!state.isLoading){
               List artists = [];
            if(state.artists!= null){
              artists = state.artists!;
            }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: artists.length,
                  itemBuilder: (context,index) {
                   final  Map<String,dynamic> artist = artists[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        onTap: (){
                        context.read<ArtistBloc>().add(FetchArtistEvent(artistId: artist['browseId']));
                        Navigator.pushNamed(context, Routes.artistDetailScreen,arguments: {'artistId':artist['browseId']});
                        },

                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                artist['thumbnail']['url'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(artist['name'],style: TextStyle(color: Colors.white),),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              );
            }
            return const SizedBox();
          }


        ),
      ),
    );
  }
}
