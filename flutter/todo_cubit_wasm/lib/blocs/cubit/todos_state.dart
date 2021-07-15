part of 'todos_cubit.dart';

@immutable
class TodosState {
  final List<Todo> todos;
  const TodosState(this.todos);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TodosState && other.todos == todos;

  @override
  int get hashCode => todos.hashCode;
}
