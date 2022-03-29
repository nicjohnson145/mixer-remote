import 'package:flutter/material.dart';
import 'package:mixer_remote/drink.dart';
import 'package:mixer_remote/views/hamburger.dart';
import 'package:mixer_remote/auth.dart';
import 'package:mixer_remote/api_service.dart';
import 'package:provider/provider.dart';

class DrinkDetails {
    final Drink drink;

    DrinkDetails({
        required this.drink,
    });

    EdgeInsetsGeometry get verticalPadding {
        return const EdgeInsets.symmetric(vertical: 10.0);
    }

    TextStyle get labelStyle {
        return const TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
        );
    }

    Widget build(BuildContext context) {
        var mainBody = getMainBody();
        return Scaffold(
            appBar: AppBar(
                title: Text(drink.name),
                actions: const [
                    DeleteDrinkButton(),
                    Hamburger(),
                ],
            ),
            body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Scrollbar(
                    child: ListView.builder(
                        itemCount: mainBody.length,
                        itemBuilder: (BuildContext context, int index) {
                            return mainBody[index];
                        },
                    ),
                ),
            ),
        );
    }

    List<Widget> getMainBody() {
        List<Widget> components = [
            basicValue("Primary Alcohol", drink.primaryAlcohol),
        ];
        if (drink.preferredGlass != null) {
            components.add(basicValue("Preferred Glass", drink.preferredGlass!));
        }
        if (drink.instructions != null) {
            components.add(basicValue("Instructions", drink.instructions!));
        }
        if (drink.notes != null) {
            components.add(basicValue("Notes", drink.notes!));
        }
        components.add(basicValue("Ingredients", ""));
        components.addAll(getIngredientsList());
        return components;
    }

    Widget basicValue(String label, String value) {
        return Padding(
            padding: verticalPadding,
            child: Text.rich(
                TextSpan(
                    text: "",
                    children: [
                        TextSpan(
                            text: label + ': ',
                            style: labelStyle,
                        ),
                        TextSpan(
                            text: value
                        ),
                    ],
                ),
            ),
        );
    }

    List<Widget> getIngredientsList() {
        List<Widget> ingredients = [];
        for (var i = 0; i < drink.ingredients.length; i++) {
            ingredients.add(_IngredientCard(drink.ingredients[i]));
        }
        return ingredients;
    }
}

class _IngredientCard extends StatelessWidget {
    final String ingredient;

    const _IngredientCard(this.ingredient);

    @override build(BuildContext context) {
        return SizedBox(
            height: 35,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget> [
                    Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(ingredient),
                    ),
                ],
            ),
        );
    }
}

class DeleteDrinkButton extends StatelessWidget {

    const DeleteDrinkButton({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
                confirmDelete(context);
            }
        );
    }

    Future<void> confirmDelete(BuildContext context) async {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
                title: const Text("Confirm"),
                content: const Text("Are you sure you want to delete? This action cannot be undone"),
                actions: <Widget>[
                    TextButton(
                        child: const Text('No'),
                        onPressed: () {
                            Navigator.of(context).pop();
                        },
                    ),
                    TextButton(
                        child: const Text('Yes'),
                        onPressed: () {
                            print("woo");
                            //var u = Provider.of<UserProvider>(context).user!;
                            //var api = ApiService(accessToken: u.accessToken, refreshToken: u.refreshToken);

                            //StoreProvider.of<AppState>(context)
                            //    .dispatch(DeleteDrinkAction(this.drink.uuid));
                            //Navigator.pushAndRemoveUntil(
                            //    context,
                            //    NoopHomeScreen.route(),
                            //    (_) => false,
                            //);
                        },
                    ),
                ],
                elevation: 24.0,
            ),
        );
    }
}
