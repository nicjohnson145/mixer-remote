import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:mixer/drink.dart';
import 'package:mixer/auth.dart';
import 'package:mixer/models/exceptions.dart';
import 'package:mixer/views/hamburger.dart';
import 'package:provider/provider.dart';
import 'package:mixer/api_service.dart';
import 'package:mixer/add_edit.dart';
import 'package:mixer/common.dart';
import 'package:mixer/constants.dart';

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
    Future<void>? copyFuture;

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
        var widgets = <Widget>[];
        var user = Provider.of<UserProvider>(context).user;
        if (user!.username == widget.drink.username) {
            widgets.add(IconButton(
                        icon: const Icon(Icons.delete_forever),
                        onPressed: () {
                            confirmDelete(context);
                        }
                    ));
        }
        widgets.add(const Hamburger());
        return Scaffold(
            appBar: AppBar(
                title: Text(widget.drink.name),
                actions: widgets
            ),
            body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: deleteFuture == null ? getMainBody() : loadingSpinner(context),
            ),
            floatingActionButton: getFloatingActionButton(context),
        );
    }

    Widget getFloatingActionButton(BuildContext context) {
        var user = Provider.of<UserProvider>(context).user;
        if (user!.username != widget.drink.username) {
            return FloatingActionButton(
                onPressed: () {
                    var api = ApiServiceMgr.getInstance();
                    setState(() {
                        copyFuture = api.copyDrink(widget.drink.id);
                        copyFuture!.then((_) {
                            Navigator.of(context).pushNamedAndRemoveUntil(Routes.Dashboard, (route) => false);
                        }).catchError((e) {
                                showDialog<void>(
                                    context: context,
                                    builder: (context) {
                                        return drinkAlreadyExistsDialog(
                                            context,
                                            widget.drink.id,
                                            (id, params) { 
                                                return api.copyDrink(id as Int64, params);
                                            }
                                        );
                                    },
                                );
                            }, 
                            test:(e) {
                                return e is DrinkAlreadyExistsException;
                            },
                        ).catchError((e) {
                            showErrorSnackbar(context, e.toString());
                        });
                    });
                },
                child: const Icon(Icons.copy),
            );
        } else {
            return FloatingActionButton(
                onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) {
                            return AddEditDrink(drink: widget.drink);
                        },
                    ));
                },
                child: const Icon(Icons.edit),
            );
        }
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

        if (widget.drink.underDevelopment) {
            components.add(boolCheckbox("Under Development"));
        }

        if (widget.drink.isFavorite) {
            components.add(boolCheckbox("Favorite"));
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

    Widget boolCheckbox(String text) {
        return Row(
            children: [
                const Icon(Icons.check_box_rounded, size: 15),
                const SizedBox(width: 5),
                Text(text),
            ],
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
                                }).catchError((e) {
                                    // first pop clears the confirmation dialog
                                    Navigator.pop(context);
                                    // second pop goes back to drinks page
                                    Navigator.pop(context);
                                    showErrorSnackbar(context, e.toString());
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
