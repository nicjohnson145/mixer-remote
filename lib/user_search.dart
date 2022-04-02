import 'package:flutter/material.dart';
import 'package:mixer/user_drinks.dart';

class UserSearch extends StatefulWidget {

    const UserSearch({Key? key}) : super(key: key);

    @override
    _UserSearchState createState() => _UserSearchState();

}


class _UserSearchState extends State<UserSearch> {

    TextEditingController nameController = TextEditingController();

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text("User Search"),
            ),
            body: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 15.0,
                ),
                child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Username",
                    ),
                ),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    search(context);
                },
                child: const Icon(Icons.person_search)
            ),
        );
    }

    void search(BuildContext context) {
        if (nameController.text.isEmpty) {
            showErrorSnackbar(context, "Must give a username");
            return;
        }

        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) {
                return UserDrinks(username: nameController.text);
            },
        ));
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
