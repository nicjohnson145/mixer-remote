import 'package:flutter/material.dart';
import 'package:mixer/user.dart';
import 'package:mixer/views/drink_details.dart';
import 'package:mixer/common.dart';
import 'package:mixer/auth.dart';
import 'package:mixer/user_drinks.dart';
import 'package:mixer/drink.dart';
import 'package:mixer/api_service.dart';
import 'package:provider/provider.dart';


class SingleDrink extends StatefulWidget {
    const SingleDrink({Key? key}) : super(key: key);

    @override
    _SingleDrinkState createState() => _SingleDrinkState();
}

class _SingleDrinkState extends State<SingleDrink> {

    @override
    Widget build(BuildContext context) {
        User? user = Provider.of<UserProvider>(context).user;

        if (user == null) {
            return Scaffold(
                appBar: AppBar(title: const Text("Unknown user")),
                body: errorScreen("ERROR", context),
            );
        }

        final args = ModalRoute.of(context)!.settings.arguments as SingleDrinkArg;

        Future<Drink> drink = ApiServiceMgr.getInstance().getDrinkByID(args.id);
        return FutureBuilder(
            future: drink,
            builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                    case ConnectionState.done:
                        if (snapshot.hasError) {
                            return UserDrinks();
                        }

                        final d = snapshot.data as Drink;
                        return DrinkDetails(drink: d);
                    default:
                        return loadingSpinner(context);
                }
            },
        );
    }
}

