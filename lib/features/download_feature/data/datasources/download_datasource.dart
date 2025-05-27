import 'dart:io';
import 'package:dio/dio.dart';
import 'package:jazz/features/download_feature/domain/entities/download_request.dart';
import 'package:path_provider/path_provider.dart';

class DownloadDataSource {
  final Dio dio = Dio();
  final List<String> apiKeyList = [
    "080345b0f5msh44a83d25e8b63f0p184dadjsn3c41b45e699e",
    "14a93bf7a5msh51f11db7d121aeap1c4625jsn5cfbb89ff05b",
    "6111b62d2dmshd13d20b55abbbe8p1f8551jsn2e425d987b94",
    "fcdf2c5ba1msh397175bf89fe87ep19fe51jsn76bc6eddb936"];
  final String apiHost = "youtube-mp36.p.rapidapi.com";

  final List<String> backupApiKeyList = [


      "3b6e8de0bfmshf1110629d4a95b0p11b000jsn264f29acc2b0"

  ];
  final List<Map<String,dynamic>> backupApiHostListAndUrl = [
    {
      "apiHost": "yt-search-and-download-mp3.p.rapidapi.com",
      "url" : "https://yt-search-and-download-mp3.p.rapidapi.com/mp3"
    }
  ];

  Future<void> downloadSongFromYoutube(
      DownloadRequest downloadRequest,
      Function(double, int) onProgress,
      CancelToken cancelToken, {
        int alreadyDownloadedBytes = 0,
      }) async {
    try {
      // Fetch the download link for the video
      final response = await fetchDownloadUrlResponse(downloadRequest);

      // If download link fetched successfully
      if ( response != null && response.statusCode == 200 && response.data != null) {
        final downloadUrl = response.data['link'];
        if (downloadUrl != null) {
          // Proceed to download the mp3 file

          await _downloadMp3(
              downloadUrl, downloadRequest.title,downloadRequest.artist,downloadRequest.videoID, onProgress, cancelToken,
              alreadyDownloadedBytes: alreadyDownloadedBytes);
        } else {
          throw Exception("Failed to get download link");
        }
      } else {
        throw Exception("Failed to fetch download link: ${response?.statusCode}");
      }
    } catch (e) {
      print('Error fetching download link: $e');
    }
  }

  Future<Response?> fetchDownloadUrlResponse(DownloadRequest downloadRequest)async{
    for(var apiKey in apiKeyList){
      try{
        final Response response = await dio.get(
          'https://youtube-mp36.p.rapidapi.com/dl',
          queryParameters: {"id": downloadRequest.videoID},
          options: Options(
            headers: {
              "x-rapidapi-key": apiKey,
              "x-rapidapi-host": apiHost,
            },
          ),
        );
       if(response.data['link'] == ""){
              for(var backupApiHostAndUrl in backupApiHostListAndUrl){
                for(var backupApiKey in backupApiKeyList) {
                  try {
                    final Response response = await dio.get(
                      backupApiHostAndUrl["url"],
                      queryParameters: {"url": downloadRequest.videoUrl},
                      options: Options(
                        headers: {
                          "x-rapidapi-key": backupApiKey,
                          "x-rapidapi-host": backupApiHostAndUrl["apiHost"],
                        },
                      ),
                    );
                    return response;
                  }catch(e){

                  }
                }
              }
       }
       return response;
      }on DioException catch(e){
        if(e.response?.statusCode == 429){

        }
      }
    }
    return null;
  }

  Future<void> _downloadMp3(
      String url,
      String title,
      String artist,
      String videoID,
      Function(double, int) onProgress,
      CancelToken cancelToken, {
        int alreadyDownloadedBytes = 0, // Bytes already downloaded
      }) async {
    try {
      Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception("Unable to access external storage");
      }

      String filePath = '${directory.path}/$title-$artist-$videoID.mp3';
      print("Saving to: $filePath");

      File file = File(filePath);
      int fileLength = 0; // Length of the existing file (if partially downloaded)
      if (file.existsSync()) {
        fileLength = file.lengthSync();
      }

      // Combine alreadyDownloadedBytes and file length to start from correct point
      int totalDownloaded = fileLength + alreadyDownloadedBytes;

      // Download the remaining part of the file
      await dio.download(
        url,
        file.path,
        cancelToken: cancelToken,
        onReceiveProgress: (receivedBytes, totalBytes) {
          int totalDownloadedBytes = receivedBytes + fileLength;
          double progress = (totalDownloadedBytes / totalBytes) * 100; // Full file progress
          onProgress(progress, totalDownloadedBytes); // Report progress
        },
        options: Options(
          headers: {
            'Range': 'bytes=$fileLength-',  // Resume download from fileLength
          },
        ),
      );
      print('Downloaded successfully to $filePath');
    } catch (e) {
      print('Error downloading file: $e');
    }
  }
}
