import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
    @override
    _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    final _formKey = GlobalKey<FormState>();
    String _password = "";
    String _username = "";

    void login() {
        final form = _formKey.currentState;
        form?.save();

        if (form != null && form.validate()) {
            print("$_username $_password");
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text("Login"),
            ),
            body: Container(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                    key: _formKey,
                    child: Column(
                        children: <Widget>[
                            const SizedBox(height: 20.0),
                            TextFormField(
                                onSaved: (value) => _username = value.toString(),
                                decoration: const InputDecoration(labelText:  "Username"),
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                                obscureText: true,
                                onSaved: (value) => _password = value.toString(),
                                decoration: const InputDecoration(labelText: "Password"),
                            ),
                            const SizedBox(height: 20.0),
                            ElevatedButton(
                                child: const Text("Login"),
                                onPressed: login,
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}
