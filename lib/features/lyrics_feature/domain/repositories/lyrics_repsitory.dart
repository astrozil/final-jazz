import 'package:dartz/dartz.dart';
import 'package:jazz/core/failure/failure.dart';

abstract class LyricsRepository {
  Future<List<Map<String, dynamic>>?> getLyrics(String artist,String songName);
}