import 'package:flutter/material.dart';
import 'package:mixer_remote/login.dart';
import 'package:mixer_remote/user.dart';
import 'package:mixer_remote/user_preferences.dart';
import 'package:mixer_remote/auth.dart';
import 'package:mixer_remote/constants.dart';
import 'package:mixer_remote/dashboard.dart';
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
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                            case ConnectionState.active:
                                return const CircularProgressIndicator();
                            default:
                                if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                }

                                final u = snapshot.data as User;
                                if (u.username == "") {
                                    return LoginPage();
                                } else {
                                    Provider.of<UserProvider>(context).setUser(u);
                                    return DashBoard();
                                }
                        }
                    },
                ),
                routes: {
                    Routes.Login: (context) => LoginPage(),
                    Routes.Dashboard: (context) => DashBoard(),
                },
            ),
        );
    }
}

