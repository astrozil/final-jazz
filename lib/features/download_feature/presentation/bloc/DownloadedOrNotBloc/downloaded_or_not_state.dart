part of 'downloaded_or_not_bloc.dart';

@immutable
sealed class DownloadedOrNotState {}

final class DownloadedOrNotInitial extends DownloadedOrNotState {}
final class DownloadedSongState extends DownloadedOrNotState{


}

final class NotDownloadedSongState extends DownloadedOrNotState{

}

final class DeletedSongState extends DownloadedOrNotState{

}