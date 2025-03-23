import 'package:jazz/features/playlist_feature/domain/entities/billboard_song.dart';
import 'package:jazz/features/playlist_feature/domain/repositories/playlist_repo.dart';


class FetchBillboardSongsUseCase {
  final PlaylistRepo _playlistRepo;

  FetchBillboardSongsUseCase({
    required PlaylistRepo playlistRepo
  }): _playlistRepo = playlistRepo;

  Future<List<BillboardSong>> call(){
    return _playlistRepo.fetchBillboardSongsPlaylist();
  }
}