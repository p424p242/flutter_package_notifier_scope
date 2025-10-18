
import 'package:uuid/uuid.dart';

class Todo {
  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory Todo.create({required String title}) {
    return Todo(
      id: const Uuid().v4(),
      title: title,
    );
  }

  final String id;
  final String title;
  final bool isCompleted;

  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
