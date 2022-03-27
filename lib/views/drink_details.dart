import 'package:flutter/material.dart';
import 'package:mixer_remote/drink.dart';
import 'package:mixer_remote/views/hamburger.dart';

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
                    Hamburger(),
                ],
            ),
            body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Expanded(
                    child: Scrollbar(
                        child: ListView.builder(
                            itemCount: mainBody.length,
                            itemBuilder: (BuildContext context, int index) {
                                return mainBody[index];
                            },
                        ),
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
