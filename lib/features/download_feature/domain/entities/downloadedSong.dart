import 'dart:io';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class DownloadedSong extends Equatable {
  final String songName;
  final String artist;
  final String album;
  final Uint8List? image;
  final File songFile;

  DownloadedSong({
    required this.songName,
    required this.image,
    required this.album,
    required this.artist,
    required this.songFile,
  });

  @override
  List<Object?> get props => [songName, artist, album, songFile.path];
}
 