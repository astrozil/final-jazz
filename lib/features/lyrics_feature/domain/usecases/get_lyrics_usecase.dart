import 'package:dartz/dartz.dart';
import 'package:jazz/core/failure/failure.dart';
import 'package:jazz/features/lyrics_feature/domain/repositories/lyrics_repsitory.dart';

class GetLyrics{
  final LyricsRepository lyricsRepository;
  GetLyrics(this.lyricsRepository);

  Future<List<Map<String,dynamic>>?> call(String artist, String songName)async{

       return await lyricsRepository.getLyrics(artist,songName);

  }
}