import 'package:example/notifiers/todo.notifier.dart';
import 'package:flutter/material.dart';
import 'package:notifier_scope/notifier_scope.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder((context) {
        final todoNotifier = todoNotifierScoped.instance;
        final todos = todoNotifier.state.todos;
        final isLoading = todoNotifier.state.isLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Todo List'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            elevation: 4,
          ),
          body: Container(
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading todos...'),
                      ],
                    ),
                  )
                : todos.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.checklist_rounded,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No todos yet!',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap the + button to add your first todo',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: todos.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: todo.isCompleted,
                                    onChanged: (value) {
                                      todoNotifier.toggleTodoStatus(todo.id);
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      todo.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        decoration: todo.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: todo.isCompleted
                                            ? Colors.grey
                                            : Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    color: Colors.red.shade400,
                                    onPressed: () {
                                      todoNotifier.removeTodo(todo.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _showAddTodoDialog(context, todoNotifier);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Todo'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        );
      },
    );
  }

  void _showAddTodoDialog(BuildContext context, TodoNotifier todoNotifier) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          title: const Text(
            'Add New Todo',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'What needs to be done?',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                autofocus: true,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a description for your new todo item',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                final title = controller.text.trim();
                if (title.isNotEmpty) {
                  todoNotifier.addTodo(title);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Todo'),
            ),
          ],
        );
      },
    );
  }
}
