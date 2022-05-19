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

  void _addTask() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _newTaskController.text;
      _newTaskController.text = '';
      newToDo["ok"] = false;
      _toDoList.add(newToDo);
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
                    child: Text('ADD'),
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          //LIST VIEW ----------------------------------------------------------
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: _toDoList.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                    title: Text(_toDoList[index]["title"]),
                    value: _toDoList[index]["ok"],
                    secondary: CircleAvatar(
                      child: Icon(
                          _toDoList[index]["ok"] ? Icons.check : Icons.error),
                    ),
                    onChanged: (status) {
                      setState(() {
                        _toDoList[index]["ok"] = status;
                      });
                    });
              },
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
}
