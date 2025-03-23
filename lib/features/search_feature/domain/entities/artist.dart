  import 'package:jazz/features/search_feature/domain/entities/album.dart';
  import 'package:jazz/features/search_feature/domain/entities/song.dart';
  import 'package:jazz/features/search_feature/domain/entities/thumbnails.dart';

  class Artist {
    final String name;
    final String browseId; // Parsed from channelId in the JSON.
    final String category;
    final String radioId;
    final String resultType;
    final String shuffleId;
    final List<YtThumbnail> thumbnails;
    final List<Album> albums;
    final List<Song> songs;
    final String description;
    final List<Single> singles;

    Artist({
      required this.name,
      required this.browseId,
      required this.category,
      required this.radioId,
      required this.resultType,
      required this.shuffleId,
      required this.thumbnails,
      required this.albums,
      required this.description,
      required this.singles,
      required this.songs
    });

    Artist copyWith({
      String? name,
      String? browseId,
      String? category,
      String? radioId,
      String? resultType,
      String? shuffleId,
      List<YtThumbnail>? thumbnails,
      List<Album>? albums,
      String? description,
      List<Single>? singles,
      List<Song>? songs
    }) {
      return Artist(
        name: name ?? this.name,
        browseId: browseId ?? this.browseId,
        category: category ?? this.category,
        radioId: radioId ?? this.radioId,
        resultType: resultType ?? this.resultType,
        shuffleId: shuffleId ?? this.shuffleId,
        thumbnails: thumbnails ?? this.thumbnails,
        albums: albums ?? this.albums,
        description: description ?? this.description,
        singles: singles ?? this.singles,
        songs: songs ?? this.songs
      );
    }

    factory Artist.fromJson(Map<String, dynamic> json) {
      return Artist(
        name: json['name'] as String? ?? json['artist'] ?? '',
        // Use "channelId" from JSON instead of "browseId"
        browseId: json['browseId'] as String? ?? '',
        category: json['category'] as String? ?? '',
        radioId: json['radioId'] as String? ?? '',
        resultType: json['resultType'] as String? ?? '',
        shuffleId: json['shuffleId'] as String? ?? '',
        thumbnails: (json['thumbnails'] as List<dynamic>?)
            ?.map((e) => YtThumbnail.fromJson(e as Map<String, dynamic>))
            .toList() ??
            [],
        // Extract the list from the nested "results" key.
        albums: (json['albums']?['results'] as List<dynamic>?)
            ?.map((e) => Album.fromJson(e as Map<String, dynamic>))
            .toList() ??
            [],
        description: json['description'] as String? ?? '',
        // Extract singles from the nested "results" key.
        singles: (json['singles']?['results'] as List<dynamic>?)
            ?.map((e) => Single.fromJson(e as Map<String, dynamic>))
            .toList() ??
            [],
        songs: (json['songs']?['results'] as List<dynamic>?)
               ?.map((e)=> Song.fromJson(e as Map<String,dynamic>))
          .toList() ?? []
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'name': name,
        'channelId': browseId,
        'category': category,
        'radioId': radioId,
        'resultType': resultType,
        'shuffleId': shuffleId,

        'songs': songs.map((e)=> e.toJson()).toList(),
        'thumbnails': thumbnails.map((e) => e.toJson()).toList(),
        // Wrap albums and singles into objects with a "results" key.
        'albums': {
          'results': albums.map((e) => e.toJson()).toList(),
        },
        'description': description,
        'singles': {
          'results': singles.map((e) => e.toJson()).toList(),
        },
      };
    }
  }

  class Single {
    final String browseId;
    final YtThumbnail thumbnail;
    final String title;
    final String year;

    Single({
      required this.browseId,
      required this.thumbnail,
      required this.title,
      required this.year,
    });

    factory Single.fromJson(Map<String, dynamic> json) {
      final thumbnailsList = json['thumbnails'] as List<dynamic>?;
      final thumbnailData = thumbnailsList != null && thumbnailsList.isNotEmpty
          ? thumbnailsList.first as Map<String, dynamic>
          : null;
      return Single(
        browseId: json['browseId'] as String? ?? '',
        thumbnail: thumbnailData != null
            ? YtThumbnail.fromJson(thumbnailData)
            : YtThumbnail(url: '', width: 0, height: 0),
        title: json['title'] as String? ?? '',
        year: json['year'] as String? ?? '',
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'browseId': browseId,
        // Output as a list with one thumbnail.
        'thumbnails': [thumbnail.toJson()],
        'title': title,
        'year': year,
      };
    }
  }
