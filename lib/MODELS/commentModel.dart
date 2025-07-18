class Comment {
  final String id;
  final String comment;
  final String createdAt;
  final String createdBy;
  final int? year;

  Comment({
    required this.id,
    required this.comment,
    required this.createdAt,
    required this.createdBy,
    required this.year,
  });

  factory Comment.fromJson(Map<String, dynamic> json){
    return Comment(
      id: json['id'] ?? '',
      comment: json['comment'] ?? '',
      createdBy: json['createdBy'] != null && json['createdBy'] is Map ? json['createdBy']['username'] ?? '' : '',
      createdAt: json['createdAt'] ?? '',
      year: json['createdBy'] != null && json['createdBy'] is Map ? json['createdBy']['year'] ?? '' : '',

    );
  }

}