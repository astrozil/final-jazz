import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jazz/core/failure/failure.dart';

class LyricsDataSource{

  final Dio dio = Dio();
  static const baseUrl = "https://ytmusic-4diq.onrender.com/lyrics";
  Future<Either<Failure,String>> getLyrics(String artist,String songName)async{
try{
    final response = await dio.get(baseUrl,queryParameters: {
      'title': songName,
      'artist': artist
    });
    if(response.statusCode == 200 && response.data != null){
      var data = response.data;
      String lyrics = data['lyrics'];
      lyrics = lyrics.replaceAll('\r\n', '\n');

      return right(lyrics);
    }else{
      return left(ServerFailure("No Lyrics Found"));
    }
}catch(e){
  return left(ServerFailure("No Lyrics Found"));
    }

  }
}