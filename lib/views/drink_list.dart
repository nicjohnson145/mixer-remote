import 'package:flutter/material.dart';
import 'package:mixer_remote/drink.dart';
import 'package:mixer_remote/views/hamburger.dart';

class DrinkListView {
    List<Drink> drinks;
    void Function(Drink) onDrinkTap;

    DrinkListView({
        required this.drinks,
        required this.onDrinkTap,
    });

    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text("Drinks"),
                actions: const <Widget>[
                    Hamburger(),
                ],
            ),
            body: ListView.builder(
                itemCount: drinks.length,
                itemBuilder: (BuildContext context, int i) {
                    return _DrinkLineItem(
                        drink: drinks[i],
                        onTap: onDrinkTap,
                    ).build(context);
                },
            ),
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
