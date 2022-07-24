import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mixer/api_service.dart';
import 'package:mixer/constants.dart';
import 'package:mixer/user_preferences.dart';
import 'package:mixer/views/hamburger.dart';

import 'drink.dart';

Widget errorScreen(String text, BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text("Error: $text"),
            ElevatedButton(
                child: const Text("Logout"),
                onPressed: () { 
                    UserPreferences().removeUser(); 
                    Navigator.pushReplacementNamed(context, Routes.Login);
                }
            ),
        ]
    );
}

class SingleDrinkArg {
    final Int64 id;

    SingleDrinkArg({
        required this.id,
    });
}

Widget loadingSpinner(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Loading"),
            actions: const <Widget>[
                Hamburger(),
            ],
        ),
        body: const Center(
            child: CircularProgressIndicator(),
        ),
    );
}

/// Pops a three-option dialog asking the user to cancel, overwrite the drink
/// that conflicts with the one they've created, or rename the new drink.
/// The [context] should just be passed through, the [originalRequest] should
/// be the input to the original api service request, the [originalFunc] should
/// be a function closure around the API request. The dialog then adds optional
/// parameters to the [originalRequest] based on the user selection and 
/// re-invokes the [originalFunc] with the new input.
Widget drinkAlreadyExistsDialog(BuildContext context, Object originalRequest, Future<Int64> Function(Object, AdditionalCreateCopyParams) originalFunc) {
    return SimpleDialog(
        title: const Text("A drink with that name already exists. What would you like to do?"),
        children: [
            SimpleDialogItem(
                icon: Icons.cancel,
                text: "Cancel and keep existing drink.",
                onPressed: () { 
                    Navigator.of(context).pushReplacementNamed(Routes.Dashboard);
                },
            ),
            SimpleDialogItem(
                icon: Icons.save,
                text: "Overwrite existing drink.",
                onPressed: () { 
                    originalFunc(originalRequest, AdditionalCreateCopyParams.overWrite())
                        .then((val) {
                                Navigator.of(context).pushReplacementNamed(Routes.Dashboard);
                        }).catchError((e) {
                                showErrorSnackbar(context, e.toString());
                                Navigator.of(context).pushReplacementNamed(Routes.Dashboard);
                        });
                },
            ),
            SimpleDialogItem(
                icon: Icons.edit_note,
                text: "Enter a new name.",
                onPressed: () { 
                    TextEditingController dialogNameController = TextEditingController();
                    String newName = "";
                    showDialog<void>(
                        context: context,
                        builder: (context) {
                            return AlertDialog(
                                title: const Text('Enter new name'),
                                content: TextField(
                                    controller: dialogNameController,
                                    decoration: const InputDecoration(hintText: "New name..."),
                                ),
                                actions: <Widget>[
                                    TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                            newName = dialogNameController.text;
                                            if (originalRequest is DrinkRequest) {
                                                originalRequest.name = newName;
                                            }
                                            originalFunc(originalRequest, AdditionalCreateCopyParams.newName(newName))
                                                .then((val) {
                                                        Navigator.of(context).pushReplacementNamed(Routes.Dashboard);
                                                }).catchError((e) {
                                                        showErrorSnackbar(context, e.toString());
                                                        Navigator.of(context).pushReplacementNamed(Routes.Dashboard);
                                                });
                                        },
                                    ),
                                ],
                            );
                        },
                    );
                },
            )
        ],
    );
}

class SimpleDialogItem extends StatelessWidget {
  const SimpleDialogItem({Key? key, required this.icon, required this.text, required this.onPressed})
      : super(key: key);

  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 36.0),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16.0),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}

void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(message),
        ),
    );
}