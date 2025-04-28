part of 'search_suggestion_bloc.dart';

@immutable
sealed class SearchSuggestionEvent {}
class GetSearchSuggestionEvent extends SearchSuggestionEvent {
  final String query;

  GetSearchSuggestionEvent(this.query);


}

class ClearSearchSuggestionsEvent extends SearchSuggestionEvent {}