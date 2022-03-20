import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

class Drink {
    Int64 id;
    String username;
    String name;
    String primaryAlcohol;
    String? preferredGlass;
    List<String> ingredients;
    String? instructions;
    String? notes;
    String publicity;

    Drink({
        required this.id,
        required this.username,
        required this.name,
        required this.primaryAlcohol,
        this.preferredGlass,
        required this.ingredients,
        this.instructions,
        this.notes,
        required this.publicity,
    });

    factory Drink.fromJson(Map<String, dynamic> d) {
        return Drink(
            id: Int64(d["id"]),
            username: d["username"],
            name: d["name"],
            primaryAlcohol:  d["primary_alcohol"],
            preferredGlass:  d["preferred_glass"],
            ingredients: List.from(d["ingredients"]),
            instructions: d["instructions"],
            notes: d["notes"],
            publicity: d["publicity"],
        );
    }
}

class DrinkList {
    final List<DrinkListItem> drinks;

    DrinkList({
        required this.drinks,
    });

    factory DrinkList.fromJson(Map<String, dynamic> d) {
        List<DrinkListItem> l = [];
        for (var i=0; i < d["drinks"].length; i++) {
            l.add(DrinkListItem.fromJson(d["drinks"][i]));
        }
        return DrinkList(
            drinks: l,
        );
    }
}

class DrinkListItem extends StatelessWidget {
    final Drink drink;

    const DrinkListItem({
        Key? key,
        required this.drink,
    }) : super(key: key);

    factory DrinkListItem.fromJson(Map<String, dynamic> d) {
        return DrinkListItem(
            drink: Drink.fromJson(d),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Card(
            child: InkWell(
                onTap: () { print(drink.id); },
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
