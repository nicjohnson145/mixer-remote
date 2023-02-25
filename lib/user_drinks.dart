import 'package:flutter/material.dart';
import 'package:mixer/user.dart';
import 'package:mixer/auth.dart';
import 'package:mixer/drink.dart';
import 'package:mixer/api_service.dart';
import 'package:mixer/common.dart';
import 'package:mixer/constants.dart';
import 'package:mixer/views/drink_list.dart';
import 'package:provider/provider.dart';

class UserDrinks extends StatefulWidget {
    String? username;

    UserDrinks({
        Key? key,
        this.username,
    }) : super(key: key);

    @override
    _UserDrinksState createState() => _UserDrinksState();
}


class  _UserDrinksState extends State<UserDrinks> {

    @override
    Widget build(BuildContext context) {
        String username;
        if (widget.username == null) {
            User? user = Provider.of<UserProvider>(context).user;

            const title = Text("Drinks");

            if (user == null) {
                return Scaffold(
                    appBar: AppBar(title: title),
                    body: errorScreen("ERROR", context),
                );
            }
            username = user.username;
        } else {
            username = widget.username!;
        }
        Future<List<Drink>> drinks = ApiServiceMgr.getInstance().getDrinksByUser(username);

        return FutureBuilder(
            future: drinks,
            builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                    case ConnectionState.done:
                        if (snapshot.hasError) {
                            return errorScreen("Error: ${snapshot.error}", context);
                        }
                        final dl = snapshot.data as List<Drink>;
                        return DrinkListView(
                            drinks: dl,
                            onDrinkTap: (drink) {
                                Navigator.of(context).pushNamed(
                                    Routes.DrinkDetails,
                                    arguments: SingleDrinkArg(id: drink.id),
                                );
                            },
                            username: widget.username,
                        );
                    default:
                        if (snapshot.hasError) {
                            return errorScreen("Error: ${snapshot.error}", context);
                        }
                        return loadingSpinner(context);
                }
            }
        );
    }
}
