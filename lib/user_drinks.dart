import 'package:flutter/material.dart';
import 'package:mixer_remote/user.dart';
import 'package:mixer_remote/auth.dart';
import 'package:mixer_remote/drink.dart';
import 'package:mixer_remote/api_service.dart';
import 'package:mixer_remote/common.dart';
import 'package:mixer_remote/constants.dart';
import 'package:mixer_remote/views/drink_list.dart';
import 'package:provider/provider.dart';

class UserDrinks extends StatefulWidget {
    const UserDrinks({Key? key}) : super(key: key);

    @override
    _UserDrinksState createState() => _UserDrinksState();
}


class  _UserDrinksState extends State<UserDrinks> {

    @override
    Widget build(BuildContext context) {
        User? user = Provider.of<UserProvider>(context).user;

        const title = Text("Drinks");

        if (user == null) {
            return Scaffold(
                appBar: AppBar(title: title),
                body: errorScreen("ERROR", context),
            );
        }

        Future<List<Drink>> drinks = ApiServiceMgr.getInstance().getDrinksByUser(user.username);

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
                        ).build(context);
                    default:
                        return loadingSpinner(context);
                }
            }
        );
    }
}
