import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/core/routes.dart';
import 'package:jazz/features/auth_feature/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search/search_bloc.dart';


class SetFavouriteArtistsScreen extends StatefulWidget {
  @override
  _SetFavouriteArtistsScreenState createState() => _SetFavouriteArtistsScreenState();
}

class _SetFavouriteArtistsScreenState extends State<SetFavouriteArtistsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late SearchBloc _searchBloc;
  final Set<String> _selectedArtists = {}; // Store selected artist IDs

  @override
  void initState() {
    super.initState();
    _searchBloc = context.read<SearchBloc>();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _searchBloc.add(SearchArtistsRequested(query:query));
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
    // You can call another function or send these IDs to an API, etc.
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if(state is UserDataUpdated){
      Navigator.pushNamedAndRemoveUntil(context, Routes.searchScreen, (Route<dynamic> route) => false);
    }
  },
  child: Scaffold(
      appBar: AppBar(title: Text('Search Artists')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search artists...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _onSearchChanged,
                ),
              ),
              onSubmitted: (_) => _onSearchChanged(),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is SearchLoaded) {
                  if (state.artists.isEmpty) {
                    return Center(child: Text('No artists found'));
                  }
                  return ListView.builder(
                    itemCount: state.artists.length,
                    itemBuilder: (context, index) {
                      final artist = state.artists[index];
                      final isSelected = _selectedArtists.contains(artist.browseId);

                      return ListTile(
                        title: Text(artist.name),

                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(artist.thumbnails.first.url ?? ''),
                        ),
                        tileColor: isSelected ? Colors.blue.withOpacity(0.3) : null,
                        onTap: () => _toggleSelection(artist.browseId),
                      );
                    },
                  );
                } else if (state is SearchError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return Center(child: Text('Search for an artist'));
              },
            ),
          ),
          if (_selectedArtists.isNotEmpty) // Show button only if selections exist
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _onFinishPressed,
                child: Text("Finish (${_selectedArtists.length})"),
              ),
            ),
        ],
      ),
    ),
);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
