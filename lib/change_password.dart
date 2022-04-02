import 'package:flutter/material.dart';
import 'package:mixer/user_drinks.dart';
import 'package:mixer/api_service.dart';
import 'package:mixer/constants.dart';
import 'package:mixer/common.dart';
import 'package:tuple/tuple.dart';

class ChangePassword extends StatefulWidget {

    const ChangePassword({Key? key}) : super(key: key);

    @override
    _ChangePasswordState createState() => _ChangePasswordState();

}


class _ChangePasswordState extends State<ChangePassword> {

    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmController = TextEditingController();
    Future<Tuple2<bool, String>>? future;

    @override
    Widget build(BuildContext context) {
        return future == null ? getPasswordColumn(context) : loadingSpinner(context);
    }

    Widget getPasswordColumn(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text("Change Password"),
            ),
            body: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 15.0,
                ),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 15.0,
                    ),
                    child: Column(
                        children: [
                            TextField(
                                controller: passwordController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "New Password",
                                ),
                                obscureText: true,
                            ),
                            const SizedBox(height: 10),
                            TextField(
                                controller: confirmController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Confirm New Password",
                                ),
                                obscureText: true,
                            ),
                        ],
                    ),
                ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    changePassword(context);
                },
                child: const Icon(Icons.edit)
            ),
        );
    }

    void changePassword(BuildContext context) {
        if (passwordController.text.isEmpty) {
            showErrorSnackbar(context, "Must supply a password");
            return;
        }
        if (passwordController.text != confirmController.text) {
            showErrorSnackbar(context, "Passwords do not match");
            return;
        }

        var api = ApiServiceMgr.getInstance();
        setState(() {
            future = api.changePassword(passwordController.text);
            future!.then((val) {
                if (val.item1) {
                    Navigator.of(context).pushNamedAndRemoveUntil(Routes.Dashboard, (route) => false);
                } else {
                    showErrorSnackbar(context, val.item2);
                }
            }).catchError((e) {
                showErrorSnackbar(context, e.toString());
            });
        });
    }

    void showErrorSnackbar(BuildContext context, String message) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text(message),
            ),
        );
    }
}
