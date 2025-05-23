import 'package:dartz/dartz.dart';
import 'package:jazz/core/failure/failure.dart';
import 'package:jazz/features/lyrics_feature/data/data_source/lyrics_data_source.dart';
import 'package:jazz/features/lyrics_feature/domain/repositories/lyrics_repsitory.dart';

class LyricsRepoImpl extends LyricsRepository{
  final LyricsDataSource lyricsDataSource;

  LyricsRepoImpl ({required this.lyricsDataSource});
  @override
  Future<List<Map<String, dynamic>>?> getLyrics(String artist,String songName)async {
    return await lyricsDataSource.getSyncedLyrics(trackName: songName,artistName: artist);
  }

}