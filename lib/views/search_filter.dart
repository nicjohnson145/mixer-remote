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

class SearchFilter extends StatefulWidget {
    final List<Drink> allDrinks;
    final List<SearchFilterOption> appliedFilters = [];
    Function(SearchFilterOption, bool Function(Drink))? updateFilterFunc;

    SearchFilter({
        Key? key,
        required this.allDrinks,
    }): super(key: key);

    @override
    _SearchFilterState createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {

    @override
    Widget build(BuildContext context) {
        return PopupMenuButton<SearchFilterOption>(
            icon: const Icon(Icons.search),
            itemBuilder: (BuildContext context) {
                return <PopupMenuItem<SearchFilterOption>>[
                    PopupMenuItem<SearchFilterOption>(
                        value: SearchFilterOption.filterByName,
                        child: ListTile(
                            title: const Text("Filter by drink name"),
                            leading: const Icon(Icons.text_snippet),
                            trailing: widget.appliedFilters.contains(SearchFilterOption.filterByName) ? const Icon(Icons.check) : null,
                        )
                    ),
                    PopupMenuItem<SearchFilterOption>(
                        value: SearchFilterOption.filterByPrimaryAlcohol,
                        child: ListTile(
                            title: const Text("Filter by primary alcohol"),
                            leading: const Icon(Icons.liquor),
                            trailing: widget.appliedFilters.contains(SearchFilterOption.filterByPrimaryAlcohol) ? const Icon(Icons.check) : null,
                        ),
                    ),
                    PopupMenuItem<SearchFilterOption>(
                        value: SearchFilterOption.filterByFavorites,
                        child: ListTile(
                            title: const Text("Show favorites"),
                            leading: const Icon(Icons.star),
                            trailing: widget.appliedFilters.contains(SearchFilterOption.filterByFavorites) ? const Icon(Icons.check) : null,
                        ),
                    ),
                    PopupMenuItem<SearchFilterOption>(
                        value: SearchFilterOption.filterByInDevelopment,
                        child: ListTile(
                            title: const Text("Show in development"),
                            leading: const Icon(Icons.science),
                            trailing: widget.appliedFilters.contains(SearchFilterOption.filterByInDevelopment) ? const Icon(Icons.check) : null,
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
                        TextEditingController nameController = TextEditingController();
                        showDialog(
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
                                                if (widget.updateFilterFunc != null) {
                                                    widget.updateFilterFunc!(SearchFilterOption.filterByName, (drink) {
                                                        return drink.name.toLowerCase().contains(nameController.text.toLowerCase());
                                                    });
                                                }
                                                setState(() {
                                                    widget.appliedFilters.add(SearchFilterOption.filterByName);
                                                });
                                                Navigator.pop(context);
                                            },
                                        ),
                                    ],
                                );
                            },
                        );
                        break;
                    case SearchFilterOption.filterByPrimaryAlcohol:
                        final Set<String> primaryAlcohols = {};
                        for (Drink d in widget.allDrinks) {     
                            primaryAlcohols.add(d.primaryAlcohol.toLowerCase());
                        }
                        final List<Widget> dialogOptions = [];
                        for (String primaryAlcohol in primaryAlcohols) {
                            dialogOptions.add(
                                SimpleDialogItem(
                                    icon: Icons.liquor,
                                    text: primaryAlcohol,
                                    onPressed: () { 
                                        if (widget.updateFilterFunc != null) {
                                            widget.updateFilterFunc!(SearchFilterOption.filterByPrimaryAlcohol, (drink) {
                                                return drink.primaryAlcohol.toLowerCase() == primaryAlcohol;
                                            });
                                        }
                                        setState(() {
                                            widget.appliedFilters.add(SearchFilterOption.filterByPrimaryAlcohol);
                                        });   
                                        Navigator.pop(context);                              
                                    },
                                )
                            );
                        }
                        showDialog<List<Drink>>(
                            context: context,
                            builder: (context) {
                                return SimpleDialog(
                                    title: const Text('Choose primary alcohol'),
                                    children: dialogOptions,
                                );
                            },
                        );
                        break;
                    case SearchFilterOption.filterByFavorites:
                        if (widget.updateFilterFunc != null) {
                            widget.updateFilterFunc!(SearchFilterOption.filterByFavorites, (drink) {
                                return drink.isFavorite;
                            });
                        }
                        setState(() {
                            widget.appliedFilters.add(SearchFilterOption.filterByFavorites);
                        });
                        break;
                    case SearchFilterOption.filterByInDevelopment:
                        if (widget.updateFilterFunc != null) {
                            widget.updateFilterFunc!(SearchFilterOption.filterByInDevelopment, (drink) {
                                return drink.underDevelopment;
                            });
                        }
                        setState(() {
                            widget.appliedFilters.add(SearchFilterOption.filterByInDevelopment);
                        });
                        break;
                    case SearchFilterOption.clear:
                        if (widget.updateFilterFunc != null) {
                            widget.updateFilterFunc!(SearchFilterOption.clear, (drink) {return true;});
                        }
                        setState(() {
                            widget.appliedFilters.clear();
                        });
                        break;
                }
            },
        );
    }
}