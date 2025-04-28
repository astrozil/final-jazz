import 'package:bloc/bloc.dart';
import 'package:jazz/features/search_feature/domain/usecases/get_suggestions_use_case.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'search_suggestion_event.dart';
part 'search_suggestion_state.dart';

class SearchSuggestionBloc extends Bloc<SearchSuggestionEvent, SearchSuggestionState> {
  final GetSuggestionsUseCase getSuggestionsUseCase;
  SearchSuggestionBloc({
    required this.getSuggestionsUseCase
}) : super(SearchSuggestionInitial()) {
    on<GetSearchSuggestionEvent>(_onGetSuggestion,
      );
    on<ClearSearchSuggestionsEvent>(_onClearSuggestions);
  }

  Future<void> _onGetSuggestion(
      GetSearchSuggestionEvent event,
      Emitter<SearchSuggestionState> emit,
      ) async {
    if (event.query.isEmpty) {
      emit(SearchSuggestionInitial());
      return;
    }

    emit(SearchSuggestionLoading());
    try {
      final List result = await getSuggestionsUseCase.execute(query: event.query);
      emit(SearchSuggestionLoaded(result));
    }catch(e){
        emit(SearchSuggestionError(e.toString()));
    }

  }

  void _onClearSuggestions(
      ClearSearchSuggestionsEvent event,
      Emitter<SearchSuggestionState> emit,
      ) {
    emit(SearchSuggestionInitial());
  }
}
