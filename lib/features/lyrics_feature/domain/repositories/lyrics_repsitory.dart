import 'package:dartz/dartz.dart';
import 'package:jazz/core/failure/failure.dart';

abstract class LyricsRepository {
  Future<Either<Failure,String>> getLyrics(String artist,String songName);
}