import 'package:flutter/material.dart';
import 'package:mixer_remote/user.dart';
import 'package:mixer_remote/user_preferences.dart';
import 'package:mixer_remote/auth.dart';
import 'package:mixer_remote/constants.dart';
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
