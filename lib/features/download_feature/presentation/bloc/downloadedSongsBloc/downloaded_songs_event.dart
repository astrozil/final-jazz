part of 'downloaded_songs_bloc.dart';

@immutable
sealed class DownloadedSongsEvent {}

final class GetDownloadedSongsEvent extends DownloadedSongsEvent{

}