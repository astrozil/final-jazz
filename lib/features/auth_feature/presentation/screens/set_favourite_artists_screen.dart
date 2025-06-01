import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search/search_bloc.dart';

class SetFavouriteArtistsScreen extends StatefulWidget {
  const SetFavouriteArtistsScreen({super.key});

  @override
  _SetFavouriteArtistsScreenState createState() => _SetFavouriteArtistsScreenState();
}

class _SetFavouriteArtistsScreenState extends State<SetFavouriteArtistsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late SearchBloc _searchBloc;
  final Set<String> _selectedArtists = {}; // Store selected artist IDs
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchBloc = context.read<SearchBloc>();
    _searchFocusNode = FocusNode();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _searchBloc.add(SearchArtistsRequested(query: query));
    }
  }

  void _toggleSelection(String artistId) {
    setState(() {
      if (_selectedArtists.contains(artistId)) {
        _selectedArtists.remove(artistId);
      } else {
        _selectedArtists.add(artistId);
      }
    });
  }

  void _onFinishPressed() {
    // Handle the selected artist IDs
    context.read<AuthBloc>().add(
        UpdateUserProfileEvent(favouriteArtists: _selectedArtists.toList()));
    // Show loading dialog

  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          // showDialog(
          //   context: context,
          //   barrierDismissible: false,
          //   builder: (context) => Center(
          //     child: CircularProgressIndicator(
          //       color: Colors.white,
          //     ),
          //   ),
          // );
        } else if (state is UserDataUpdated) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Dismiss loading dialog

          }
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.homeScreen, (Route<dynamic> route) => false);
        } else if (state is AuthFailure) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Dismiss loading dialog
          }
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? "Failed to update profile"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Album artwork grid background
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/auth_background.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Dark overlay with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.9),
                    Colors.black,
                  ],
                  stops: [0.0, 0.1, 0.7],
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 16.h),

                        // Icon
                        Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 52.r,
                        ),

                        SizedBox(height: 16.h),

                        // Title
                        Text(
                          "Choose your favorite artists",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 8.h),

                        // Subtitle
                        Text(
                          "We'll personalize your experience based on your selections",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 24.h),

                        // Search field
                        TextField(
                          focusNode: _searchFocusNode,
                          controller: _searchController,
                          style: TextStyle(color: Colors.white, fontSize: 16.sp),
                          decoration: InputDecoration(
                            hintText: "Search artists...",
                            hintStyle: TextStyle(fontSize: 16.sp, color: Colors.white60),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(color: Colors.white30),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search, color: Colors.white70),
                              onPressed: _onSearchChanged,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                          ),
                          onSubmitted: (_) => _onSearchChanged(),
                        ),
                      ],
                    ),
                  ),

                  // Results list
                  Expanded(
                    child: BlocBuilder<SearchBloc, SearchState>(
                      builder: (context, state) {
                        if (state is SearchLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        } else if (state is SearchLoaded) {
                          if (state.artists.isEmpty) {
                            return Center(
                              child: Text(
                                'No artists found',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16.sp,
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16.r),
                            itemCount: state.artists.length,
                            itemBuilder: (context, index) {
                              final artist = state.artists[index];
                              final isSelected = _selectedArtists.contains(artist.browseId);

                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 6.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.05),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  title: Text(
                                    artist.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    radius: 24.r,
                                    backgroundColor: Colors.grey[800],
                                    backgroundImage: NetworkImage(
                                      artist.thumbnails.isNotEmpty
                                          ? artist.thumbnails.first.url ?? ''
                                          : '',
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 24.r,
                                  )
                                      : Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.white70,
                                    size: 24.r,
                                  ),
                                  onTap: () => _toggleSelection(artist.browseId),
                                ),
                              );
                            },
                          );
                        } else if (state is SearchError) {
                          return Center(
                            child: Text(
                              'Error: ${state.message}',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return Center(
                          child: Text(
                            'Search for your favorite artists',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom buttons
                  Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      children: [
                        // Finish button
                        ElevatedButton(
                          onPressed: _selectedArtists.isNotEmpty ? _onFinishPressed : (){

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedArtists.isNotEmpty
                                ? Colors.white
                                : Color.fromRGBO(49, 47, 52, 0.5),
                            foregroundColor: _selectedArtists.isNotEmpty
                                ? Colors.black
                                : Colors.white.withOpacity(0.3),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            minimumSize: Size(double.infinity, 50.h),
                          ),
                          child: Text(
                            _selectedArtists.isNotEmpty
                                ? "Continue with ${_selectedArtists.length} artists"
                                : "Select at least one artist",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Skip button


                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
