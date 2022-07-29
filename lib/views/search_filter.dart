import 'package:flutter/material.dart';

import '../common.dart';
import '../drink.dart';

enum SearchFilterOption {
    filterByName,
    filterByPrimaryAlcohol,
    filterByFavorites,
    filterByInDevelopment,
    clear,
}

class SearchFilter extends StatelessWidget {

    final Function(Function(List<Drink> filterFunction)) visibleDrinksSetter;

    const SearchFilter(this.visibleDrinksSetter, {Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return PopupMenuButton<SearchFilterOption>(
            icon: const Icon(Icons.search),
            itemBuilder: (BuildContext context) {
                return <PopupMenuItem<SearchFilterOption>>[
                    const PopupMenuItem<SearchFilterOption>(
                        value: SearchFilterOption.filterByName,
                        child: ListTile(
                            title: Text("Filter by drink name"),
                            leading: Icon(Icons.text_snippet)
                        )
                    ),
                    const PopupMenuItem<SearchFilterOption>(
                        value: SearchFilterOption.filterByPrimaryAlcohol,
                        child: ListTile(
                            title: Text("Filter by primary alcohol"),
                            leading: Icon(Icons.liquor),
                        ),
                    ),
                    const PopupMenuItem<SearchFilterOption>(
                        value: SearchFilterOption.filterByFavorites,
                        child: ListTile(
                            title: Text("Show favorites"),
                            leading: Icon(Icons.star),
                        ),
                    ),
                    const PopupMenuItem<SearchFilterOption>(
                        value: SearchFilterOption.filterByInDevelopment,
                        child: ListTile(
                            title: Text("Show in development"),
                            leading: Icon(Icons.science),
                        ),
                    ),
                    const PopupMenuItem<SearchFilterOption>(
                        value: SearchFilterOption.clear,
                        child: ListTile(
                            title: Text("Clear search/filter"),
                            leading: Icon(Icons.clear_all),
                        ),
                    ),
                ];
            },
            onSelected: (SearchFilterOption action) {
                switch (action) {
                    case SearchFilterOption.filterByName:
                        final List<Drink> matchingDrinks = [];
                        visibleDrinksSetter((final allDrinks) {
                            TextEditingController nameController = TextEditingController();
                            return showDialog<List<Drink>>(
                                context: context,
                                builder: (context) {
                                    return AlertDialog(
                                        title: const Text('Enter name (or substring) to search for'),
                                        content: TextField(
                                            controller: nameController,
                                            decoration: const InputDecoration(hintText: "Name..."),
                                        ),
                                        actions: <Widget>[
                                            TextButton(
                                                child: const Text('Search'),
                                                onPressed: () {
                                                    for (Drink d in allDrinks) {
                                                        if (d.name.toLowerCase().contains(nameController.text.toLowerCase())) {
                                                            matchingDrinks.add(d);
                                                        }
                                                    }
                                                    Navigator.pop(context, matchingDrinks);
                                                },
                                            ),
                                        ],
                                    );
                                },
                            );
                        });
                        break;
                    case SearchFilterOption.filterByPrimaryAlcohol:
                        visibleDrinksSetter((final allDrinks) {
                            final Map<String, List<Drink>> grouped = {};
                            final List<Widget> dialogOptions = [];
                            for (Drink d in allDrinks) {
                                grouped.putIfAbsent(d.primaryAlcohol.toLowerCase(), () => <Drink>[]).add(d);
                            }
                            for (String primaryAlcohol in grouped.keys) {
                                dialogOptions.add(
                                    SimpleDialogItem(
                                        icon: Icons.liquor,
                                        text: primaryAlcohol,
                                        onPressed: () { 
                                            Navigator.pop(context, grouped[primaryAlcohol]);
                                        },
                                    )
                                );
                            }
                            return showDialog<List<Drink>>(
                                context: context,
                                builder: (context) {
                                    return SimpleDialog(
                                        title: const Text('Choose primary alcohol'),
                                        children: dialogOptions,
                                    );
                                },
                            );
                        });
                        break;
                    case SearchFilterOption.filterByFavorites:
                        visibleDrinksSetter((final allDrinks) {
                            final List<Drink> filtered = [];
                            for (Drink drink in allDrinks) {
                                if (drink.isFavorite) {
                                    filtered.add(drink);
                                }
                            }
                            return Future.value(filtered);
                        });
                        break;
                    case SearchFilterOption.filterByInDevelopment:
                        visibleDrinksSetter((final allDrinks) {
                            final List<Drink> filtered = [];
                            for (Drink drink in allDrinks) {
                                if (drink.underDevelopment) {
                                    filtered.add(drink);
                                }
                            }
                            return Future.value(filtered);
                        });
                        break;
                    case SearchFilterOption.clear:
                        visibleDrinksSetter((final allDrinks) {
                            return Future.value(allDrinks);
                        });
                        break;
                }
            },
        );
    }
}
