part of 'search_suggestion_bloc.dart';

@immutable
sealed class SearchSuggestionState {}

final class SearchSuggestionInitial extends SearchSuggestionState {}
class SearchSuggestionLoading extends SearchSuggestionState {}

class SearchSuggestionLoaded extends SearchSuggestionState {
  final List suggestions;

   SearchSuggestionLoaded(this.suggestions);


}

class SearchSuggestionError extends SearchSuggestionState {
  final String message;

   SearchSuggestionError(this.message);

}