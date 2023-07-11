import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class TasksState extends ChangeNotifier {
  var currentTasks = [], completedTasks = [];
  void addTask(task) {
    currentTasks.add(task);
    notifyListeners();
  }

  void deleteTask(task) {
    currentTasks.remove(task);
    notifyListeners();
  }

  void taskComplete(task) {
    currentTasks.remove(task);
    completedTasks.add(task);
    notifyListeners();
  }

  void taskFinishEditing(newText, index, controller) {
    currentTasks[index] = newText;
    controller.text = newText;
    notifyListeners();
  }
}

class CurrentTasks extends StatelessWidget {
  CurrentTasks({super.key});
  final addController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<TasksState>();
    var currentTasks = appState.currentTasks;
    return Column(
      children: [
        TextField(
          cursorColor: Colors.red,
          controller: addController,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: "Enter your tasks here",
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
        IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              (addController.text.isEmpty || addController.text.trim().isEmpty)
                  ? null
                  : appState.addTask(
                      addController.text.split(RegExp(r"\s+")).join(" "));
              addController.clear();
            }),
        for (var task in currentTasks)
          SingleTask(
            taskTitle: task,
            taskIndex: currentTasks.indexOf(task),
          ),
      ],
    );
  }
}

class SingleTask extends StatefulWidget {
  const SingleTask({Key? key, required this.taskTitle, required this.taskIndex})
      : super(key: key);
  final String taskTitle;
  final int taskIndex;
  @override
  State<SingleTask> createState() => _SingleTaskState();
}

class _SingleTaskState extends State<SingleTask> {
  bool active = false;
  final editController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<TasksState>();
    return ListTile(
      title: active
          ? TextField(
              controller: editController,
              decoration: const InputDecoration(hintText: "Edit your task"),
            )
          : Text(widget.taskTitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () {
                appState.taskComplete(widget.taskTitle);
              },
              icon: const Icon(Icons.done)),
          IconButton(
            onPressed: () {
              setState(() {
                active = !active;
              });
              (editController.text.isEmpty ||
                      editController.text.trim().isEmpty)
                  ? null
                  : appState.taskFinishEditing(
                      editController.text, widget.taskIndex, editController);
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
              onPressed: () {
                appState.deleteTask(widget.taskTitle);
              },
              icon: const Icon(Icons.delete)),
        ],
      ),
    );
  }
}

class CompletedTasks extends StatelessWidget {
  const CompletedTasks({super.key});
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<TasksState>();
    var completedTasks = appState.completedTasks;
    return Column(
      children: [
        const SizedBox(height: 10),
        completedTasks.isEmpty
            ? const Text("You haven't completed any tasks yet")
            : Text("You've completed ${completedTasks.length} tasks"),
        for (var task in completedTasks) ListTile(title: Text(task))
      ],
    );
  }
}

class ToDo extends StatefulWidget {
  const ToDo({super.key});

  @override
  State<ToDo> createState() => _ToDoState();
}

class _ToDoState extends State<ToDo> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = CurrentTasks();
        break;
      case 1:
        page = const CompletedTasks();
        break;
      default:
        throw UnimplementedError("There's no widget for $selectedIndex");
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
                child: NavigationRail(
              extended: constraints.maxWidth >= 600,
              destinations: [
                NavigationRailDestination(
                    icon: const Icon(Icons.description),
                    selectedIcon:
                        const Icon(Icons.description, color: Colors.red),
                    label: Text("Current tasks",
                        style: TextStyle(
                            color: selectedIndex == 0 ? Colors.red : null))),
                NavigationRailDestination(
                    icon: const Icon(Icons.check_box),
                    label: Text("Completed tasks",
                        style: TextStyle(
                            color: selectedIndex == 1 ? Colors.red : null)),
                    selectedIcon:
                        const Icon(Icons.check_box, color: Colors.red))
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            )),
            Expanded(
                child: Container(
              child: page,
            )),
          ],
        ),
      );
    });

    // return Column(
    //   children: [page],
    // );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TasksState(),
      child: MaterialApp(
        title: 'ToDo',
        theme: ThemeData(),
        home: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.red,
              title: const Center(
                  child: Text(
                "What do you need to get done today?",
                style: TextStyle(
                  color: Colors.white,
                ),
              ))),
          body: const ToDo(),
        ),
      ),
    );
  }
}
