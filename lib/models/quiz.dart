class Quiz {
  final String id;
  final dynamic answer;
  final String explanation;
  final List<dynamic> options;
  final String question;
  final String type;

  Quiz({
    required this.id,
    required this.answer,
    required this.explanation,
    required this.options,
    required this.question,
    required this.type,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] ?? '',
      answer: json['answer'] ?? 0,
      explanation: json['explanation'] ?? '',
      options: json['options'] ?? [],
      question: json['question'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
