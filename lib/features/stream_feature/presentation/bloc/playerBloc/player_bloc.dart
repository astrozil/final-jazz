import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jazz/core/failure/failure.dart';
import 'package:jazz/features/auth_feature/domain/entities/user.dart';
import 'package:jazz/features/download_feature/domain/entities/downloadedSong.dart';
import 'package:jazz/features/lyrics_feature/domain/usecases/get_lyrics_usecase.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';
import 'package:jazz/features/stream_feature/domain/entities/repeat_mode.dart';
import 'package:jazz/features/stream_feature/domain/entities/songHistory.dart';
import 'package:jazz/features/stream_feature/domain/usecases/getMp3StreamUsecase.dart';
import 'package:jazz/features/stream_feature/domain/usecases/getRelatedSongUsecase.dart';
import 'package:jazz/features/stream_feature/presentation/bloc/playerBloc/player_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  late SongHistory unShuffledSongHistory;
  final GetMp3StreamUseCase getMp3StreamUseCase;
  final GetRelatedSongUseCase getRelatedSongUseCase;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<ProcessingState>? _processingStateSubscription;
  StreamSubscription? _audioPlayerStateSubscription;

  final GetLyrics getLyrics;
  final AudioPlayer audioPlayer;

  // Add lyrics tracking variables
  String? _currentLyricsSongId;
  Completer<void>? _currentLyricsCompleter;

  PlayerBloc({
    required this.getMp3StreamUseCase,
    required this.getRelatedSongUseCase,
    required this.getLyrics
  }) : audioPlayer = AudioPlayer(),
        super(PlayerState(
          songPosition: Duration.zero,
          currentSong: null,
          totalDuration: Duration.zero,
          isPlaying: false,
          isSongRepeatEnabled: false,
          isPlaylistRepeatEnabled: false,
          isShuffleEnabled: false,
          isLoading: false,
          errorMessage: null,
          relatedSongs: SongHistory.empty(),
          lyrics: [],
          currentSongIndex: 0,
          isFromAlbum: false
      )) {

    on<PlaySongEvent>(_playSongEvent);
    on<PausePlayerEvent>(_pausePlayerEvent);
    on<UpdateStateEvent>(_updateStateEvent);
    on<PlayNextSongEvent>(_playNextSongEvent);
    on<PlayPreviousEvent>(_playPreviousSongEvent);
    on<PlayChosenSongEvent>(_playChosenSongEvent);
    on<ResumePlayerEvent>(_resumePlayerEvent);
    on<ToggleShuffleEvent>(_toggleShuffleEvent);
    on<ToggleRepeatModeEvent>(_toggleRepeatModeEvent);
  }

  Future<void> _playSongEvent(PlaySongEvent event, Emitter<PlayerState> emit) async {
    await _resetVariables(emit);

    emit(state.copyWith(
        isShuffleEnabled: false,
        isPlaylistRepeatEnabled: false,
        isSongRepeatEnabled: false,
        isLoading: true,
        lyrics: [] // Clear lyrics immediately
    ));

    _cancelSubscriptions();
    _cancelCurrentLyricsRequest(); // Cancel any ongoing lyrics request

    if (event.albumTracks != null) {
      emit(state.copyWith(isFromAlbum: true));
      emit(state.copyWith(relatedSongs: SongHistory(history: left(event.albumTracks!))));
    }

    await event.song.fold(
            (song) async {
          if (event.albumTracks != null) {
            final tempIndex = event.albumTracks!.indexWhere((tempSong) => tempSong.song.id == song.id);
            emit(state.copyWith(currentSongIndex: tempIndex));
          }
          add(UpdateStateEvent(state: state.copyWith(currentSong: left(song))));

          if (!state.isFromAlbum) {
            final songHistory = state.relatedSongs;
            songHistory.addSong(left(RelatedSong(url: "", song: song)));
            add(UpdateStateEvent(state: state.copyWith(relatedSongs: songHistory)));
            await fetchSongHistory(emit);
          }

          Future.microtask(() async {
            await playSong(left(song), emit, "");
          });
        },
            (downloadedSong) async {
          add(UpdateStateEvent(state: state.copyWith(relatedSongs: SongHistory.empty(isStreamed: false))));
          await playSong(right(downloadedSong), emit, "");
        }
    );
  }

  void _updateStateEvent(UpdateStateEvent event, Emitter<Player> emit) {
    emit(event.state);
  }

  Future<void> _playNextSongEvent(PlayNextSongEvent event, Emitter<PlayerState> emit) async {
    final songHistory = state.relatedSongs;
    _cancelCurrentLyricsRequest(); // Cancel lyrics when switching songs

    songHistory.mapBothAsync(
        onRelatedSongs: (relatedSongs) async {
          if (state.currentSongIndex < songHistory.length - 1) {
            final newIndex = state.currentSongIndex + 1;
            add(UpdateStateEvent(state: state.copyWith(
                currentSongIndex: newIndex,
                songPosition: Duration.zero,
                totalDuration: Duration.zero,
                lyrics: [] // Clear lyrics immediately
            )));
            Future.microtask(() async {
              await playSong(left(relatedSongs[newIndex].song), emit, relatedSongs[newIndex].url);
            });

            if (newIndex == relatedSongs.length - 1 && !(state).isPlaylistRepeatEnabled) {
              await fetchSongHistory(emit);
            }
          } else if (state.currentSongIndex == songHistory.length - 1 && state.isPlaylistRepeatEnabled) {
            add(UpdateStateEvent(state: state.copyWith(currentSongIndex: -1)));
            add(PlayNextSongEvent());
          }
          return relatedSongs;
        },
        onDownloadedSongs: (downloadedSongs) async {
          if (state.currentSongIndex < downloadedSongs.length - 1) {
            final newIndex = state.currentSongIndex + 1;
            add(UpdateStateEvent(state: state.copyWith(
                currentSongIndex: newIndex,
                lyrics: [] // Clear lyrics immediately
            )));
            Future.microtask(() async {
              await playSong(right(downloadedSongs[newIndex]), emit, "");
            });
          } else if (state.currentSongIndex == downloadedSongs.length - 1 && state.isPlaylistRepeatEnabled) {
            add(UpdateStateEvent(state: state.copyWith(currentSongIndex: -1)));
            add(PlayNextSongEvent());
          }
          return downloadedSongs;
        });
  }

  Future<void> _playPreviousSongEvent(PlayPreviousEvent event, Emitter<PlayerState> emit) async {
    if (state.currentSongIndex > 0) {
      _cancelCurrentLyricsRequest(); // Cancel lyrics when switching songs

      final newIndex = state.currentSongIndex - 1;
      add(UpdateStateEvent(state: state.copyWith(
          currentSongIndex: newIndex,
          songPosition: Duration.zero,
          totalDuration: Duration.zero,
          lyrics: [] // Clear lyrics immediately
      )));
      final songHistory = state.relatedSongs;
      songHistory.mapBothAsync(
          onRelatedSongs: (relatedSongs) async {
            await playSong(left(relatedSongs[newIndex].song), emit, relatedSongs[newIndex].url);
            return relatedSongs;
          },
          onDownloadedSongs: (downloadedSongs) async {
            await playSong(right(downloadedSongs[newIndex]), emit, "");
            return downloadedSongs;
          });
    }
  }

  Future<void> _playChosenSongEvent(PlayChosenSongEvent event, Emitter<PlayerState> emit) async {
    _cancelCurrentLyricsRequest(); // Cancel lyrics when switching songs

    final newIndex = event.chosenIndex;
    add(UpdateStateEvent(state: state.copyWith(
        currentSongIndex: newIndex,
        songPosition: Duration.zero,
        totalDuration: Duration.zero,
        lyrics: [] // Clear lyrics immediately
    )));
    final songHistory = state.relatedSongs;
    songHistory.mapBothAsync(
        onRelatedSongs: (relatedSongs) async {
          await playSong(left(relatedSongs[newIndex].song), emit, relatedSongs[newIndex].url);
          if (newIndex == relatedSongs.length - 1 && !(state).isPlaylistRepeatEnabled) {
            fetchSongHistory(emit);
          }
          return relatedSongs;
        },
        onDownloadedSongs: (downloadedSongs) async {
          playSong(right(downloadedSongs[newIndex]), emit, "");
          return downloadedSongs;
        }
    );
  }

  Future<void> _pausePlayerEvent(PausePlayerEvent event, Emitter<PlayerState> emit) async {
    await audioPlayer.pause();
  }

  Future<void> _resumePlayerEvent(ResumePlayerEvent event, Emitter<PlayerState> emit) async {
    await audioPlayer.play();
  }

  void _toggleShuffleEvent(ToggleShuffleEvent event, Emitter<PlayerState> emit) {
    if (event.isShuffled) {
      if (event.index != null) {
        _shuffleHistory(event.index!);
      }
    } else {
      _unShuffleHistory();
    }
  }

  void _toggleRepeatModeEvent(ToggleRepeatModeEvent event, Emitter<PlayerState> emit) {
    if (event.mode == RepeatMode.song) {
      emit((state).copyWith(isSongRepeatEnabled: true, isPlaylistRepeatEnabled: false));
    } else if (event.mode == RepeatMode.playlist) {
      emit((state).copyWith(isPlaylistRepeatEnabled: true, isSongRepeatEnabled: false));
    } else {
      emit((state).copyWith(isSongRepeatEnabled: false, isPlaylistRepeatEnabled: false));
    }
  }

  void seekTo(Duration position) {
    audioPlayer.seek(position);
  }

  Future<SongHistory> fetchSongHistory(Emitter<PlayerState> emit) async {
    final updatedHistory = await state.relatedSongs.mapBothAsync(
      onRelatedSongs: (relatedSongs) async {
        var result = _fetchAndAddRelatedSongs(relatedSongs, emit);
        return await result;
      },
      onDownloadedSongs: (downloadedSongs) async => downloadedSongs,
    );

    emit((state).copyWith(relatedSongs: updatedHistory));
    return updatedHistory;
  }

  Future<List<RelatedSong>> _fetchAndAddRelatedSongs(
      List<RelatedSong> relatedSongs, Emitter<PlayerState> emit) async {
    final relatedSongList = await getRelatedSongUseCase(relatedSongs.last.song.id, relatedSongs);
    return await relatedSongList.fold(
          (failure) async {
        return relatedSongs;
      },
          (result) async {
        if (result != null) {
          return [...relatedSongs, ...result];
        } else {
          return relatedSongs;
        }
      },
    );
  }

  Future<void> playSong(Either<Song, DownloadedSong> song, Emitter<PlayerState> emit, String url) async {
    if (audioPlayer.playing) {
      await audioPlayer.stop();
    }

    // Clear lyrics immediately and cancel any ongoing lyrics request
    _cancelCurrentLyricsRequest();
    add(UpdateStateEvent(state: (state).copyWith(currentSong: song, lyrics: [])));

    _cancelSubscriptions();
    await setUrl(song, url, emit);
    print("HEYYY");
    updateSongPosition();
    updateAudioPlayerState();
    setProcessAfterSongEnd(emit);
    Future.microtask(() async {
      await audioPlayer.play();
    });

    // Start lyrics search with tracking
    _searchLyricsWithTracking(song, emit);
  }

  Future<void> setUrl(Either<Song, DownloadedSong> song, String url, Emitter<PlayerState> emit) async {
    await song.fold(
          (song) => _handleStreamedSong(song, url, emit),
          (downloadedSong) => _handleDownloadedSong(downloadedSong, emit),
    );
  }

  Future<void> _handleStreamedSong(Song song, String url, Emitter<PlayerState> emit) async {
    add(UpdateStateEvent(state: (state).copyWith(currentSong: left(song))));
    String userId = FirebaseAuth.instance.currentUser!.uid;

    if (url.isEmpty) {
      print("OKKK");
      try {
        final songUrl = await getMp3StreamUseCase(song.id, song.url);
        await songUrl.fold(
              (failure) async {
            // emit(PlayerErrorState(errorMessage: failure.message));
          },
              (result) async {
            print("YEESS");
            if (result != null) {
              print(result.url);
              final songHistory = state.relatedSongs.mapRelatedSongs((list) {
                list[state.currentSongIndex] = list[state.currentSongIndex].copyWith(url: result.url);
                return list;
              });
              add(UpdateStateEvent(state: state.copyWith(relatedSongs: songHistory)));
              print(result.url);
              await audioPlayer.setUrl(result.url);
            }
          },
        );

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot doc = await transaction.get(
              FirebaseFirestore.instance.collection("Users").doc(userId));

          List<dynamic> songHistory = doc.exists && doc.data() != null && (doc.data() as Map).containsKey("songHistory")
              ? List.from(doc.get("songHistory"))
              : [];

          if (songHistory.length >= 50) {
            songHistory.removeAt(0);
          }

          songHistory.add(song.id);

          transaction.update(
              FirebaseFirestore.instance.collection("Users").doc(userId),
              {"songHistory": songHistory});
        });

      } catch (e) {
        add(UpdateStateEvent(state: state.copyWith(errorMessage: e.toString())));
      }
    } else {
      audioPlayer.setUrl(url);
    }
  }

  Future<void> _handleDownloadedSong(DownloadedSong downloadedSong, Emitter<PlayerState> emit) async {
    add(UpdateStateEvent(state: state.copyWith(currentSong: right(downloadedSong))));
    await audioPlayer.setFilePath(downloadedSong.songFile.path);
  }

  void updateSongPosition() {
    _positionSubscription = audioPlayer.positionStream.throttleTime(const Duration(milliseconds: 500)).listen((position) {
      final totalDuration = audioPlayer.duration ?? Duration.zero;
      if (totalDuration > Duration.zero && position <= totalDuration) {
        add(UpdateStateEvent(state: state.copyWith(
          totalDuration: totalDuration,
          songPosition: position,
        )));
      }
    });
  }

  void updateAudioPlayerState() {
    _audioPlayerStateSubscription = audioPlayer.playingStream
        .startWith(true)
        .listen((isPlaying) {
      add(UpdateStateEvent(state: (state).copyWith(isPlaying: isPlaying)));
    });
  }

  void setProcessAfterSongEnd(Emitter<PlayerState> emit) {
    _processingStateSubscription = audioPlayer.processingStateStream.listen(
            (processingState) async {
          if (processingState == ProcessingState.completed) {
            if ((state).isSongRepeatEnabled) {
              audioPlayer.seek(Duration.zero);
              await audioPlayer.play();
            } else if ((state).isPlaylistRepeatEnabled && state.currentSongIndex == state.relatedSongs.length - 1) {
              add(UpdateStateEvent(state: state.copyWith(currentSongIndex: 0)));
              state.relatedSongs.mapBothAsync(onRelatedSongs: (relatedSongs) async {
                await playSong(left(relatedSongs[state.currentSongIndex].song), emit, relatedSongs[state.currentSongIndex].url);
                return relatedSongs;
              }, onDownloadedSongs: (downloadedSongs) async {
                await playSong(right(downloadedSongs[state.currentSongIndex]), emit, "");
                return downloadedSongs;
              });
            } else {
              add(PlayNextSongEvent());
            }
          }
        });
  }

  // FIXED LYRICS METHOD - with proper tracking and cancellation
  void _searchLyricsWithTracking(Either<Song, DownloadedSong> song, Emitter<PlayerState> emit) async {
    // Cancel any existing lyrics request
    _cancelCurrentLyricsRequest();

    // Generate unique ID for this song
    String songId;
    String artist, title;

    if (song.isLeft()) {
      final songData = song.fold((s) => s, (_) => null)!;
      songId = songData.id;
      artist = songData.artists.map((artist) => artist['name']).join(",");
      title = songData.title;
    } else {
      final downloadedSong = song.fold((_) => null, (ds) => ds)!;
      songId = downloadedSong.songFile.path;
      artist = downloadedSong.artist;
      title = downloadedSong.songName;
    }

    // Set current song ID for tracking
    _currentLyricsSongId = songId;
    _currentLyricsCompleter = Completer<void>();

    try {
      List<Map<String, dynamic>>? lyricsResult = await getLyrics(artist, title);

      // Check if this request is still valid (song hasn't changed)
      if (_currentLyricsSongId == songId && !_currentLyricsCompleter!.isCompleted) {
        if (lyricsResult != null && lyricsResult.isNotEmpty) {
          add(UpdateStateEvent(state: (state).copyWith(lyrics: lyricsResult)));
        } else {
          add(UpdateStateEvent(state: state.copyWith(lyrics: [])));
        }
        _currentLyricsCompleter!.complete();
      }
    } catch (e) {
      // Check if this request is still valid before updating state
      if (_currentLyricsSongId == songId && !_currentLyricsCompleter!.isCompleted) {
        add(UpdateStateEvent(state: state.copyWith(lyrics: [])));
        _currentLyricsCompleter!.complete();
      }
    }
  }

  void _cancelCurrentLyricsRequest() {
    if (_currentLyricsCompleter != null && !_currentLyricsCompleter!.isCompleted) {
      _currentLyricsCompleter!.complete();
    }
    _currentLyricsSongId = null;
    _currentLyricsCompleter = null;
  }

  Future<void> _resetVariables(Emitter<PlayerState> emit) async {
    emit(state.copyWith(currentSong: null, currentSongIndex: 0, relatedSongs: SongHistory.empty()));
    _cancelCurrentLyricsRequest(); // Cancel lyrics when resetting

    if (audioPlayer.playing) {
      await audioPlayer.stop();
    }
  }

  void _shuffleHistory(int index) {
    final currentSong = state.currentSong;

    unShuffledSongHistory = state.relatedSongs.clone();
    var shuffledSongHistory = state.relatedSongs.shuffleWithPriorityAt(index);

    final currentIndex = shuffledSongHistory.indexWhere((songItem) {
      if (songItem is RelatedSong && currentSong != null && currentSong.isLeft()) {
        return songItem.song.id == currentSong.fold((s) => s.id, (_) => '');
      } else if (songItem is DownloadedSong && currentSong != null && currentSong.isRight()) {
        return songItem.songFile == currentSong.fold((_) => "", (d) => d.songFile);
      }
      return false;
    });
    add(UpdateStateEvent(state: state.copyWith(relatedSongs: shuffledSongHistory, currentSongIndex: currentIndex, isShuffleEnabled: true)));
  }

  void _unShuffleHistory() {
    final currentSong = state.currentSong;

    final currentIndex = unShuffledSongHistory.indexWhere((songItem) {
      if (songItem is RelatedSong && currentSong != null && currentSong.isLeft()) {
        return songItem.song.id == currentSong.fold((s) => s.id, (_) => '');
      } else if (songItem is DownloadedSong && currentSong != null && currentSong.isRight()) {
        return songItem.songFile == currentSong.fold((_) => "", (d) => d.songFile);
      }
      return false;
    });
    add(UpdateStateEvent(state: state.copyWith(currentSongIndex: currentIndex, isShuffleEnabled: false, relatedSongs: unShuffledSongHistory)));
  }

  void _cancelSubscriptions() {
    _positionSubscription?.cancel();
    _processingStateSubscription?.cancel();
    _audioPlayerStateSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _processingStateSubscription?.cancel();
    _audioPlayerStateSubscription?.cancel();
    _cancelCurrentLyricsRequest(); // Cancel lyrics on close
    audioPlayer.dispose();
    return super.close();
  }
}
