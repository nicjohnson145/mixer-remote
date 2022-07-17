import 'package:flutter/material.dart';
import 'package:mixer/user_drinks.dart';
import 'package:mixer/api_service.dart';
import 'package:mixer/common.dart';

class UserSearch extends StatefulWidget {

    const UserSearch({Key? key}) : super(key: key);

    @override
    _UserSearchState createState() => _UserSearchState();

}


class _UserSearchState extends State<UserSearch> {

    TextEditingController nameController = TextEditingController();

    @override
    Widget build(BuildContext context) {
        Future<List<String>> allUsers = ApiServiceMgr.getInstance().getAllPublicUsers();

        return FutureBuilder(
            future: allUsers,
            builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                    case ConnectionState.done:
                        if (snapshot.hasError) {
                            return errorScreen("Error: ${snapshot.error}", context);
                        }
                        return userList(context, snapshot.data as List<String>);
                    default:
                        if (snapshot.hasError) {
                            return errorScreen("Error: ${snapshot.error}", context);
                        }
                        return loadingSpinner(context);
                }
            }
        );
    }

    Widget userList(BuildContext context, List<String> users) {
        return Scaffold(
            appBar: AppBar(
                title: const Text("All Users"),
            ),
            body: ListView.builder(
                itemCount: users.length,
                itemBuilder: (BuildContext context, int i) {
                    return UserCard(username: users[i]).build(context);
                },
            ),
        );
    }

}

class UserCard {
    String username;

    UserCard({
        required this.username,
    });

    Widget build(BuildContext context) {
        return Card(
            child: InkWell(
                onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) {
                            return UserDrinks(username: username);
                        },
                    ));
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                    ),
                    child: Text(username),
                ),
            ),
        );
    }
}
