class DownloadRequest{
  final String videoID;
  final String title;
  final String artist;
  final String thumbnail;
  final String videoUrl;
  int alreadyDownloadedBytes;
   DownloadRequest({required this.videoID,required this.artist,required this.title,required this.thumbnail, int? alreadyDownloadedBytes, required this.videoUrl}) : alreadyDownloadedBytes = alreadyDownloadedBytes ?? 0;
}