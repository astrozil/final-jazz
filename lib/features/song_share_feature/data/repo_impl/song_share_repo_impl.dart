// lib/data/repositories/shared_song_repository_impl.dart
import 'package:jazz/features/song_share_feature/data/data_source/song_share_data_source.dart';
import 'package:jazz/features/song_share_feature/data/models/shared_song_model.dart';
import 'package:jazz/features/song_share_feature/domain/entities/shared_song.dart';
import 'package:jazz/features/song_share_feature/domain/repo/song_share_repo.dart';





class SongShareRepoImpl implements SharedSongRepository {
  final SongShareDataSource dataSource;

  SongShareRepoImpl(this.dataSource);

  @override
  Future<void> shareSong(SharedSong sharedSong) async {
   await  dataSource.shareSong(SharedSongModel(
      id: sharedSong.id,
      senderId: sharedSong.senderId,
      receiverId: sharedSong.receiverId,
      songId: sharedSong.songId,
      songName: sharedSong.songName,
      artistName: sharedSong.artistName,
      type: sharedSong.type,
      albumArt: sharedSong.albumArt,
      message: sharedSong.message,
      isViewed: sharedSong.isViewed,
      createdAt: sharedSong.createdAt,
    ));
  }

  @override
  Stream<List<SharedSongModel>> getReceivedSharedSongs(String userId) {
    return dataSource.getReceivedSharedSongs(userId);
  }

  @override
  Stream<List<SharedSongModel>> getSentSharedSongs(String userId) {
    return dataSource.getSentSharedSongs(userId);
  }

  @override
  Future<void> markAsViewed(String sharedSongId) {
    return dataSource.markAsViewed(sharedSongId);
  }
}
