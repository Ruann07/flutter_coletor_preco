import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class configuracao extends StatefulWidget {
  @override
  _configuracaoState createState() => _configuracaoState();
}

class _configuracaoState extends State<configuracao> {
  TextEditingController idLocalControler    = TextEditingController();
  TextEditingController senhaLocalControler = TextEditingController();
  TextEditingController idRemotoControler   = TextEditingController();
  TextEditingController ipControler         = TextEditingController();
  bool select = false;
  @override
  void initState() {
    super.initState();
    configuracaoInicial();
  }
  Future<bool> _onBackPresed() {
    return _saveData();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
        backgroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 12.0, right: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Text( "ID do Sistema Local: " ),
                  Expanded(
                    child: TextFormField(
                      controller: idLocalControler,
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Text( "Senha do Sistema Local: " ),
                  Expanded(
                    child: TextFormField(
                      controller: senhaLocalControler,
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Text( "ID do Sistema Remoto: " ),
                  Expanded(
                    child: TextFormField(
                      controller: idRemotoControler,
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Text( "IP do Sistema: " ),
                  Expanded(
                    child: TextFormField(
                      controller: ipControler,
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: CheckboxListTile(
                      title: Text("Ultilização pelo smartphones"),
                      value: select,
                      onChanged: (newValue) {
                        setState(() {
                          select = newValue;
                        });
                      },
                      activeColor: Colors.blue,
                    )
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
      idLocalControler.text = prefs.getString('idLocal') ?? "";
      idRemotoControler.text = prefs.getString('idRemoto') ?? "";
      senhaLocalControler.text = prefs.getString('senhaLocal') ?? "";
      ipControler.text = prefs.getString('ipServidor') ?? "";
      select = prefs.getBool('celular') ?? false;
    });
  }
  _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('idLocal', idLocalControler.text);
    prefs.setString('senhaLocal', senhaLocalControler.text);
    prefs.setString('idRemoto', idRemotoControler.text);
    prefs.setString('ipServidor', ipControler.text);
    prefs.setBool('celular', select);
    Navigator.pop(context);
  }
}
