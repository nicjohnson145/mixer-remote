import 'package:mixer_remote/constants.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mixer_remote/drink.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum HeaderType {
    Refresh,
    Standard,
}

class UnauthorizedError implements Exception {}

class ApiService {
    String accessToken;
    String refreshToken;

    ApiService({
        required this.accessToken,
        required this.refreshToken,
    });

    static Map<String, String> basicHeaders() {
        return {
            "Content-type": "application/json",
        };
    }

    Map<String, String> authHeaders(String token) {
        return {
            AuthHeaderName: token,
        };
    }

    Map<String, String> headers(HeaderType t) {
        Map<String, String> m = {};
        m.addAll(basicHeaders());

        String token;
        if (t == HeaderType.Standard) {
            token = accessToken; } else { token = refreshToken; } m.addAll(authHeaders(token));
        return m;
    }

    void reauthenticate() async {
        final resp = await http.post(
            Uri.parse(Urls.Refresh),
            headers: headers(HeaderType.Refresh)
        );
        if (resp.statusCode == 401) {
            throw UnauthorizedError();
        } else if (resp.statusCode != 200) {
            throw Exception("server error");
        }

        var respBody = json.decode(resp.body);
        accessToken = respBody["access_token"];
        refreshToken = respBody["refresh_token"];
    }

    Future<List<Drink>> getDrinksByUser(String username) async {
        final resp = await http.get(
            Uri.parse(Urls.DrinksByUser + "/" + username),
            headers: headers(HeaderType.Standard),
        );
        if (resp.statusCode == 401) {
            reauthenticate();
            return getDrinksByUser(username);
        }

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
            headers: headers(HeaderType.Standard),
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
            headers: headers(HeaderType.Standard),
        );
        if (resp.statusCode == 401) {
            reauthenticate();
            return getDrinkByID(id);
        }

        var respBody = json.decode(resp.body);
        if (resp.statusCode != 200) {
            throw Exception("oh shit oh fuck");
        }

        return Drink.fromJson(respBody["drink"]);
    }

    Future<Int64> createDrink(DrinkRequest d) async {
        final resp = await http.post(
            Uri.parse(Urls.DrinksV1 + "/" + "create"),
            headers: headers(HeaderType.Standard),
            body: json.encode(d.toJson()),
        );
        if (resp.statusCode == 401) {
            reauthenticate();
            return createDrink(d);
        }

        var respBody = json.decode(resp.body);
        if (resp.statusCode == 200) {
            return Int64(respBody["id"]);
        } else {
            return respBody["error"];
        }
    }
}
