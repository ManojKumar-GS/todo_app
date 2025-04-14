import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todo_app/model/todo_model.dart';
import 'package:todo_app/utils/utils.dart';
import 'package:todo_app/viewmodel/todo_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController titleEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isDone = false;

  @override
  void initState() {
    Provider.of<TaskViewModel>(context, listen: false).fetchTodoList();
    super.initState();
  }

  @override
  void dispose() {
    titleEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TaskViewModel>(context);

    return SafeArea(
        maintainBottomViewPadding: true,
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: MediaQuery.sizeOf(context).height * 0.1,
              title: const Padding(
                padding: EdgeInsets.only(top: 18, bottom: 20),
                child: ListTile(
                  title: Text("Welcome Back!"),
                  subtitle: Text("UserName",
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  leading: CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person),
                  ),
                ),
              ),
              bottom: const TabBar(
                  padding: EdgeInsets.all(0),
                  indicatorColor: Colors.blue,
                  tabAlignment: TabAlignment.fill,
                  automaticIndicatorColorAdjustment: true,
                  tabs: [
                    Tab(icon: Icon(Icons.checklist), text: "ALL"),
                    Tab(icon: Icon(Icons.pending_actions), text: "PENDING"),
                    Tab(icon: Icon(Icons.done_all), text: "DONE")
                  ]),
            ),
            body: TabBarView(
              children: [
                getTabView(todoProvider, false, false),
                getTabView(todoProvider, true, false),
                getTabView(todoProvider, false, true),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () =>
                  getShowDialogue(todoProvider, isUpdating: false, todoId: 0),
              child: const Icon(CupertinoIcons.add),
            ),
          ),
        ));
  }

  getTabView(TaskViewModel todoProvider, bool isPendingTab, bool isDoneTab) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: todoProvider.task.length,
              itemBuilder: (context, index) {
                if (isPendingTab || isDoneTab) {
                  if (isPendingTab &&
                      (todoProvider.task[index].isCompleted ?? false)) {
                    return const SizedBox.shrink();
                  }
                  if (!(todoProvider.task[index].isCompleted ?? false) &&
                      isDoneTab) {
                    return const SizedBox.shrink();
                  }
                }
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Utils().getRandomNonBlackColor(),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      height: 170,
                      width: MediaQuery.sizeOf(context).width,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('# ${todoProvider.task[index].id ?? ""}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                        color: Colors.black)),
                                Badge(
                                  backgroundColor:
                                      (todoProvider.task[index].isCompleted ??
                                              false)
                                          ? Colors.red
                                          : Colors.green,
                                  largeSize: 30,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  label: Text(
                                      (todoProvider.task[index].isCompleted ??
                                              false)
                                          ? "Done"
                                          : "Pending"),
                                )
                              ],
                            ),
                            Text(todoProvider.task[index].title ?? "",
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 25)),
                            Text(
                                'Created at: ${todoProvider.task[index].createdAt?.substring(0, 16) ?? ""}',
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    color: Colors.black,
                                    fontSize: 15)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Utils().getActionButton(
                                    icon: Icons.delete,
                                    onTap: () async {
                                      try {
                                        await todoProvider.deleteTodo(
                                            todoProvider.task[index].id
                                                .toString());
                                      } catch (e) {
                                        if (mounted) {
                                          getSnackBar('Something went wrong!');
                                        }
                                      }
                                    }),
                                Utils().getActionButton(
                                    icon: Icons.share,
                                    onTap: () async => await shareTodo(
                                        id: todoProvider.task[index].id
                                            .toString(),
                                        title: todoProvider.task[index].title ??
                                            "")),
                                Utils().getActionButton(
                                    icon: Icons.edit,
                                    onTap: () => getShowDialogue(todoProvider,
                                        isUpdating: true, todoId: index)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5)
                  ],
                );
              },
            )),
          ],
        ));
  }

  getSnackBar(String text) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.all(MediaQuery.sizeOf(context).height * 0.01),
      behavior: SnackBarBehavior.floating,
    ));
  }

  getShowDialogue(TaskViewModel todoProvider,
      {bool isUpdating = false, required int todoId}) {
    if (isUpdating) {
      isDone = todoProvider.task[todoId].isCompleted ?? false;
      titleEditingController.text = todoProvider.task[todoId].title ?? "";
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUpdating ? "Edit Todo" : "Add Todo"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                enabled: false,
                initialValue:
                    'TODO: ${isUpdating ? todoProvider.task[todoId].id : (todoProvider.task.length + 1)}',
              ),
              const SizedBox(height: 10),
              TextFormField(
                validator: (value) {
                  if (value?.isEmpty ?? false) {
                    getSnackBar('Please add title');
                    return 'Please enter title';
                  }
                  return null;
                },
                controller: titleEditingController,
                decoration: InputDecoration(
                  hintText: 'TITLE',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (isUpdating)
                StatefulBuilder(
                  builder: (context, setState) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ChoiceChip(
                        label: const Text("Pending"),
                        selected: !isDone,
                        onSelected: (value) {
                          setState(() {
                            isDone = false;
                          });
                        },
                        selectedColor: Colors.green,
                      ),
                      ChoiceChip(
                          label: const Text("Done"),
                          onSelected: (value) {
                            setState(() {
                              isDone = true;
                            });
                          },
                          selected: isDone,
                          selectedColor: Colors.red)
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("cancel")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        !todoProvider.isLoading) {
                      addOrUpdateTodo(todoProvider,
                          todoId: todoId, isUpdating: isUpdating);
                    }
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  addOrUpdateTodo(TaskViewModel todoProvider,
      {bool isUpdating = false, required int todoId}) async {
    TodoModel todoModel = TodoModel(
        id: isUpdating
            ? todoProvider.task[todoId].id.toString()
            : (todoProvider.task.length + 1).toString(),
        title: titleEditingController.value.text,
        createdAt: isUpdating
            ? todoProvider.task[todoId].createdAt
            : DateTime.now().toString(),
        isCompleted: isUpdating ? isDone : false);

    try {
      isUpdating
          ? await todoProvider.updateTodo(
              id: todoProvider.task[todoId].id.toString(), todo: todoModel)
          : todoProvider.addTodo(todoModel);

      if (mounted) {
        getSnackBar(isUpdating
            ? 'Todo updated successfully'
            : 'Todo added successfully');
      }

      titleEditingController.clear();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        getSnackBar('Something went wrong!');
        Navigator.pop(context);
      }
    }
  }

  shareTodo({required String id, required String title}) async {
    try {
      await Share.share('Todo Id: $id \nTodo: $title');
    } catch (e) {
      return getSnackBar("Something went wrong!");
    }
  }
}
