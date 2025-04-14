import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:todo_app/model/todo_model.dart';

class TaskViewModel extends ChangeNotifier {
  List<TodoModel> _todo = [];
  bool _isLoading = false;

  List<TodoModel> get task => _todo;
  bool get isLoading => _isLoading;

  setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void fetchTodoList() async {
    FirebaseFirestore.instance
        .collection('todo_list')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      _todo =
          snapshot.docs.map((doc) => TodoModel.fromJson(doc.data())).toList();
      notifyListeners();
    });
  }

  void addTodo(TodoModel task) async {
    setLoading(true);
    final data = task.toJson();
    try {
      await FirebaseFirestore.instance
          .collection('todo_list')
          .doc(task.id)
          .set(data);
    } catch (e) {
      rethrow;
    }
    setLoading(false);
  }

  Future<void> updateTodo({required String id, required TodoModel todo}) async {
    setLoading(true);
    final data = todo.toJson();
    try {
      await FirebaseFirestore.instance
          .collection('todo_list')
          .doc(id)
          .update(data);
    } catch (e) {
      rethrow;
    }
    setLoading(false);
  }

  Future<void> deleteTodo(String id) async {
    setLoading(true);
    try {
      await FirebaseFirestore.instance.collection('todo_list').doc(id).delete();
    } catch (e) {
      rethrow;
    }
    setLoading(false);
  }
}
