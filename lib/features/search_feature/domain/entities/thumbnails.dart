class YtThumbnail {
  final String url;
  final int width;
  final int height;

  YtThumbnail({
    required this.url,
    required this.width,
    required this.height,
  });

  factory YtThumbnail.fromJson(Map<String, dynamic> json) {
    return YtThumbnail(
      url: json['url'],
      width: json['width'],
      height: json['height'],
    );
  }
}

class YtThumbnails {
  final YtThumbnail defaultThumbnail;
  final YtThumbnail mediumThumbnail;
  final YtThumbnail highThumbnail;

  YtThumbnails({
    required this.defaultThumbnail,
    required this.mediumThumbnail,
    required this.highThumbnail,
  });

  factory YtThumbnails.fromJson(Map<String, dynamic> json) {
    return YtThumbnails(
      defaultThumbnail: YtThumbnail.fromJson(json['default']),
      mediumThumbnail: YtThumbnail.fromJson(json['medium']),
      highThumbnail: YtThumbnail.fromJson(json['high']),
    );
  }
}
