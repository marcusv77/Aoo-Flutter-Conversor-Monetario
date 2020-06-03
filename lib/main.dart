import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=006ddc0a";

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light));

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.green,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.green),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChange(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChange(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar) / euro).toStringAsFixed(2);
  }

  void _euroChange(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = ((euro * this.euro) / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "\$ Conversor monetário \$",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados...",
                    style: TextStyle(color: Colors.green, fontSize: 20),
                    textAlign: TextAlign.center),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text("Erro ao carregar os dados!",
                      style: TextStyle(color: Colors.green, fontSize: 20),
                      textAlign: TextAlign.center),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.money_off, size: 140, color: Colors.green),
                      buildTextFiled("Reais", "R\$", realController, _realChange),
                      buildTextFiled("Dolares", "US\$", dolarController, _dolarChange),
                      buildTextFiled("Euros", "€\$", euroController, _euroChange),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextFiled(String label, String prefix, TextEditingController tec, Function func) {
  return Padding(
    padding: EdgeInsets.fromLTRB(0, 14, 0, 0),
    child: TextField(
      controller: tec,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.green),
          border: OutlineInputBorder(),
          prefixText: prefix),
      style: TextStyle(color: Colors.green, fontSize: 18),
      onChanged: func,
      keyboardType: TextInputType.number,
    ),
  );
}
