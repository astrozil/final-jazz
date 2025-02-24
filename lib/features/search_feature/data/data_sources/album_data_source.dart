import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jazz/core/failure/failure.dart';
import 'package:jazz/features/search_feature/domain/entities/album.dart';
import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

class AlbumDatasource {
  Dio dio = Dio();
  static const baseUrl = "https://ytmusic-4diq.onrender.com/album/";
  static const baseUrlForSongMetadata = 'https://ytmusic-4diq.onrender.com/song/';

  Future<Either<Failure,Album>> searchAlbumMetadata(String albumId)async{
    try{
      late Album album;
      final response = await dio.get("$baseUrl$albumId");
      if(response.statusCode == 200 && response.data != null){
        var data = response.data;
        var tracksResult = data['tracks'];
        List<RelatedSong> tracks = [];
        for(var track in tracksResult){
          tracks.add(
            RelatedSong(
                url: "",
                song: Song(
                    url: 'https://www.youtube.com/watch?v=${track['videoId']}',
                    title: track['title'],
                    artist: track['artists'][0]['name'],
                    id: track['videoId'],
                    resultType:  track['resultType'] ?? "",
                    category: "",
                    browseId: '',
                    thumbnails: YtThumbnails(
                        defaultThumbnail: YtThumbnail(
                            url: "",
                            width: 0,
                            height: 0),
                        mediumThumbnail: YtThumbnail(
                            url: "",
                            width: 0,
                            height: 0),
                        highThumbnail: YtThumbnail(
                            url: "",
                            width: 0,
                            height: 0))
            )
            )
          );
        }
         album = Album(
            artist: data['artists'][0]['name']?? '',
            artistId:  data['artists'][0]['id'] ?? '',
            description: data['description'] ?? '',
            duration: data['duration'] ?? '',
            ytThumbnail: YtThumbnail(
                url: data['thumbnails'][0]['url'],
                width: data['thumbnails'][0]['width'],
                height: data['thumbnails'][0]['height']
            ),
            title: data['title']?? "",
            trackCount: data['trackCount']?? 0,
            tracks:tracks,
           year: data['year']?? "",
           type: data['type'] ?? "",
             browseId: data['browseId'] ?? ""
        );

      }
      return right(album);
    }catch(e){
      print(e.toString());
      return left(ServerFailure(e.toString()));
    }

  }
  Future<Either<Failure,YtThumbnail>> fetchTrackThumbnail(String songId)async{
    try{
      late YtThumbnail ytThumbnail;
      final response = await dio.get('$baseUrlForSongMetadata$songId');
      if(response.statusCode == 200 && response.data != null){
        var data = response.data;
        ytThumbnail = YtThumbnail(
            url: data['videoDetails']['thumbnail']['thumbnails'][0]['url'],
            width: data['videoDetails']['thumbnail']['thumbnails'][0]['width'],
            height: data['videoDetails']['thumbnail']['thumbnails'][0]['height']);
      }
      return right(ytThumbnail);
    }catch(e){
      return left(ServerFailure(e.toString()));
    }

  }
}