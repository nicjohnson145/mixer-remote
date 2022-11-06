import 'package:flutter/material.dart';
import 'package:mixer/api_service.dart';
import 'package:mixer/drink.dart';
import 'package:mixer/constants.dart';
import 'package:mixer/common.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mixer/models/exceptions.dart';

const String Public = "public";
const String Private = "private";

class AddEditDrink extends StatefulWidget {

    Drink? drink;

    AddEditDrink({
        Key? key,
        this.drink,
    }) : super(key: key);

    @override
    _AddEditDrinkState createState() => _AddEditDrinkState();
}

class _AddEditDrinkState extends State<AddEditDrink> {

    TextEditingController nameController = TextEditingController();
    TextEditingController primaryAlcoholController = TextEditingController();
    TextEditingController preferredGlassController = TextEditingController();
    TextEditingController instructionsController = TextEditingController();
    TextEditingController newIngredientController = TextEditingController();
    List<TextEditingController> ingredientsControllers = [];
    TextEditingController notesController = TextEditingController();
    List<String> ingredients = [];
    String? publicity;
    bool underDevelopment = false;
    bool isFavorite = false;

    List<FocusNode> ingredientsFocusNodes = [];
    FocusNode newIngredientFocus = FocusNode();
    Int64? id;
    Future<dynamic>? future;

    @override
    void initState() {
        super.initState();
        if (widget.drink != null) {
            nameController.text = widget.drink!.name;
            primaryAlcoholController.text = widget.drink!.primaryAlcohol;
            if (widget.drink!.preferredGlass != null) {
                preferredGlassController.text = widget.drink!.preferredGlass!;
            }
            if (widget.drink!.instructions != null) {
                instructionsController.text = widget.drink!.instructions!;
            }
            if (widget.drink!.notes != null) {
                notesController.text = widget.drink!.notes!;
            }
            ingredients.addAll(widget.drink!.ingredients);
            for (var i = 0; i < ingredients.length; i++) {
                ingredientsControllers.add(TextEditingController(text: ingredients[i]));
                ingredientsFocusNodes.add(FocusNode());
            }
            id = widget.drink!.id;
            publicity = widget.drink!.publicity;
            underDevelopment = widget.drink!.underDevelopment;
            isFavorite = widget.drink!.isFavorite;
        }
    }

    String get titleText => widget.drink != null ? 'Edit Drink' : 'Create Drink';

    EdgeInsetsGeometry get formRowPadding {
        return const EdgeInsets.only(bottom: 8.0);
    }

