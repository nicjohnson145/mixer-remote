import 'package:fixnum/fixnum.dart';

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
