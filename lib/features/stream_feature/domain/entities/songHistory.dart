import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:jazz/features/download_feature/domain/entities/downloadedSong.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

class SongHistory {
  final Either<List<RelatedSong>, List<DownloadedSong>> _history;

  SongHistory({required Either<List<RelatedSong>, List<DownloadedSong>> history}) : _history = history;

  Either<List<RelatedSong>, List<DownloadedSong>> get history => _history;

  int get length => _history.fold((related) => related.length, (downloaded) => downloaded.length);

  bool hasRelatedSongs() => _history.isLeft();
  static SongHistory empty({bool isStreamed = true}) {
    if (isStreamed) {
      return SongHistory(history: left([])); // Empty related songs list
    } else {
      return SongHistory(history: right([])); // Empty downloaded songs list
    }
  }
  Either<RelatedSong, DownloadedSong> getSongAt(int index) {
    return _history.fold(
          (relatedSongs) => left(relatedSongs[index]),
          (downloadedSongs) => right(downloadedSongs[index]),
    );
  }

  SongHistory addSong(Either<RelatedSong, DownloadedSong> song) {
    return SongHistory(
      history: _history.fold(
            (relatedSongs) {
          song.fold((relatedSong) => relatedSongs.add(relatedSong), (_) {});
          return left(List<RelatedSong>.from(relatedSongs));
        },
            (downloadedSongs) {
          song.fold((_) {}, (downloadedSong) => downloadedSongs.add(downloadedSong));
          return right(List<DownloadedSong>.from(downloadedSongs));
        },
      ),
    );
  }
  SongHistory addSongs(Either<List<RelatedSong>, List<DownloadedSong>> songs) {
    return SongHistory(
      history: _history.fold(
            (relatedSongs) {
          final updatedRelatedSongs = Set<RelatedSong>.from(relatedSongs);
          songs.fold(
                (newRelatedSongs) {
              updatedRelatedSongs.addAll(newRelatedSongs.where((song) => !updatedRelatedSongs.contains(song)));
            },
                (_) {},
          );
          return left(updatedRelatedSongs.toList());
        },
            (downloadedSongs) {
          final updatedDownloadedSongs = Set<DownloadedSong>.from(downloadedSongs);
          songs.fold(
                (_) {},
                (newDownloadedSongs) {
              updatedDownloadedSongs.addAll(newDownloadedSongs.where((song) => !updatedDownloadedSongs.contains(song)));
            },
          );
          return right(updatedDownloadedSongs.toList());
        },
      ),
    );
  }

  SongHistory mapRelatedSongs(List<RelatedSong> Function(List<RelatedSong>) transform) {
    return SongHistory(
      history: _history.leftMap(transform),
    );
  }
  SongHistory shuffleWithPriorityAt(int prioritizedIndex) {
    print("HEFEOIFHEO");
    return SongHistory(
      history: _history.fold(
            (relatedSongs) {
          List<RelatedSong> copy = List<RelatedSong>.from(relatedSongs);
          if (prioritizedIndex >= 0 && prioritizedIndex < copy.length) {
            // Remove the item at the given index.
            final prioritizedSong = copy.removeAt(prioritizedIndex);
            // Shuffle the remaining items.
            copy.shuffle();
            // Insert the prioritized item at the beginning.
            copy.insert(0, prioritizedSong);
          } else {
            // If the index is invalid, just shuffle normally.
            copy.shuffle();
          }
          return left(copy);
        },
            (downloadedSongs) {
          List<DownloadedSong> copy = List<DownloadedSong>.from(downloadedSongs);
          if (prioritizedIndex >= 0 && prioritizedIndex < copy.length) {
            final prioritizedSong = copy.removeAt(prioritizedIndex);
            copy.shuffle();
            copy.insert(0, prioritizedSong);
          } else {
            copy.shuffle();
          }
          return right(copy);
        },
      ),
    );
  }

  int indexWhere(bool Function(dynamic song) predicate) {
    return _history.fold(
          (relatedSongs) => relatedSongs.indexWhere(predicate),
          (downloadedSongs) => downloadedSongs.indexWhere(predicate),
    );
  }
  SongHistory shuffle() {
    return SongHistory(
      history: _history.fold(
            (relatedSongs) {
          relatedSongs.shuffle();
          return left(List<RelatedSong>.from(relatedSongs));
        },
            (downloadedSongs) {
          downloadedSongs.shuffle();
          return right(List<DownloadedSong>.from(downloadedSongs));
        },
      ),
    );

  }

  SongHistory reset() {
    return SongHistory(
      history: _history.fold((_) => left([]), (_) => right([])),
    );
  }

  SongHistory clone() {
    return SongHistory(
      history: _history.fold(
            (relatedSongs) => left(List<RelatedSong>.from(relatedSongs)),
            (downloadedSongs) => right(List<DownloadedSong>.from(downloadedSongs)),
      ),
    );
  }

  Future<SongHistory> mapBoth({
    required dynamic Function(List<RelatedSong>) onRelatedSongs,
    required dynamic Function(List<DownloadedSong>) onDownloadedSongs,
  }) async{
    return SongHistory(
      history: _history.fold(
            (relatedSongs) =>  left( onRelatedSongs(relatedSongs)),
            (downloadedSongs) =>  right(onDownloadedSongs(downloadedSongs)),
      ),
    );
  }
  Future<SongHistory> mapBothAsync({
    required FutureOr<List<RelatedSong>> Function(List<RelatedSong>) onRelatedSongs,
    required FutureOr<List<DownloadedSong>> Function(List<DownloadedSong>) onDownloadedSongs,
  }) async {
    if (_history.isLeft()) {
      // Get the left value (related songs)
      List<RelatedSong> relatedSongs = _history.fold((l) => l, (r) => []);
      // Await the asynchronous mapping function
      final newRelatedSongs = await onRelatedSongs(relatedSongs);
      return SongHistory(history: left(newRelatedSongs));
    } else {
      // Get the right value (downloaded songs)
      List<DownloadedSong> downloadedSongs = _history.fold((l) => [], (r) => r);
      // Await the asynchronous mapping function
      final newDownloadedSongs = await onDownloadedSongs(downloadedSongs);
      return SongHistory(history: right(newDownloadedSongs));
    }
  }
}



