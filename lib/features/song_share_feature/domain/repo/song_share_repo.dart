import 'package:jazz/features/song_share_feature/domain/entities/shared_song.dart';

abstract class SharedSongRepository {
  Future<void> shareSong(SharedSong sharedSong);
  Stream<List<SharedSong>> getReceivedSharedSongs(String userId);
  Stream<List<SharedSong>> getSentSharedSongs(String userId);
  Future<void> markAsViewed(String sharedSongId);
}