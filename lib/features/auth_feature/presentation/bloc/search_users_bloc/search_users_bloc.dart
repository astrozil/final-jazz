import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/auth_feature/domain/use_case/auth_use_cases/search_users_use_case.dart';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'search_users_event.dart';
part 'search_users_state.dart';

class SearchUsersBloc extends Bloc<SearchUsersEvent, SearchUsersState> {
  final SearchUsersUseCase _searchUsersUseCase;
  StreamSubscription? _searchSubscription;
  SearchUsersBloc(
      SearchUsersUseCase searchUsersUseCase,

      ) : _searchUsersUseCase = searchUsersUseCase,

        super(SearchUsersInitial()) {

    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchResultsReceived>(_searchResultsReceived);
    on<SearchError>(_searchError);
  }
  void _onSearchQueryChanged(
      SearchQueryChanged event,
      Emitter<SearchUsersState> emit,
      ) async {
    if (event.query.isEmpty) {
      emit(SearchUsersInitial());
      return;
    }

    emit(SearchUsersLoading());

    await _searchSubscription?.cancel();
    _searchSubscription = _searchUsersUseCase(event.query)
    .debounceTime(const Duration(milliseconds: 300))
        .listen(
          (users) => add(SearchResultsReceived(users)),
      onError: (error) => add(SearchError(error.toString())),
    );
  }
  void _searchResultsReceived(SearchResultsReceived event,
      Emitter<SearchUsersState> emit,){
    emit(SearchUsersSuccess(event.users));
  }
  void _searchError(SearchError event,
      Emitter<SearchUsersState> emit,){
    emit(SearchFailure(event.error));
  }

  @override
  Future<void> close() {
    _searchSubscription?.cancel();
    return super.close();
  }
}
