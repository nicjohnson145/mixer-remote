import 'package:flutter/material.dart';
import 'package:mixer_remote/login.dart';
import 'package:mixer_remote/homepage.dart';
import 'package:mixer_remote/user.dart';
import 'package:mixer_remote/user_preferences.dart';
import 'package:mixer_remote/auth.dart';
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
                                return const CircularProgressIndicator();
                            default:
                                if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                } else if (snapshot.data.accessToken == null) {
                                    return Login();
                                } else {
                                    UserPreferences().removeUser();
                                }
                                return Welcome(user: snapshot.data);
                        }
                    },
                ),
                routes: {

                },
            ),
        );
    }
}

