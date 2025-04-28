import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jazz/core/failure/failure.dart';

class LyricsDataSource{
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://lrclib.net/api',
    connectTimeout: const Duration(milliseconds: 5000),
    receiveTimeout: const Duration(milliseconds: 3000),
  ));

  Future<Map<String, dynamic>?> findLyrics({
    required String trackName,
    required String artistName,
    String? albumName,
    int? duration,
  }) async {
    try {
      final queryParams = {
        'track_name': trackName,
        'artist_name': artistName,
        if (albumName != null) 'album_name': albumName,
        if (duration != null) 'duration': duration.toString(),
      };

      final response = await _dio.get('/get', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print('Error fetching lyrics: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> getSyncedLyrics({
    required String trackName,
    required String artistName,
  }) async {
    try {
      final lyricsData = await findLyrics(
        trackName: trackName,
        artistName: artistName,
      );

      if (lyricsData != null && lyricsData['syncedLyrics'] != null) {
        // Parse the synced lyrics format which is in LRC format
        final String syncedLyricsText = lyricsData['syncedLyrics'];

        // Parse LRC format to get timestamped lyrics
        List<Map<String, dynamic>> parsedLyrics = [];

        // Split by lines
        final lines = syncedLyricsText.split('\n');
        for (var line in lines) {
          // LRC format: [MM:SS.ms] Lyrics text
          final match = RegExp(r'\[(\d+):(\d+)\.(\d+)\](.*)')
              .firstMatch(line);

          if (match != null) {
            final minutes = int.parse(match.group(1)!);
            final seconds = int.parse(match.group(2)!);
            final milliseconds = int.parse(match.group(3)!);
            final text = match.group(4)!.trim();

            final startTime = (minutes * 60 * 1000) +
                (seconds * 1000) +
                milliseconds;

            parsedLyrics.add({
              'text': text,
              'startTime': startTime,
            });
          }
        }

        return parsedLyrics;
      }
    } catch (e) {
      print('Error parsing synced lyrics: $e');
    }

    return null;
  }
}