    Widget getSimpleField(String label, TextEditingController controller, {int numLines = 1}) {
        return Padding(
            padding: formRowPadding,
            child: TextField(
                controller: controller,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: label,
                ),
                maxLines: numLines,
            ),
        );
    }

    List<Widget> getIngredientsList() {
        List<Widget> list = [];
        list.add(Padding(
            padding: formRowPadding,
            child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'New Ingredient',
                ),
                focusNode: newIngredientFocus,
                controller: newIngredientController,
                onSubmitted: (text)
                {
                    FocusScope.of(context).requestFocus(newIngredientFocus);
                    setState(() {
                        ingredients.add(text);
                        ingredientsControllers.add(TextEditingController(text: text));
                        ingredientsFocusNodes.add(FocusNode());
                        newIngredientController.clear();
                    });
                }
            ),
        ));
        list.add(const Text("Ingredients:"));
        for (var i = 0; i < ingredients.length; i++) {
            list.add(ListTile(
                key: Key(ingredients[i]),
                title: TextField(
                    focusNode: ingredientsFocusNodes[i],
                    controller: ingredientsControllers[i],
                    onChanged: (text)
                    {
                        ingredients[i] = text;
                    }
                ),
                trailing: 
                    IconButton(
                        onPressed: () 
                        {
                            setState(()
                            {
                                ingredients.removeAt(i);
                                ingredientsControllers.removeAt(i).dispose();
                                ingredientsFocusNodes.removeAt(i).dispose();
                            });
                        }, 
                        icon: const Icon(Icons.delete)
                    ),
                ),
            );
        }
        return list;
    }

    Widget booleanCheckbox(Function(bool) setFunc, bool Function() getFunc, String text) {
        return Row(
            children: [
                Checkbox(
                    value: getFunc(),
                    onChanged: (bool? value) {
                        setState(() {
                            setFunc(value!);
                        });
                    },
                ),
                Text(text),
            ],
        );
    }

    Widget getPublicityDropdown() {
        return Row(
            children: <Widget>[
                const Text("Publicity:"),
                const Spacer(),
                DropdownButton<String>(
                    value: publicity ?? Public,
                    icon: const Icon(Icons.arrow_downward),
                    onChanged: (String? newVal) {
                        setState(() {
                            publicity = newVal!;
                        });
                    },
                    items: <String>[Public, Private].map<DropdownMenuItem<String>>((String val) {
                        var text = val[0].toUpperCase() + val.substring(1);
                        return DropdownMenuItem<String>(
                            value: val,
                            child: Text(text),
                        );
                    }).toList(),
                ),
            ],
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(titleText),
                backgroundColor: Colors.black87,
            ),
            body: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 25.0,
                ),
                child: future == null ? buildScrollbar(context) : buildFutureBuilder(context),
            ),
            floatingActionButton: Builder(
                builder: (context) {
                    return FloatingActionButton(
                        onPressed: () { submitDrink(context); },
                        child: const Icon(Icons.check),
                    );
                }
            ),
        );
    }

    Widget buildScrollbar(BuildContext context) {
        List<Widget> components = [
            getSimpleField('Name', nameController),
            getSimpleField('Primary Alcohol', primaryAlcoholController),
            getSimpleField('Preferred Glass', preferredGlassController),
            getSimpleField('Instructions', instructionsController, numLines:2),
            getSimpleField('Notes', notesController, numLines:2),
        ];
        components.addAll(getIngredientsList());
        components.add(getPublicityDropdown());
        components.add(booleanCheckbox((v) { underDevelopment = v; }, () { return underDevelopment; }, "Under Development"));
        components.add(booleanCheckbox((v) { isFavorite = v; }, () { return isFavorite; }, "Favorite"));
        return Scrollbar(
            child: ListView.builder(
                itemCount: components.length,
                itemBuilder: (BuildContext context, int index) {
                    return components[index];
                },
            ),
        );
    }

    Widget buildFutureBuilder(BuildContext context) {
        return loadingSpinner(context);
    }

    void submitDrink(BuildContext context) {
        List<FormCheck> checks = [
            FormCheck(
                () => nameController.text.isNotEmpty,
                'Must have a name',
            ),
            FormCheck(
                () => primaryAlcoholController.text.isNotEmpty,
                'Must have a primary alcohol',
            ),
            FormCheck(
                () => ingredients.isNotEmpty,
                'Must have ingredients',
            ),

        ];

        bool allValid = true;
        for (int i = 0; i < checks.length; i++) {
            FormCheck check = checks[i];
            if (!check.func()) {
                allValid = false;
                showErrorSnackbar(context, check.message);
                break;
            }
        }

        if (allValid) {
            var api = ApiServiceMgr.getInstance();
            DrinkRequest d = DrinkRequest(
                name: nameController.text,
                primaryAlcohol: primaryAlcoholController.text,
                preferredGlass: preferredGlassController.text.isNotEmpty ? preferredGlassController.text : null,
                instructions: instructionsController.text.isNotEmpty ? instructionsController.text : null,
                notes: notesController.text.isNotEmpty ? notesController.text : null,
                ingredients: ingredients,
                publicity: publicity ?? Public,
                underDevelopment: underDevelopment,
                isFavorite: isFavorite,
            );
            setState(() {
                if (widget.drink == null) {
                    future = api.createDrink(d)
                        .then((val) {
                            Navigator.of(context).pushNamedAndRemoveUntil(Routes.Dashboard, (route) => false);
                        }).catchError((e) {
                                showDialog<void>(
                                    context: context,
                                    builder: (context) {
                                        return drinkAlreadyExistsDialog(
                                            context,
                                            d,
                                            (d, params) { 
                                                return api.createDrink(d as DrinkRequest, params);
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
                            Navigator.pop(context);
                        });
                } else {
                    future = api.updateDrink(widget.drink!.id, d)                        
                    .then((val) {
                            Navigator.of(context).pushNamedAndRemoveUntil(Routes.Dashboard, (route) => false);
                    }).catchError((e) {
                            showErrorSnackbar(context, e.toString());
                            Navigator.pop(context);
                    });
                }
            });
        }
    }
}


class FormCheck {
    final Function func;
    final String message;

    FormCheck(this.func, this.message);
}
