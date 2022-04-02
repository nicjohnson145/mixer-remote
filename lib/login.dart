import 'package:flutter/material.dart';
import 'package:mixer_remote/auth.dart';
import 'package:mixer_remote/user.dart';
import 'package:mixer_remote/constants.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';

class LoginPage extends StatefulWidget {
    @override
    _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    final _formKey = GlobalKey<FormState>();
    String _password = "";
    String _username = "";

    void login(AuthProvider auth, BuildContext context) {
        final form = _formKey.currentState!;
        if (!form.validate()) {
            return;
        }

        form.save();

        final Future<Map<String, dynamic>> successfulMsg = auth.login(_username, _password);

        successfulMsg.then((response) {
            if (response['status']) {
                User user = response['user'];
                Provider.of<UserProvider>(context, listen: false).setUser(user);
                Navigator.pushReplacementNamed(context, Routes.Dashboard);
            } else {
                Flushbar(
                    title: "Failed Login",
                    message: response["message"],
                    duration: const Duration(seconds: 3),
                ).show(context);
            }
        });

    }

    String? Function(String?) required(String key) {
        String? inner(String? val) {
            if (val == null || val.isEmpty) {
                return "$key is required";
            }
            return null;
        }
        return inner;
    }

    @override
    Widget build(BuildContext context) {
        AuthProvider auth = Provider.of<AuthProvider>(context);

        final usernameField = TextFormField(
            onSaved: (val) => _username = val == null ? "" : val.toString(),
            decoration: const InputDecoration(labelText:  "Username"),
            validator: required("Username"),
        );
        final passwordField = TextFormField(
            obscureText: true,
            onSaved: (value) => _password = value == null ? "" : value.toString(),
            decoration: const InputDecoration(labelText: "Password"),
            validator: required("Password"),
        );
        final loginButton = ElevatedButton(
            child: const Text("Login"),
            onPressed: () { login(auth, context); }
        );

        var loading = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                CircularProgressIndicator(),
                const SizedBox(width: 10.0),
                Text("Authenticating"),
            ],
        );

        return SafeArea(
            child: Scaffold(
                body: SingleChildScrollView(
                    child: Container(
                        padding: const EdgeInsets.all(30.0),
                        child: Form(
                            key: _formKey,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    const SizedBox(height: 30.0),
                                    usernameField,
                                    const SizedBox(height: 30.0),
                                    passwordField,
                                    const SizedBox(height: 30.0),
                                    auth.loggedInStatus == Status.Authenticating
                                        ? loading
                                        : loginButton,
                                ],
                            ),
                        ),
                    ),
                ),
            ),
        );
    }
}
