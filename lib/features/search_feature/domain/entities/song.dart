import 'package:equatable/equatable.dart';
import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';

class Song extends Equatable {
  final String url;
  final String title;
  final List<dynamic> artists;
  final String resultType;
  final String id;
  final String category;
  final String browseId;
  final YtThumbnails thumbnails;
  final String duration;
  final Map<dynamic,dynamic>? album;

  Song({
    required this.url,
    required this.title,
    required this.artists,
    required this.id,
    required this.category,
    required this.browseId,
    required this.thumbnails,
    required this.resultType,
    required this.duration,
    required this.album
  });

  Song copyWith({
    String? url,
    String? title,
    List<Map<dynamic,dynamic>>? artists,
    String? duration,
    String? id,
    String? category,
    String? resultType,
    String? browseId,
    YtThumbnails? thumbnails,
    Map<dynamic,dynamic>? album
  }) {
    return Song(
      url: url ?? this.url,
      title: title ?? this.title,
      artists: artists ?? this.artists,
      id: id ?? this.id,
      resultType: resultType ?? this.resultType,
      category: category ?? this.category,
      browseId: browseId ?? this.browseId,
      thumbnails: thumbnails ?? this.thumbnails,
      duration: duration ?? this.duration,
      album: album ?? this.album
    );
  }

  factory Song.fromJson(Map<dynamic, dynamic> json) {
   try {
     return Song(
       url: json['url'] as String? ??
           (json['videoId'] != null
               ? "https://www.youtube.com/watch?v=${json['videoId']}"
               : ""),
       title: json['title'] as String? ?? "",
       artists: json['artists'] is List
           ? List<Map<String, dynamic>>.from(json['artists'] as List)
           : [{
         'name': json['artist']
       }
       ],
       id: json['videoId'] as String? ?? "",
       resultType: json['resultType'] as String? ?? "",
       category: json['category'] as String? ?? "",
       browseId: json['browseId'] as String? ?? "",
       thumbnails: YtThumbnails.fromJson(
         json['thumbnails'] != null ? json['thumbnails'] as List :
             json['thumbnail'] as List<dynamic>? ?? [],
       ),
       album: json['album'] != null ? json['album'] is Map ? Map<
           dynamic,
           dynamic>.from(json['album']) : null : null,
       duration: json['duration'] as String? ?? "",
     );
   }catch(e){
     print("Error is ${e.toString()}");
   }
   return Song(
     url: json['url'] as String? ??
         (json['videoId'] != null
             ? "https://www.youtube.com/watch?v=${json['videoId']}"
             : ""),
     title: json['title'] as String? ?? "",
     artists: json['artists'] is List
         ? List<Map<String, dynamic>>.from(json['artists'] as List)
         : [{
       'name': json['artist']
     }
     ],
     id: json['videoId'] as String? ?? "",
     resultType: json['resultType'] as String? ?? "",
     category: json['category'] as String? ?? "",
     browseId: json['browseId'] as String? ?? "",
     thumbnails: YtThumbnails.fromJson(
       json['thumbnails'] != null ? json['thumbnails'] as List :
           json['thumbnail'] as List<dynamic>? ?? [],
     ),
     album: json['album'] != null ? json['album'] is Map ? Map<
         dynamic,
         dynamic>.from(json['album']) : null : null,
     duration: json['duration'] as String? ?? "",
   );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'artist': artists,
      'videoId': id,
      'resultType': resultType,
      'category': category,
      'browseId': browseId,
      'thumbnails': thumbnails.toJson(),
    };
  }

  @override
  List<Object?> get props => [id];
}
