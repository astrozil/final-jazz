import 'dart:io';

import 'dart:typed_data';
import 'package:jazz/features/download_feature/domain/entities/downloadedSong.dart';
import 'package:jazz/features/download_feature/presentation/bloc/downloadedSongsBloc/downloaded_songs_bloc.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path_provider/path_provider.dart';

class DownloadedSongsMetadataDataSource{

  Future<List<DownloadedSong>?> getDownloadedSongsMetadata()async{


      List<File> downloadedFiles = [];
      List<DownloadedSong> downloadedSongs = [];
      final directory = await getExternalStorageDirectory() ?? Directory('/storage/emulated/0/Download');

      if (await directory.exists()) {
        downloadedFiles = directory
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.mp3')) // Filter only MP3 files
            .toList();
      }

      if (downloadedFiles.isEmpty) {

        return null;
      } else {

         // Initialize the metadata library
        for (var file in downloadedFiles) {

          final metadata = await MetadataGod.readMetadata(file: file.path);

          // Extract title, artist, and album from metadata
          final title = metadata.title ?? getTitleFromFileName(file.uri.pathSegments.last);
          final artist = getArtistFromFileName(file.uri.pathSegments.last) ?? "Unknown Artist";
          final id = getIdFromFileName(file.uri.pathSegments.last);
          final album = metadata.album ?? 'Unknown Album';

          // Extract album art if available
          Uint8List? albumArt;
          if (metadata.picture != null) {
            albumArt = metadata.picture!.data as Uint8List;
          }

          downloadedSongs.add(DownloadedSong(
            songName: title,
            image: albumArt,
            songFile: file,
            album: album,
            artist: artist,
            id: id,
            songSavedPath: file.uri.pathSegments.last
          ));
        }


      }
      return downloadedSongs;
    }

    String getTitleFromFileName(String fileName) {
      final regex = RegExp(r'^(.+)-(.+)\.mp3$');
      final match = regex.firstMatch(fileName);
      if (match != null) {
        return match.group(1) ?? 'Unknown Title'; // Extract the title
      }
      return fileName;
    }

  String getArtistFromFileName(String fileName) {
    final regex = RegExp(r'^(.+)-(.+)-(.+)\.mp3$');
    final match = regex.firstMatch(fileName);
    if (match != null) {
      return match.group(2) ?? 'Unknown Artist'; // Second group: artist
    }
    return 'Unknown Artist';
  }
  String getIdFromFileName(String fileName) {

    final regex = RegExp(r'^(.+)-(.+)-(.+)\.mp3$');
    final match = regex.firstMatch(fileName);
    if (match != null) {
      return match.group(3) ?? 'Unknown ID'; // Extract the video ID
    }
    return 'Unknown ID';
  }

}