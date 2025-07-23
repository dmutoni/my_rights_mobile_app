class Content {
  final String audioUrl;
  final List<ContentImage> images;
  final List<String> keyPoints;
  final String text;
  final String videoUrl;

  Content({
    required this.audioUrl,
    required this.images,
    required this.keyPoints,
    required this.text,
    required this.videoUrl,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      audioUrl: json['audioUrl'] ?? '',
      images: (json['images'] as List<dynamic>?)
          ?.map((image) => ContentImage.fromJson(image as Map<String, dynamic>))
          .toList() ?? [],
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      text: json['text'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
    );
  }
}

class ContentImage {
  String altText;
  String caption;
  String url;

  ContentImage({
    required this.altText,
    required this.caption,
    required this.url,
  });

  factory ContentImage.fromJson(Map<String, dynamic> json) {
    return ContentImage(
      altText: json['altText'] ?? '',
      caption: json['caption'] ?? '',
      url: json['url'] ?? '',
    );
  }
}