import 'package:flutter/material.dart';
import 'package:mixer/drink.dart';
import 'package:mixer/views/hamburger.dart';
import 'package:mixer/constants.dart';
import 'package:mixer/views/search_filter.dart';

class DrinkListView extends StatefulWidget{
    final List<Drink> allDrinks;
    final List<Drink> visibleDrinks;
    final void Function(Drink) onDrinkTap;
    final String? username;

    /// Creates a stateful [DrinkListView]. Note that [visibleDrinks] should
    /// be a new list or a DEEP copy of [allDrinks] - passing by reference will
    /// make filters not work.
    DrinkListView({Key? key, 
        required this.allDrinks,
        required this.onDrinkTap,
        this.username,
    }): visibleDrinks = allDrinks.toList(), super(key: key);
    
    @override
    State<DrinkListView> createState() => _DrinkListViewState();
}
    
class _DrinkListViewState extends State <DrinkListView> {

    @override
    Widget build(BuildContext context) {
        String title;
        if (widget.username == null) {
            title = "Drinks";
        } else {
            title = "${widget.username!}'s Drinks";
        }
        return Scaffold(
            appBar: AppBar(
                title: Text(title),
                actions: <Widget>[
                    SearchFilter((filterFunction) {
                        refresh(filterFunction(widget.allDrinks));
                    }),
                    const Hamburger(),
                ],
            ),
            body: getBody(context),
            floatingActionButton: getFloatingActionButton(context),
        );
    }

    Widget getBody(BuildContext context) {
        // If you're looking at someone else's drinks
        if (widget.allDrinks.isEmpty && widget.username != null) {
            return Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 15.0,
                ),
                child: Text("Either $widget.username has no public drinks, or does not exist"),
            );
        }

        var sortedDrinks = List<Drink>.from(widget.visibleDrinks);
        sortedDrinks.sort((a, b) => a.name.compareTo(b.name));
        return ListView.builder(
            itemCount: sortedDrinks.length,
            itemBuilder: (BuildContext context, int i) {
                return _DrinkLineItem(
                    drink: sortedDrinks[i],
                    onTap: widget.onDrinkTap,
                ).build(context);
            },
        );
    }

    Widget getFloatingActionButton(BuildContext context) {
        if (widget.username != null) {
            return Container();
        }
        return FloatingActionButton(
            onPressed: () {
                Navigator.of(context).pushNamed(Routes.AddEdit);
            },
            child: const Icon(Icons.add),
        );
    }

    void refresh(Future<List<Drink>?> visibleDrinks) {
        visibleDrinks.then((value) {
            if (value != null) {
                setState(() {
                    widget.visibleDrinks.clear();
                    widget.visibleDrinks.addAll(value);
                });
            }
        });
    }
}

class _DrinkLineItem {
    final Drink drink;
    final void Function(Drink) onTap;

    const _DrinkLineItem({
        required this.drink,
        required this.onTap,
    });

    Widget nameRow(BuildContext context) {
        List<Widget> children = [
            Text(
                drink.name,
                style: Theme.of(context).textTheme.subtitle1,
            ),
        ];
        if (drink.underDevelopment) {
            children.add(cardIcon(Icons.science_rounded));
        }
        if (drink.isFavorite) {
            children.add(cardIcon(Icons.star));
        }
        return Row(children: children);
    }

    Widget cardIcon(IconData i) {
        return Row(
            children:[
                const SizedBox(width: 15),
                Icon(i, size: 16),
            ],
        );
    }

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
                            nameRow(context),
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
