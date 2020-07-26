import 'package:flutter/material.dart';
import 'package:gpstracker/API_Retrofite/api_master.dart';
import 'package:gpstracker/Model/user_model.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController mobileController = TextEditingController();

  final logger = Logger();

  Future<void> registerUser() async {
    final dio = Dio();   // Provide a dio instance
    dio.options.headers["Demo-Header"] = "demo header";   // config your dio headers globally
    final client = RestClient(dio);

    client.registerUser(User(email: mobileController.text))
        .then((it) =>
        logger.i(it)
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(

            )
          ],
        ),
      ),
    );

  }
}
