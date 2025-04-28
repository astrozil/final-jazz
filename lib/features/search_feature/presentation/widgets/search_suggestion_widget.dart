import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jazz/features/search_feature/presentation/bloc/search_suggestion_bloc/search_suggestion_bloc.dart';

class SearchSuggestion extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final FocusNode focusNode;

  const SearchSuggestion({
    Key? key,
    required this.controller,
    required this.onSearch,
    required this.focusNode
  }) : super(key: key);

  @override
  _SearchSuggestionState createState() => _SearchSuggestionState();
}

class _SearchSuggestionState extends State<SearchSuggestion> {
  List _suggestions = [];
  List<String> _searchHistory = [];
  bool _showSuggestions = false;
  bool _isLoading = false;
  Timer? _debounce;
  String _lastQuery = '';
  StreamSubscription? _historySubscription;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _setupSearchHistoryListener();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _debounce?.cancel();
    _historySubscription?.cancel();
    super.dispose();
  }

  void _setupSearchHistoryListener() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _historySubscription = FirebaseFirestore.instance
          .collection("Users")
          .doc(userId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && snapshot.data()!.containsKey("searchHistory")) {
          List<dynamic> history = snapshot.data()!["searchHistory"];
          setState(() {
            _searchHistory = history.cast<String>();
          });
        }
      });
    }
  }

  void _onTextChanged() {
    final currentText = widget.controller.text;

    // Immediately hide suggestions if text is empty
    if (currentText.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
        _lastQuery = '';
      });
      context.read<SearchSuggestionBloc>().add(ClearSearchSuggestionsEvent());
      _debounce?.cancel();
      return;
    }

    // Show matching items from search history immediately
    _showMatchingHistoryItems(currentText);

    // Use shorter debounce for better responsiveness
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (widget.focusNode.hasFocus && currentText != _lastQuery) {
        _fetchSuggestions(currentText);

        _lastQuery = currentText;
      }
    });
  }

  void _showMatchingHistoryItems(String query) {
    if (query.isEmpty) return;

    List<String> matchingHistory = _searchHistory
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();

    if (matchingHistory.isNotEmpty) {
      setState(() {
        _suggestions = matchingHistory;
        _showSuggestions = true;
      });
    }
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Store the query at the time of request
      final requestQuery = query;

      // Only fetch if the text field still has the same content
      if (widget.controller.text == requestQuery) {
        context.read<SearchSuggestionBloc>().add(GetSearchSuggestionEvent(query));
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addToSearchHistory(String query) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // First check if the query already exists in the history
        if (!_searchHistory.contains(query)) {
          await FirebaseFirestore.instance.collection("Users").doc(userId).update({
            "searchHistory": FieldValue.arrayUnion([query])
          });

          // Note: We don't need to update local state here as the listener will handle it
        } else {
          // If the query already exists, we might want to move it to the top
          // This requires removing and re-adding the item
          List<String> updatedHistory = List.from(_searchHistory);
          updatedHistory.remove(query);
          updatedHistory.insert(0, query);

          await FirebaseFirestore.instance.collection("Users").doc(userId).update({
            "searchHistory": updatedHistory
          });
        }
      }
    } catch (e) {
      print('Error adding to search history: $e');
    }
  }

  // New function to remove item from search history
  Future<void> _removeFromSearchHistory(String query) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // Create a new list without the removed item
        List<String> updatedHistory = List.from(_searchHistory);
        updatedHistory.remove(query);

        // Update Firestore with the new list
        await FirebaseFirestore.instance.collection("Users").doc(userId).update({
          "searchHistory": updatedHistory
        });

        // Update suggestions after removing history item
        if (widget.controller.text.isNotEmpty) {
          _fetchSuggestions(widget.controller.text);
        }
      }
    } catch (e) {
      print('Error removing from search history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't render anything if search field is empty
    if (widget.controller.text.isEmpty) {
      return SizedBox.shrink();
    }

    return BlocListener<SearchSuggestionBloc, SearchSuggestionState>(
      listener: (context, state) {
        if (state is SearchSuggestionLoaded) {
          // Only update if the search field still has text
          if (widget.controller.text.isNotEmpty) {
            // Combine API suggestions with history suggestions
            List apiSuggestions = state.suggestions;
            List<String> historySuggestions = _searchHistory
                .where((item) => item.toLowerCase().contains(widget.controller.text.toLowerCase()))
                .take(3)
                .toList();

            // Create a combined list with history items first, then API suggestions
            List combinedSuggestions = [...historySuggestions];

            // Add API suggestions that aren't already in the list
            for (var suggestion in apiSuggestions) {
              if (!combinedSuggestions.contains(suggestion)) {
                combinedSuggestions.add(suggestion);
              }
            }

            setState(() {
              _suggestions = combinedSuggestions.take(8).toList();
              _showSuggestions = true;
              _isLoading = false;
            });
          }
        } else if (state is SearchSuggestionInitial) {
          setState(() {
            _suggestions = [];
            _showSuggestions = false;
            _isLoading = false;
          });
        } else if (state is SearchSuggestionError) {
          print(state.message);
          setState(() {
            _isLoading = false;
          });
        } else if (state is SearchSuggestionLoading) {
          setState(() {
            _isLoading = true;
          });
        }
      },
      child: Column(
        children: [
          if (_showSuggestions && _suggestions.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  final isHistoryItem = _searchHistory.contains(suggestion);

                  return ListTile(
                    leading: Icon(
                      isHistoryItem ? Icons.history : Icons.search,
                      color: isHistoryItem ? Colors.blue : Colors.grey,
                    ),
                    title: Text(
                      suggestion,
                      style: TextStyle(
                        fontWeight: isHistoryItem ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isHistoryItem
                        ? IconButton(
                      icon: Icon(Icons.close, size: 18, color: Colors.grey),
                      onPressed: () {
                        _removeFromSearchHistory(suggestion);
                      },
                      splashRadius: 20,
                      tooltip: 'Remove from history',
                    )
                        : null,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    dense: true,
                    onTap: () {
                      widget.controller.text = suggestion;
                      _addToSearchHistory(suggestion); // Add to history when suggestion is tapped
                      widget.onSearch(suggestion);
                      setState(() {
                        _showSuggestions = false;
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
