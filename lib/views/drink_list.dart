import 'package:flutter/material.dart';
import 'package:mixer/drink.dart';
import 'package:mixer/views/hamburger.dart';
import 'package:mixer/constants.dart';

class DrinkListView {
    List<Drink> drinks;
    void Function(Drink) onDrinkTap;
    String? username;

    DrinkListView({
        required this.drinks,
        required this.onDrinkTap,
        this.username,
    });

    Widget build(BuildContext context) {
        String title;
        if (username == null) {
            title = "Drinks";
        } else {
            title = "${username!}'s Drinks";
        }
        return Scaffold(
            appBar: AppBar(
                title: Text(title),
                actions: const <Widget>[
                    Hamburger(),
                ],
            ),
            body: getBody(context),
            floatingActionButton: getFloatingActionButton(context),
        );
    }

    Widget getBody(BuildContext context) {
        // If you're looking at someone else's drinks
        if (drinks.isEmpty && username != null) {
            return Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 15.0,
                ),
                child: Text("Either $username has no public drinks, or does not exist"),
            );
        }

        var sortedDrinks = List<Drink>.from(drinks);
        sortedDrinks.sort((a, b) => a.name.compareTo(b.name));
        return ListView.builder(
            itemCount: sortedDrinks.length,
            itemBuilder: (BuildContext context, int i) {
                return _DrinkLineItem(
                    drink: sortedDrinks[i],
                    onTap: onDrinkTap,
                ).build(context);
            },
        );
    }

    Widget getFloatingActionButton(BuildContext context) {
        if (username != null) {
            return Container();
        }
        return FloatingActionButton(
            onPressed: () {
                Navigator.of(context).pushNamed(Routes.AddEdit);
            },
            child: const Icon(Icons.add),
        );
    }
}

class _DrinkLineItem {
    final Drink drink;
    final void Function(Drink) onTap;

    const _DrinkLineItem({
        required this.drink,
        required this.onTap,
    });

    Widget build(BuildContext context) {
        return Card(
            child: InkWell(
                onTap: () {
                    onTap(drink);
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 10.0,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                                drink.name,
                                style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Text(
                                drink.primaryAlcohol,
                                style: Theme.of(context).textTheme.subtitle2,
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}
