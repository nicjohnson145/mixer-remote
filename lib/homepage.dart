import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text("Home Flutter Firebase"),
        //actions: <Widget>[LogoutButton()],
      ),
      body: const Center(
        child: Text('Home Page Flutter Firebase  Content'),
      ),
    );
  }
}
