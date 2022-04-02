import 'package:flutter/material.dart';
import 'package:mixer/user_preferences.dart';
import 'package:mixer/constants.dart';

enum HamburgerAction {
    Logout,
    ViewOtherUser,
}

class Hamburger extends StatelessWidget {

    const Hamburger({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return PopupMenuButton<HamburgerAction>(
            itemBuilder: (BuildContext context) {
                return <PopupMenuItem<HamburgerAction>>[
                    const PopupMenuItem<HamburgerAction>(
                        value: HamburgerAction.Logout,
                        child: Text("Logout"),
                    ),
                    const PopupMenuItem<HamburgerAction>(
                        value: HamburgerAction.ViewOtherUser,
                        child: Text("View Other User"),
                    ),
                ];
            },
            onSelected: (HamburgerAction action) {
                switch (action) {
                    case HamburgerAction.Logout:
                        UserPreferences().removeUser(); 
                        Navigator.pushReplacementNamed(context, Routes.Login);
                        break;
                    case HamburgerAction.ViewOtherUser:
                        Navigator.of(context).pushNamed(Routes.UserSeach);
                        break;
                }
            },
        );
    }
}
