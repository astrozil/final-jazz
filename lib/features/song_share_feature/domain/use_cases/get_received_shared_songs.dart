import 'package:jazz/features/song_share_feature/domain/entities/shared_song.dart';
import 'package:jazz/features/song_share_feature/domain/repo/song_share_repo.dart';

class GetReceivedSharedSongs {
  final SharedSongRepository repository;

  GetReceivedSharedSongs(this.repository);

  Stream<List<SharedSong>> execute(String userId) {
    return repository.getReceivedSharedSongs(userId);
  }
}