part of 'todo_cubit.dart';

@immutable
abstract class TodoState {
  final int id;

  TodoState(this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TodoState && other.id == id;

  @override
  int get hashCode => id;
}

class ExistingTodo extends TodoState {
  final Todo todo;

  ExistingTodo(this.todo) : super(todo.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExistingTodo && other.todo == todo;

  @override
  int get hashCode => todo.hashCode;
}

class MissingTodo extends TodoState {
  MissingTodo(int id) : super(id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MissingTodo && other.id == id;

  @override
  int get hashCode => super.hashCode;
}
