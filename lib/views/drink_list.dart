import 'package:flutter/material.dart';
import 'package:mixer/drink.dart';
import 'package:mixer/views/hamburger.dart';
import 'package:mixer/constants.dart';
import 'package:mixer/views/search_filter.dart';

class DrinkListView extends StatefulWidget {
    final List<Drink> drinks;
    final void Function(Drink) onDrinkTap;
    final String? username;
    final SearchFilter searchFilterWidget;
    final Map<SearchFilterOption, bool Function(Drink)> filterFunctions = {};

    DrinkListView({Key? key, 
        required this.drinks,
        required this.onDrinkTap,
        this.username,
    }): searchFilterWidget = SearchFilter(allDrinks: drinks), super(key: key);

    @override
    State<DrinkListView> createState() => _DrinkListViewState();
}

class _DrinkListViewState extends State<DrinkListView> {

    @override
    Widget build(BuildContext context) {
        widget.searchFilterWidget.updateFilterFunc = (searchFilterOption, newFilter) => {
            setState(() {
                if (searchFilterOption == SearchFilterOption.clear) {
                    widget.filterFunctions.clear();
                } else {
                    widget.filterFunctions[searchFilterOption] = newFilter;
                }
            })
        };
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
                    widget.searchFilterWidget,
                    const Hamburger(),
                ],
            ),
            body: getBody(context),
            floatingActionButton: getFloatingActionButton(context),
        );
    }

    Widget getBody(BuildContext context) {
        // If you're looking at someone else's drinks
        if (widget.drinks.isEmpty && widget.username != null) {
            return Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 15.0,
                ),
                child: Text("Either ${widget.username} has no public drinks, or does not exist"),
            );
        }

        var sortedAndFilteredDrinks = List<Drink>.from(widget.drinks);
        sortedAndFilteredDrinks.sort((a, b) => a.name.compareTo(b.name));
        if (widget.filterFunctions.isNotEmpty) {
            sortedAndFilteredDrinks.retainWhere(widget.filterFunctions.values.reduce((value, element) => (drink) {
                return value(drink) && element(drink);
            }));
        }
        return ListView.builder(
            itemCount: sortedAndFilteredDrinks.length,
            itemBuilder: (BuildContext context, int i) {
                return _DrinkLineItem(
                    drink: sortedAndFilteredDrinks[i],
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
