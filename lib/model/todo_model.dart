class TodoModel {
  final String? id;
  final String? title;
  final bool? isCompleted;
  final String? createdAt;

  TodoModel(
      {required this.id,
      required this.title,
      this.isCompleted,
      this.createdAt});

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
        id: json['id'],
        title: json['title'],
        isCompleted: json['isCompleted'],
        createdAt: json['createdAt'],
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
    };
  }
}
