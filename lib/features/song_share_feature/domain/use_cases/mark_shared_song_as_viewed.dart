import 'package:jazz/features/song_share_feature/domain/repo/song_share_repo.dart';

class MarkSharedSongAsViewed {
  final SharedSongRepository repository;

  MarkSharedSongAsViewed(this.repository);

  Future<void> execute(String sharedSongId) {
    return repository.markAsViewed(sharedSongId);
  }
}