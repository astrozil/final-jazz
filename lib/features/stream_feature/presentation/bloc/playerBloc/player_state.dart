part of 'player_bloc.dart';

@immutable
sealed class Player {

}

final class PlayerState extends Player{
  final Duration songPosition;
  final Duration totalDuration;
  Either<Song,DownloadedSong>? currentSong;
  final bool isPlaying;
  final bool isSongRepeatEnabled;
  final bool isPlaylistRepeatEnabled;
  final bool isShuffleEnabled;
  final SongHistory relatedSongs;
  final int currentSongIndex;
  final bool isLoading;
  final List<Map<String,dynamic>>? lyrics;
  final String? errorMessage;
  final bool isFromAlbum;

  PlayerState({required this.totalDuration,required this.songPosition,required this.currentSong, required this.isPlaying,required this.isSongRepeatEnabled,required this.isPlaylistRepeatEnabled, required this.isShuffleEnabled, required this.relatedSongs, required this.currentSongIndex, required this.isLoading, required this.lyrics,required this.errorMessage, required this.isFromAlbum});
  PlayerState copyWith({
    Duration? songPosition,
    Duration? totalDuration,
    Either<Song,DownloadedSong>? currentSong,
    bool? isPlaying,
    bool? isSongRepeatEnabled,
    bool? isPlaylistRepeatEnabled,
    bool? isShuffleEnabled,
    SongHistory? relatedSongs,
    int? currentSongIndex,
    bool? isLoading,
    List<Map<String,dynamic>>? lyrics,
    String? errorMessage,
    bool? isFromAlbum

  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      totalDuration: totalDuration ?? this.totalDuration,
      isSongRepeatEnabled: isSongRepeatEnabled ?? this.isSongRepeatEnabled,
       lyrics: lyrics ?? this.lyrics,
      isPlaylistRepeatEnabled: isPlaylistRepeatEnabled ?? this.isPlaylistRepeatEnabled,
      songPosition: songPosition ?? this.songPosition,
      isPlaying: isPlaying ?? this.isPlaying,

      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      relatedSongs: relatedSongs ?? this.relatedSongs,
      currentSongIndex: currentSongIndex ?? this.currentSongIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isFromAlbum: isFromAlbum ?? this.isFromAlbum

    );
  }

}

