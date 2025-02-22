import 'package:dio/dio.dart';

import 'package:jazz/features/stream_feature/data/models/Mp3StreamModel.dart';

class Mp3streamDatasource {


  Mp3streamDatasource();
  final Dio dio = Dio();
  final List<String> apiKeyList = ["14a93bf7a5msh51f11db7d121aeap1c4625jsn5cfbb89ff05b",
  "6111b62d2dmshd13d20b55abbbe8p1f8551jsn2e425d987b94",
  "fcdf2c5ba1msh397175bf89fe87ep19fe51jsn76bc6eddb936",
    "ab47a3c2camsh4097dc8ff0fb89fp1d95e6jsna047ccc76ab6",
  "3b6e8de0bfmshf1110629d4a95b0p11b000jsn264f29acc2b0",
    "9203689df7msh9f35abfe7467ce8p12ca71jsn625743a17f66"
  ];
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
  Future<Mp3StreamModel?> getMp3Link(String videoId,String videoUrl) async {

    final downloadUrl = await fetchDownloadUrlResponse(videoId,videoUrl);



        if (downloadUrl != null) {
          return Mp3StreamModel(url: downloadUrl);
        }


    return null;
  }

  Future<String?> fetchDownloadUrlResponse(String videoId,String videoUrl)async{
    for(var apiKey in apiKeyList){
     try{
       final Response response = await dio.get(
         'https://youtube-mp36.p.rapidapi.com/dl',
         queryParameters: {"id": videoId},
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
                 queryParameters: {"url": videoUrl},
                 options: Options(
                   headers: {
                     "x-rapidapi-key": backupApiKey,
                     "x-rapidapi-host": backupApiHostAndUrl["apiHost"],
                   },
                 ),
               );
               if (  response.statusCode == 200 && response.data != null) {
                 return response.data["download"];
               }
             }catch(e){

             }
           }
         }
       }
       if (  response.statusCode == 200 && response.data != null){
         return response.data["link"];
       }

     }on DioException catch(e){
       if(e.response?.statusCode == 429){

       }
     }

    }
    return null;
  }
}
