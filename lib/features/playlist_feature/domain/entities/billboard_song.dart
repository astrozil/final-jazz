import 'package:jazz/features/search_feature/domain/entities/song.dart';
import 'package:jazz/features/stream_feature/domain/entities/RelatedSong.dart';

class BillboardSong extends RelatedSong {
  final int lastPos;
  final int peakPos;
  final int rank;
  final int weeks;

  const BillboardSong({
    required this.lastPos,
    required this.peakPos,
    required this.rank,
    required this.weeks,
    required super.url,
    required super.song,
  });

  factory BillboardSong.fromJson(Map<String, dynamic> json) {
    final baseSong = Song.fromJson(json['ytmusic_result']);
    return BillboardSong(
      url: "",
      song: baseSong,
      rank: json['rank'] as int? ?? 0,
      peakPos: json['peakPos'] as int? ?? 0,
      weeks: json['weeks'] as int? ?? 0,
      lastPos: json['lastPos'] as int? ?? 0,
    );
  }

  BillboardSong copyWith({
    int? lastPos,
    int? peakPos,
    int? rank,
    int? weeks,
    String? url,
    Song? song,
  }) {
    return BillboardSong(
      lastPos: lastPos ?? this.lastPos,
      peakPos: peakPos ?? this.peakPos,
      rank: rank ?? this.rank,
      weeks: weeks ?? this.weeks,
      url: url ?? this.url,
      song: song ?? this.song,
    );
  }
}
