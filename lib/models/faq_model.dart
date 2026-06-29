class FaqModel {
  final int id;
  final String question;
  final String answer;
  final String category;
  final String keywords;
  final int upvotes;
  final String createdAt;

  FaqModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.keywords,
    required this.upvotes,
    required this.createdAt,
  });

  factory FaqModel.fromMap(Map<String, dynamic> map) {
    return FaqModel(
      id: map['id'] as int,
      question: map['question'] as String,
      answer: map['answer'] as String,
      category: map['category'] as String,
      keywords: map['keywords'] as String,
      upvotes: map['upvotes'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'keywords': keywords,
      'upvotes': upvotes,
      'created_at': createdAt,
    };
  }
}