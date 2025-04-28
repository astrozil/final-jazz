class YtThumbnail {
  final String url;
  final int width;
  final int height;

  YtThumbnail({
    required this.url,
    required this.width,
    required this.height,
  });

  factory YtThumbnail.fromJson(Map? json) {
    return YtThumbnail(
      url: json?['url'] as String? ?? "",
      width: json?['width'] as int? ?? 0,
      height: json?['height'] as int? ?? 0,
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'url': url,
      'width': width,
      'height': height,
    };
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

  factory YtThumbnails.fromJson(List json) {
    return YtThumbnails(
      defaultThumbnail: YtThumbnail.fromJson(json[0] as Map? ?? {}),
      mediumThumbnail: YtThumbnail.fromJson(json.length > 1 ? json[1] : json[0]),
      highThumbnail: YtThumbnail.fromJson(json.length >2? json[2] : json.length >1 ? json[1] : json[0]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'default': defaultThumbnail.toJson(),
      'medium': mediumThumbnail.toJson(),
      'high': highThumbnail.toJson(),
    };
  }
}
