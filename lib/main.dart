import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _toDoController = TextEditingController();

  List _toDoList =[];                                          //_todoList vai ser uma lista que vai armazenar as nossas tarefas.

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });

    });
  }

  void _addToDo() {
   setState(() {
     Map<String, dynamic> newToDo = Map();
     newToDo["title"] = _toDoController.text;
     _toDoController.text = "";
     newToDo["ok"] = false;
     _toDoList.add(newToDo);

     _saveData();
   });
  }

  Future<Null> _refresh() async{                                                 //atualizar pagina
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a, b){
        if(a["ok"] && !b["ok"]) return 1;
        else if(!a["ok"] && b["ok"]) return -1;
        else return 0;
      });

      _saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent)
                    ),
                  )
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(onRefresh: _refresh,
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList.length,
                itemBuilder: buildItem),),
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index){
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete,color: Colors.white,),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index] ["title"]),
        value: _toDoList[index] ["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index] ["ok"] ?
          Icons.check : Icons.error),),
        onChanged: (c){
          setState(() {
            _toDoList[index] ["ok"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction){
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(label: "Desfazer",
                onPressed: (){
              setState(() {
                _toDoList.insert(_lastRemovedPos, _lastRemoved);
                _saveData();
              });
                }),
            duration: Duration(seconds: 2),
          );

          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {                                      //obter o arquivo. sempre que precisar do arquivo basta chamar o _getfile que ele vai pegar o arquivo que vou utilizar pra salvar os meus dados.
    final directory = await getApplicationDocumentsDirectory();       //essa fun??ao vai pegar o local onde eu posso armazenar os documentos do meu app, ele esta no diretorio.
    return File("${directory.path}/data.json");                      //pega o caminho .path deste diretorio junto com data.json e abri o arquivo atraves do File.
  }

  Future<File> _saveData() async {                                  //funcao para salvar algum dado no arquivo.
    String data = json.encode(_toDoList);                           //Esta pegando minha lista, tranformando a lista em um json e armazenando numa string.

    final file = await _getFile();                                  //pegando o arquivo que obteve pelo _getfile.
    return file.writeAsString(data);                                //escrever os dados da lista de tarefas como texto dentro do nosso arquivo.
  }

  Future<String> _readData() async {                                     //fun??ao para ler os dados no arquivo.
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

}











