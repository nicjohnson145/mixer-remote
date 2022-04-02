import 'package:flutter/material.dart';
import 'package:mixer_remote/drink.dart';
import 'package:mixer_remote/views/hamburger.dart';
import 'package:mixer_remote/api_service.dart';
import 'package:mixer_remote/add_edit.dart';
import 'package:mixer_remote/common.dart';
import 'package:mixer_remote/constants.dart';

class DrinkDetails extends StatefulWidget {
    Drink drink;

    DrinkDetails({
        Key? key,
        required this.drink,
    }) : super(key: key);

    @override
    _DrinkDetailsState createState() => _DrinkDetailsState();

}

class _DrinkDetailsState extends State<DrinkDetails> {

    Future<void>? deleteFuture;

    EdgeInsetsGeometry get verticalPadding {
        return const EdgeInsets.symmetric(vertical: 10.0);
    }

    TextStyle get labelStyle {
        return const TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(widget.drink.name),
                actions: [
                    IconButton(
                        icon: const Icon(Icons.delete_forever),
                        onPressed: () {
                            confirmDelete(context);
                        }
                    ),
                    const Hamburger(),
                ],),
            body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: deleteFuture == null ? getMainBody() : loadingSpinner(context),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) {
                            return AddEditDrink(drink: widget.drink);
                        },
                    ));
                },
                child: const Icon(Icons.edit),
            ),
        );
    }

    Widget getMainBody() {
        List<Widget> components = [
            basicValue("Primary Alcohol", widget.drink.primaryAlcohol),
        ];
        if (widget.drink.preferredGlass != null) {
            components.add(basicValue("Preferred Glass", widget.drink.preferredGlass!));
        }
        if (widget.drink.instructions != null) {
            components.add(basicValue("Instructions", widget.drink.instructions!));
        }
        if (widget.drink.notes != null) {
            components.add(basicValue("Notes", widget.drink.notes!));
        }
        components.add(basicValue("Ingredients", ""));
        components.addAll(getIngredientsList());

        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Scrollbar(
                child: ListView.builder(
                    itemCount: components.length,
                    itemBuilder: (BuildContext context, int index) {
                        return components[index];
                    },
                ),
            ),
        );
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
        for (var i = 0; i < widget.drink.ingredients.length; i++) {
            ingredients.add(_IngredientCard(widget.drink.ingredients[i]));
        }
        return ingredients;
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
                            var api = ApiServiceMgr.getInstance();
                            setState(() {
                                deleteFuture = api.deleteDrink(widget.drink.id);
                                deleteFuture!.then((_) {
                                    Navigator.of(context).pushNamedAndRemoveUntil(Routes.Dashboard, (route) => false);
                                });
                            });
                        },
                    ),
                ],
                elevation: 24.0,
            ),
        );
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
