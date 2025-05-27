import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jazz/features/song_share_feature/domain/entities/shared_song.dart';
import 'package:jazz/features/song_share_feature/domain/use_cases/get_received_shared_songs.dart';
import 'package:jazz/features/song_share_feature/domain/use_cases/get_sent_shared_songs.dart';
import 'package:jazz/features/song_share_feature/domain/use_cases/mark_shared_song_as_viewed.dart';
import 'package:jazz/features/song_share_feature/domain/use_cases/share_song_use_case.dart';
import 'package:meta/meta.dart';

part 'shared_song_event.dart';
part 'shared_song_state.dart';

class SharedSongBloc extends Bloc<SharedSongEvent, SharedSongState> {
  final ShareSong _shareSong;
  final GetReceivedSharedSongs _getReceivedSharedSongs;
  final GetSentSharedSongs _getSentSharedSongs;
  final MarkSharedSongAsViewed _markSharedSongAsViewed;

  StreamSubscription? _receivedSongsSubscription;
  StreamSubscription? _sentSongsSubscription;

  String _currentUserId = '';

  SharedSongBloc(
      this._shareSong,
      this._getReceivedSharedSongs,
      this._getSentSharedSongs,
      this._markSharedSongAsViewed,
      ) : super(SharedSongInitial()) {
    on<ShareSongEvent>(_onShareSong);
    on<GetReceivedSharedSongsEvent>(_onGetReceivedSharedSongs);
    on<GetSentSharedSongsEvent>(_onGetSentSharedSongs);
    on<MarkSharedSongAsViewedEvent>(_onMarkSharedSongAsViewed);
    on<SetCurrentUserIdSharedSongEvent>(_onSetCurrentUserId);
    on<_ReceivedSharedSongsUpdated>(_onReceivedSharedSongsUpdated);
    on<_SentSharedSongsUpdated>(_onSentSharedSongsUpdated);
    on<_SharedSongError>(_onSharedSongError);
  }

  void _onSetCurrentUserId(
      SetCurrentUserIdSharedSongEvent event,
      Emitter<SharedSongState> emit,
      ) {
    _currentUserId = event.userId;
  }

  Future<void> _onShareSong(
      ShareSongEvent event,
      Emitter<SharedSongState> emit,
      ) async {
    emit(SharedSongLoading());
    try {
      await _shareSong.execute(event.sharedSong);
      emit(SharedSongSuccess());
    } catch (e) {
      emit(SharedSongError(e.toString()));
    }
  }

  void _onGetReceivedSharedSongs(
      GetReceivedSharedSongsEvent event,
      Emitter<SharedSongState> emit,
      ) {
    emit(SharedSongLoading());
    _receivedSongsSubscription?.cancel();
    _receivedSongsSubscription = _getReceivedSharedSongs
        .execute(FirebaseAuth.instance.currentUser!.uid)
        .listen(
          (songs) => add(_ReceivedSharedSongsUpdated(songs)),
      onError: (error) => add(_SharedSongError(error.toString())),
    );
  }

  void _onGetSentSharedSongs(
      GetSentSharedSongsEvent event,
      Emitter<SharedSongState> emit,
      ) {
    emit(SharedSongLoading());
    _sentSongsSubscription?.cancel();
    _sentSongsSubscription = _getSentSharedSongs
        .execute(_currentUserId)
        .listen(
          (songs) => add(_SentSharedSongsUpdated(songs)),
      onError: (error) => add(_SharedSongError(error.toString())),
    );
  }

  Future<void> _onMarkSharedSongAsViewed(
      MarkSharedSongAsViewedEvent event,
      Emitter<SharedSongState> emit,
      ) async {
    try {
      await _markSharedSongAsViewed.execute(event.sharedSongId);
    } catch (e) {
      emit(SharedSongError(e.toString()));
    }
  }

  void _onReceivedSharedSongsUpdated(
      _ReceivedSharedSongsUpdated event,
      Emitter<SharedSongState> emit,
      ) {
    emit(ReceivedSharedSongsLoaded(event.sharedSongs));
  }

  void _onSentSharedSongsUpdated(
      _SentSharedSongsUpdated event,
      Emitter<SharedSongState> emit,
      ) {
    emit(SentSharedSongsLoaded(event.sharedSongs));
  }

  void _onSharedSongError(
      _SharedSongError event,
      Emitter<SharedSongState> emit,
      ) {
    emit(SharedSongError(event.message));
  }

  @override
  Future<void> close() {
    _receivedSongsSubscription?.cancel();
    _sentSongsSubscription?.cancel();
    return super.close();
  }
}