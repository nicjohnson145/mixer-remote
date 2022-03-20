import 'package:flutter/material.dart';
import 'package:mixer_remote/user.dart';
import 'package:mixer_remote/user_preferences.dart';
import 'package:mixer_remote/auth.dart';
import 'package:mixer_remote/constants.dart';
import 'package:mixer_remote/drink.dart';
import 'package:mixer_remote/api_service.dart';
import 'package:provider/provider.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {

    User? user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text("DASHBOARD PAGE"),
        elevation: 0.1,
      ),
      body: Column(
        children: [
          SizedBox(height: 100,),
          Center(child: Text(user == null ? "ERROR" : user.username)),
          SizedBox(height: 100),
          ElevatedButton(
              child: Text("Logout"),
              onPressed: () {
                UserPreferences().removeUser();
                Navigator.pushReplacementNamed(context, Routes.Login);
              },
          ),
        ],
      ),
    );
  }
}


class UserDrinks extends StatefulWidget {
    const UserDrinks({Key? key}) : super(key: key);

    @override
    _UserDrinksState createState() => _UserDrinksState();
}


class  _UserDrinksState extends State<UserDrinks> {

    Widget errorScreen(String text) {
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

    @override
    Widget build(BuildContext context) {
        User? user = Provider.of<UserProvider>(context).user;

        const title = Text("Drinks");

        if (user == null) {
            return Scaffold(
                appBar: AppBar(title: title),
                body: errorScreen("ERROR"),
            );
        }

        Future<DrinkList> drinks = ApiService(accessToken: user.accessToken, refreshToken:  user.refreshToken).getDrinksByUser(user.username);

        return Scaffold(
            appBar: AppBar(title: title),
            body: FutureBuilder(
                future: drinks,
                builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                            return const CircularProgressIndicator();
                        default:
                            if (snapshot.hasError) {
                                return errorScreen("Error: ${snapshot.error}");
                            }

                            final dl = snapshot.data as DrinkList;
                            return ListView.builder(
                                itemCount: dl.drinks.length,
                                itemBuilder: (BuildContext context, int i) {
                                    return dl.drinks[i];
                                },
                            );
                    }
                },
            ),
        );
    }
}
