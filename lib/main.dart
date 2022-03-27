import 'package:flutter/material.dart';
import 'package:mixer_remote/login.dart';
import 'package:mixer_remote/user.dart';
import 'package:mixer_remote/common.dart';
import 'package:mixer_remote/add_edit.dart';
import 'package:mixer_remote/user_preferences.dart';
import 'package:mixer_remote/api_service.dart';
import 'package:mixer_remote/single_drink.dart';
import 'package:mixer_remote/auth.dart';
import 'package:mixer_remote/constants.dart';
import 'package:mixer_remote/user_drinks.dart';
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
                                    var a = ApiService(accessToken: u.accessToken, refreshToken: u.refreshToken);
                                    a.reauthenticate();
                                    // If we're successful, write the new credentials back to disk
                                    u.accessToken = a.accessToken;
                                    u.refreshToken = a.refreshToken;
                                    UserPreferences().saveUser(u);
                                } catch(e) {
                                    // Something went wrong, back to login page and try again
                                    return returnLogin();
                                }

                                // We've either got valid credentials, or we've successfully
                                // refreshed, to the drinks now.
                                Provider.of<UserProvider>(context).setUser(u);
                                return const UserDrinks();
                            default:
                                return loadingSpinner(context);
                        }
                    },
                ),
                routes: {
                    Routes.Login: (context) => LoginPage(),
                    Routes.Dashboard: (context) => const UserDrinks(),
                    Routes.DrinkDetails: (context) => const SingleDrink(),
                    Routes.AddEdit: (context) => AddEditDrink(),
                },
            ),
        );
    }
}

