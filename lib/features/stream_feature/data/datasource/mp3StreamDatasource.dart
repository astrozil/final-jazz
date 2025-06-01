// lib/features/stream_feature/data/datasources/mp3stream_datasource.dart

import 'package:dio/dio.dart';
import 'package:jazz/features/stream_feature/data/models/Mp3StreamModel.dart';

class Mp3streamDatasource {
  Mp3streamDatasource();

  final Dio dio = Dio();

  // your primary API keys
  final List<String> apiKeyList = [
    "14a93bf7a5msh51f11db7d121aeap1c4625jsn5cfbb89ff05b",
    "6111b62d2dmshd13d20b55abbbe8p1f8551jsn2e425d987b94",
    "fcdf2c5ba1msh397175bf89fe87ep19fe51jsn76bc6eddb936",
    "ab47a3c2camsh4097dc8ff0fb89fp1d95e6jsna047ccc76ab6",
    "3b6e8de0bfmshf1110629d4a95b0p11b000jsn264f29acc2b0",
    "9203689df7msh9f35abfe7467ce8p12ca71jsn625743a17f66"
  ];
  final String apiHost = "youtube-mp36.p.rapidapi.com";

  // your rare‐used backup host & keys
  final List<String> backupApiKeyList = [
    "3b6e8de0bfmshf1110629d4a95b0p11b000jsn264f29acc2b0"
  ];
  final List<Map<String, String>> backupApiHostListAndUrl = [
    {
      "apiHost": "yt-search-and-download-mp3.p.rapidapi.com",
      "url": "https://yt-search-and-download-mp3.p.rapidapi.com/mp3"
    }
  ];

  // **in-memory cache** to avoid refetching
  final _urlCache = <String, String?>{};

  /// Public: returns cached or freshly‐fetched link
  Future<Mp3StreamModel?> getMp3Link(String videoId, String videoUrl) async {
    if (_urlCache.containsKey(videoId)) {
      final cached = _urlCache[videoId];
      if (cached != null) return Mp3StreamModel(url: cached);
    }

    final link = await fetchDownloadUrlResponse(videoId, videoUrl);
    _urlCache[videoId] = link;
    return link == null ? null : Mp3StreamModel(url: link);
  }

  /// Fire‐and‐forget: kick off a fetch so it’s warm in cache
  void prefetch(String videoId, String videoUrl) {
    if (!_urlCache.containsKey(videoId)) {
      fetchDownloadUrlResponse(videoId, videoUrl)
          .then((link) => _urlCache[videoId] = link);
    }
  }

  /// Core: try all primary keys in parallel, fallback to backups if needed
  Future<String?> fetchDownloadUrlResponse(
      String videoId, String videoUrl) async {
    // 1) parallel primary keys
    final attempts = apiKeyList.map((key) async {
      try {
        final resp = await dio.get(
          'https://$apiHost/dl',
          queryParameters: {"id": videoId},
          options: Options(headers: {
            "x-rapidapi-key": key,
            "x-rapidapi-host": apiHost,
          }),
        );
        final link = resp.data['link'] as String?;
        if (resp.statusCode == 200 && link?.isNotEmpty == true) {
          return link;
        }
      } catch (_) {}
      return null;
    });

    try {
      // completes with the first non-null String
      final first = await Future.any<String?>(attempts);
      if (first != null) return first;
    } catch (_) {
      // all primary calls failed or returned null
    }

    // 2) fallback: sequential backups
    for (final backup in backupApiHostListAndUrl) {
      for (final key in backupApiKeyList) {
        try {
          final resp = await dio.get(
            backup['url']!,
            queryParameters: {"url": videoUrl},
            options: Options(headers: {
              "x-rapidapi-key": key,
              "x-rapidapi-host": backup['apiHost']!,
            }),
          );
          final dl = resp.data['download'] as String?;
          if (resp.statusCode == 200 && dl?.isNotEmpty == true) {
            return dl;
          }
        } catch (_) {}
      }
    }

    return null;
  }
}
