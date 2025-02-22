part of 'downloaded_songs_bloc.dart';

@immutable
sealed class DownloadedSongsState {}

final class DownloadedSongsInitial extends DownloadedSongsState {}

final class GettingDownloadedSongsState extends DownloadedSongsState{

}

final class GotDownloadedSongsState extends DownloadedSongsState{
 final List<DownloadedSong> downloadedSongs;
   GotDownloadedSongsState({required this.downloadedSongs});
}
final class NoDownloadedSongsState extends DownloadedSongsState{

}

final class ErrorGettingDownloadedSongsState extends DownloadedSongsState{

}