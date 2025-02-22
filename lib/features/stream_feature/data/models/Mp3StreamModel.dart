
import 'package:jazz/features/stream_feature/domain/entities/mp3Stream.dart';

class Mp3StreamModel extends Mp3Stream {
  Mp3StreamModel({required super.url});

  factory Mp3StreamModel.fromJson(Map<String, dynamic> json) {
    return Mp3StreamModel(url: json['link']);
  }
}
