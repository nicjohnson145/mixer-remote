import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mixer_remote/constants.dart';
import 'package:mixer_remote/user_preferences.dart';

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
        appBar: AppBar(title: const Text("Loading")),
        body: const Center(
            child: CircularProgressIndicator(),
        ),
    );
}
