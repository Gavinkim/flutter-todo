import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class Todo {
  bool isDone;
  String title;

  Todo(this.title,{
    this.isDone=false
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '할일관리',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  var _todoController = TextEditingController();
  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('남은 할일'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  // 할일 입력 받는곳
                  child: TextField(
                    controller: _todoController,
                  ),
                ),
                //추가 액션
                RaisedButton(
                  child: Text('추가'),
                  onPressed: () => _addTodo(Todo(_todoController.text)),
                ),
              ],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('todo').snapshots(),
              builder: (context, snapshot) {
                //데이터가 없을 경우 로딩바 표시
                if(!snapshot.hasData){
                  return CircularProgressIndicator();
                }
                final documents = snapshot.data.documents;
                return Expanded(
                  //할일 목록 리스트
                  child: ListView(
                    children: documents
                        .map((doc) => _buildItemWidget(doc)).toList()
                  ),
                );
              }
            )
          ],
        ),
      ),
    );
  }

  //할일 객체 리스트 타이틀 형태로 변경 메서드
  Widget _buildItemWidget(DocumentSnapshot doc) {
    final todo = Todo(doc['title'],isDone: doc['isDone']);
    return ListTile(
      onTap: () => _toggleTodo(doc),
      title: Text(
        todo.title,
        style: todo.isDone
            ? TextStyle(
                decoration: TextDecoration.lineThrough,
                fontStyle: FontStyle.italic,
              )
            : null,
      ),
      //삭제 액션
      trailing: IconButton(
        icon: Icon(Icons.delete_forever),
        onPressed: () => _deleteTodo(doc),
      ),
    );
  }

  void _addTodo(Todo todo) {
    setState(() {
      if(todo.title.isNotEmpty){
        Firestore.instance
            .collection('todo')
            .add({'title': todo.title,'isDone':todo.isDone});
        _todoController.text = '';
      }
    });
  }

  void _deleteTodo(DocumentSnapshot doc) {
    setState(() {
      Firestore.instance.collection('todo')
          .document(doc.documentID).delete();
    });
  }

  //할일 상태 관리
  void _toggleTodo(DocumentSnapshot doc) {
    setState(() {
      Firestore.instance.collection('todo')
          .document(doc.documentID).updateData({'isDone': !doc['isDone']});
    });
  }
}
