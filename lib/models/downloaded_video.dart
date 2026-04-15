class DownloadedVideo {
  final int movieId;
  final String title;
  final String posterPath;
  final String sourceUrl;
  final String localPath;
  final int downloadedAtMs;

  const DownloadedVideo({
    required this.movieId,
    required this.title,
    required this.posterPath,
    required this.sourceUrl,
    required this.localPath,
    required this.downloadedAtMs,
  });

  factory DownloadedVideo.fromJson(Map<String, dynamic> json) {
    return DownloadedVideo(
      movieId: (json['movieId'] ?? 0) as int,
      title: (json['title'] ?? '').toString(),
      posterPath: (json['posterPath'] ?? '').toString(),
      sourceUrl: (json['sourceUrl'] ?? '').toString(),
      localPath: (json['localPath'] ?? '').toString(),
      downloadedAtMs: (json['downloadedAtMs'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'movieId': movieId,
        'title': title,
        'posterPath': posterPath,
        'sourceUrl': sourceUrl,
        'localPath': localPath,
        'downloadedAtMs': downloadedAtMs,
      };
}

