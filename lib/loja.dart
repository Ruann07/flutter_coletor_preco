import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ftpclient/ftpclient.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class Loja extends StatefulWidget {
  @override
  _LojaState createState() => _LojaState();
}

class _LojaState extends State<Loja> {
  String enderecoServidor;
  String userServidor;
  String passServidor;
  String _barcode;
  bool celular = false;
  List _listProdutos = [];
  TextEditingController precoProduto = TextEditingController();
  TextEditingController myController = TextEditingController();
  bool exec = false;
  bool itemEncotrado = false;
  var cFileCsv;
  String cNomeLoja;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  void _addlistProdutos() {
    setState(() {
      if (_formKey.currentState.validate()) {
        Map<String, dynamic> newListProdutos = Map();
        newListProdutos["CodigoBarras"] = myController.text;
        myController.text = "";
        newListProdutos["preco"] = precoProduto.text;
        precoProduto.text = "";
        _listProdutos.add(newListProdutos);
        _saveData(cNomeLoja);
      }
    });
  }

  Widget build(BuildContext context) {
    if (!exec) {
      final Argummentos args = ModalRoute.of(context).settings.arguments;
      cNomeLoja = args.nomeLoja;
      exec = true;
    }
    _readData(cNomeLoja).then((data) {
      setState(() {
        _listProdutos = json.decode(data);
      });
    });
    return Scaffold(
        appBar: AppBar(
          title: Text("Loja " + cNomeLoja),
          backgroundColor: Colors.blue[900],
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.file_upload),
              onPressed: () {
                _importarCsv(cNomeLoja).then((value) async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    enderecoServidor = prefs.getString('ipServidor') ?? "";
                    userServidor = prefs.getString('usuarioServidor') ?? "";
                    passServidor = prefs.getString("senhaServidor") ?? "";
                    
                    FTPClient ftpClient = FTPClient(enderecoServidor, user: userServidor, pass: passServidor);
                    ftpClient.connect();
                    try {
                      ftpClient.uploadFile(File(value));
                    } finally {
                      ftpClient.disconnect();
                    }
                });
              },
            )
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(17.0, 15.0, 7.0, 1.0),
                child: Row(
                  children: <Widget>[
                  Flexible(
                    child: TextFormField(
                      controller: myController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Informe o Codigo de barras";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'Codigo de barras',
                          fillColor: Colors.blueAccent
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  RaisedButton(
                    child: Icon(Icons.camera_alt),
                    color: Colors.white70,
                    onPressed: () {
                      setState(() {
                        scanBarcodeNormal();
                      });
                    },
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),
              Container(
                padding: EdgeInsets.fromLTRB(17.0, 15.0, 7.0, 1.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Informe o Preço";
                          }
                          return null;
                        },
                        controller: precoProduto,
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: "Preço do Produto",
                          prefixText: "R\$ ",
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    RaisedButton(
                        child: Icon(Icons.check_box),
                        color: Colors.white70,
                        onPressed: _addlistProdutos
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 10.0),
                    itemCount: _listProdutos.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.assignment),
                        title: Text("Preço:  " + _listProdutos[index]["preco"]),
                        subtitle: Text("Codigo de Barras:  " +
                            _listProdutos[index]["CodigoBarras"]),
                        trailing: IconButton(
                            icon: Icon(
                                Icons.delete_outline
                            ),
                            onPressed: () {
                              alertDelete(index);
                            }
                        ),
                      );
                    }
                ),
              )
            ],
          ),
        )
    );
  }

  Future<void> alertCodigoBarras() async {
    await showDialog(
        context: context,
        child: AlertDialog(
          title: Text("Esse código de barras ja foi capturado."),
          contentPadding: const EdgeInsets.fromLTRB(12.0, 5.0, 7.0, 1.0),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        )
    );
  }

  Future<dynamic> alertDelete(index) async {
    await showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Deseja deletar esse item ?"),
        contentPadding: const EdgeInsets.fromLTRB(12.0, 5.0, 7.0, 1.0),
        actions: <Widget>[
          FlatButton(
              child: const Text('NÃO'),
              onPressed: () {
                Navigator.pop(context);
              }),
          FlatButton(
              child: const Text('SIM'),
              onPressed: () {
                setState(() {
                  _listProdutos.removeAt(index);
                  _saveData(cNomeLoja);
                });
                Navigator.pop(context);
              }
          )
        ],
      ),
    );
  }

  Future scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (barcodeScanRes == "-1") {
      barcodeScanRes = "";
    }
    if (!mounted) return;

    itemEncotrado = _listProdutos
        .where((map) => map["CodigoBarras"] == barcodeScanRes)
        .isEmpty;
    if (!itemEncotrado) {
      alertCodigoBarras();
    } else {
      setState(() {
        _barcode = barcodeScanRes;
        myController = TextEditingController(text: _barcode);
      });
    }
  }

  Future<File> _getFile(loja) async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/dados_produtos" + loja + ".json");
  }

  Future<File> _saveData(nomeLoja) async {
    String data = json.encode(_listProdutos);
    final file = await _getFile(nomeLoja);
    return file.writeAsString(data);
  }

  Future<String> _readData(nomeLoja) async {
    try {
      final file = await _getFile(nomeLoja);
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<File> _getFileCsv(nomeLoja) async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/produtos" + nomeLoja + ".csv");
  }

  Future<String> _importarCsv(nomeLoja) async {
    String cCodBarras, cPreco;
    int i;
    final fileCsv = await _getFileCsv(nomeLoja);
    for (i = 0; i < _listProdutos.length; i++) {
      cCodBarras = _listProdutos[i]["CodigoBarras"];
      cPreco = _listProdutos[i]["preco"];
      fileCsv.writeAsString(cCodBarras + "," + cPreco + "\n");
    }
    return fileCsv.readAsString();
  }

  usoCelular() {

  }
}
class Argumentoslist {
  final List list;
  Argumentoslist( this.list );
}