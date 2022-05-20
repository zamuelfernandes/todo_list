import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];
  Color baseColor = Colors.blueGrey;

  final TextEditingController _newTaskController = TextEditingController();

  late Map<String, dynamic> _lastRemoved;
  late int _lastRemovedPos;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //Chama o _readData, e depois de um await passa pro then
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  //ADD TASK FUNCTION ----------------------------------------------------------
  void _addTask() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _newTaskController.text;
      _newTaskController.text = '';
      newToDo["ok"] = false;
      _toDoList.add(newToDo);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: baseColor,
        title: const Text('To-Do List'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: [
                //TEXT FIELD ---------------------------------------------------
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: baseColor),
                    ),
                    controller: _newTaskController,
                  ),
                ),
                const SizedBox(width: 10),
                //BUTTON -------------------------------------------------------
                ClipRRect(
                  //borderRadius: BorderRadius.circular(20),
                  child: RaisedButton(
                    onPressed: _addTask,
                    color: baseColor,
                    textColor: Colors.white,
                    child: const Text('ADD'),
                  ),
                ),
              ],
            ),
          ),
          //LIST VIEW ----------------------------------------------------------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: _toDoList.length,
              itemBuilder: buildItem,
            ),
          )
        ],
      ),
    );
  }

  //GET THE FILE ----------------------------------------------------
  //Future<File> _getFile() async {
  Future _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  //SAVE THE FILE ----------------------------------------------------
  Future _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();

    return file.writeAsString(data);
  }

  //READ THE FILE ----------------------------------------------------
  Future _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  //BUILD EACH ITEM ----------------------------------------------------
  Widget buildItem(context, index) {
    return Dismissible(
      //Key para identificação específica de cada item
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
          activeColor: baseColor,
          title: Text(_toDoList[index]["title"]),
          value: _toDoList[index]["ok"],
          secondary: CircleAvatar(
            backgroundColor: baseColor,
            child: Icon(
              _toDoList[index]["ok"] ? Icons.check : Icons.error,
              color: Colors.white,
            ),
          ),
          onChanged: (status) {
            setState(() {
              _toDoList[index]["ok"] = status;
              _saveData();
            });
          }),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text('Task "${_lastRemoved['title']}" removed'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                setState(() {
                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                });
              },
            ),
            duration: const Duration(seconds: 2),
          );

          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }
}
