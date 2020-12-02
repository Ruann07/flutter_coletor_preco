import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  Configuralcao createState() => Configuralcao();
}

class Configuralcao extends State<Settings> {
  TextEditingController ipServidor    = TextEditingController();
  TextEditingController usuarioServidor = TextEditingController();
  TextEditingController senhaServidor = TextEditingController();
  bool select = false;
  @override
  void initState() {
    super.initState();
    configuracaoInicial();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
        backgroundColor: Colors.blue[900],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        backgroundColor: Colors.blue[900],
        onPressed: _saveData,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 12.0, right: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Text( "IP do Servidor Ftp: " ),
                  Expanded(
                    child: TextFormField(
                      controller: ipServidor,
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Text( "Nome do usuario: " ),
                  Expanded(
                    child: TextFormField(
                      controller: usuarioServidor,
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Text( "Senha do Servidor: " ),
                  Expanded(
                    child: TextFormField(
                      controller: senhaServidor,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  configuracaoInicial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ipServidor.text = prefs.getString('ipServidor') ?? "";
      usuarioServidor.text = prefs.getString('usuarioServidor') ?? "";
      senhaServidor.text = prefs.getString("senhaServidor") ?? "";
      select = prefs.getBool('celular') ?? false;
    });
  }
  _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ipServidor', ipServidor.text);
    prefs.setString('usuarioServidor', usuarioServidor.text);
    prefs.setString('senhaServidor', senhaServidor.text);
    prefs.setBool('celular', select);
    Navigator.pop(context);
  }
}
