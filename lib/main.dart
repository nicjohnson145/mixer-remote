import 'package:flutter/material.dart';
import 'package:mixer/login.dart';
import 'package:mixer/user.dart';
import 'package:mixer/common.dart';
import 'package:mixer/add_edit.dart';
import 'package:mixer/user_preferences.dart';
import 'package:mixer/api_service.dart';
import 'package:mixer/single_drink.dart';
import 'package:mixer/auth.dart';
import 'package:mixer/constants.dart';
import 'package:mixer/user_drinks.dart';
import 'package:mixer/user_search.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        Future<User> getUserData() => UserPreferences().getUser();

        return MultiProvider(
            providers: [
                ChangeNotifierProvider(create: (_) => AuthProvider()),
                ChangeNotifierProvider(create: (_) => UserProvider()),
            ],
            child: MaterialApp(
                title: "Mixer",
                theme: ThemeData(brightness: Brightness.dark),
                home: FutureBuilder(
                    future: getUserData(),
                    builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                            case ConnectionState.done:
                                if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                }

                                var returnLogin = () {
                                    UserPreferences().removeUser();
                                    return LoginPage();
                                };

                                // Try to get the user
                                final u = snapshot.data as User;
                                // If we don't find anything, then straight to login page
                                if (u.username == "") {
                                    return returnLogin();
                                }
                                // We did find something, try to refresh its credentials
                                try{
                                    var a = ApiServiceMgr.getInstance();
                                    a.reauthenticate();
                                } catch(e) {
                                    // Something went wrong, back to login page and try again
                                    return returnLogin();
                                }

                                // We've either got valid credentials, or we've successfully
                                // refreshed, to the drinks now.
                                Provider.of<UserProvider>(context).setUser(u);
                                return UserDrinks();
                            default:
                                return loadingSpinner(context);
                        }
                    },
                ),
                routes: {
                    Routes.Login: (context) => LoginPage(),
                    Routes.Dashboard: (context) => UserDrinks(),
                    Routes.DrinkDetails: (context) => const SingleDrink(),
                    Routes.AddEdit: (context) => AddEditDrink(),
                    Routes.UserSeach: (context) => const UserSearch(),
                },
            ),
        );
    }
}

