import 'package:mixer_remote/constants.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mixer_remote/drink.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
    final String accessToken;
    final String refreshToken;

    ApiService({
        required this.accessToken,
        required this.refreshToken,
    });

    static Map<String, String> basicHeaders() {
        return {
            "Content-type": "application/json",
        };
    }

    Map<String, String> authHeaders() {
        return {
            AuthHeaderName: accessToken,
        };
    }

    Map<String, String> headers() {
        Map<String, String> m = {};
        m.addAll(basicHeaders());
        m.addAll(authHeaders());
        return m;
    }

    Future<List<Drink>> getDrinksByUser(String username) async {
        final resp = await http.get(
            Uri.parse(Urls.DrinksByUser + "/" + username),
            headers: headers(),
        );

        var respBody = json.decode(resp.body);
        if (resp.statusCode == 200) {
            List<Drink> drinks = [];
            for (var i = 0; i < respBody["drinks"].length; i++) {
                drinks.add(Drink.fromJson(respBody["drinks"][i]));
            }
            return drinks;
        } else {
            throw Exception(respBody["error"]);
        }
    }

    Future<bool> tokenCheck() async {
        final resp = await http.get(
            Uri.parse(Urls.apiv1 + "/health"),
            headers: headers(),
        );
        if (resp.statusCode == 200) {
            return true;
        } else {
            return false;
        }
    }

    Future<Drink> getDrinkByID(Int64 id) async {
        final resp = await http.get(
            Uri.parse(Urls.DrinksV1 + "/" + id.toString()),
            headers: headers(),
        );

        var respBody = json.decode(resp.body);
        if (resp.statusCode != 200) {
            throw Exception(respBody["error"]);
        }

        return Drink.fromJson(respBody["drink"]);
    }
}
