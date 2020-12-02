import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'loja.dart';
import 'configuracao.dart';

enum Configuracao {conf}
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    title: "Coletor Preco",
    theme: ThemeData(
      primaryColor: Colors.blue[900]
    ),
    routes: {
      '/': (context) => MyApp(),
      '/second': (context) => Loja(),
      '/configuracao': (context) => Settings(),
    },
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  List _listEmpresas = [];
  TextEditingController _newEmpresa = TextEditingController();
  var posicao, empresa;
  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _listEmpresas = json.decode(data);
      });
    });
  }

  void _addEmpresas() {
    setState(() {
      if (_form.currentState.validate()){
        _listEmpresas.add(_newEmpresa.text);
        _newEmpresa.text = "";
        _saveData();
        Navigator.pop(context);
      }
    });
  }

  _navigateDisplaySnack() async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Settings()),
      );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text("Coletor Preco"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white,),
            onPressed: () {
              setState(() {
                _navigateDisplaySnack();
              });
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _listEmpresas.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Column(
              children: [
                Dismissible(
                  key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                  onDismissed: (direction) {
                    setState(() {
                      posicao = index;
                      empresa = _listEmpresas[index];
                      _listEmpresas.removeAt(index);
                      _saveData();
                      final snack = SnackBar( // criacao do snack bar
                        content: Text( " $empresa foi removido" ),
                        action: SnackBarAction(
                          label: "Desfazer",
                          onPressed: () {
                            setState(() {
                              _listEmpresas.insert(posicao, empresa);
                              _saveData();
                            });
                          },
                        ),
                        duration: Duration(seconds: 2),
                      );
                      Scaffold.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(snack); // mostrar snack bar
                    });
                  },
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    color: Colors.redAccent,
                    child: Align(
                      alignment: Alignment(-0.9, 0.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text (
                      _listEmpresas[index],
                      textAlign: TextAlign.center,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                          context,
                          '/second',
                          arguments: Argummentos(_listEmpresas[index])
                      );
                    },
                  ),
                ),
              ],
            ),
            color: Colors.white70,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[800],
        child: Icon(Icons.add),
        onPressed: () {
          setState(() {
            _showDialog();
          });
        },
      ),
    );
  }

  _showDialog() async {
    await showDialog(
      context: context,
      child: Row(
        children: <Widget>[
          Form(
            key: _form,
            child: Expanded(
              child: AlertDialog(
                title: Text("Criar nova empresa"),
                contentPadding: EdgeInsets.fromLTRB(17.0, 5.0, 7.0, 1.0),
                content: TextFormField(
                  controller: _newEmpresa,
                  validator: (value) {
                    if (value.isEmpty){
                      return "Informe o nome da empresa";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: "Nome da Empresa"
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                      child: Text('Cancelar', style: TextStyle( color: Colors.blue[800] ),),
                      onPressed: () {
                        _newEmpresa.text = "";
                        Navigator.pop(context);
                      }),
                  FlatButton(
                      child: Text('Salvar',style: TextStyle( color: Colors.blue[800] ), ),
                      onPressed: _addEmpresas
                  )
                ],
              ),
            ),
          ),
        ],
      )
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/dados.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_listEmpresas);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}

class Argummentos {
  final String nomeLoja;
  Argummentos( this.nomeLoja );
}