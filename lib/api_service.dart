import 'package:mixer/constants.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mixer/drink.dart';
import 'package:mixer/user_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tuple/tuple.dart';

enum HeaderType {
    Refresh,
    Standard,
}

class UnauthorizedError implements Exception {}

class ApiServiceMgr {
    static ApiService? _instance;

    static ApiService getInstance() {
        _instance ??= ApiService();
        return _instance!;
    }
}

class ApiService {

    String? accessToken;
    String? refreshToken;

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

    Future<void> setAuth() async {
        var u = await UserPreferences().getUser();
        accessToken = u.accessToken;
        refreshToken = u.refreshToken;
    }

    Map<String, String> headers(HeaderType t) {
        Map<String, String> m = {};
        m.addAll(basicHeaders());

        String token;
        if (t == HeaderType.Standard) {
            token = accessToken!; 
        } else {
            token = refreshToken!;
        }
        m.addAll(authHeaders(token));
        return m;
    }

    Future<void> reauthenticate() async {
        await setAuth();
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
        var newAccess = respBody["access_token"];
        var newRefresh = respBody["refresh_token"];
        var up = UserPreferences();
        var u = await up.getUser();
        u.accessToken = newAccess;
        u.refreshToken = newRefresh;
        await up.saveUser(u);
    }

    Future<List<Drink>> getDrinksByUser(String username) async {
        await setAuth();
        final resp = await http.get(
            Uri.parse(Urls.DrinksByUser + "/" + username),
            headers: headers(HeaderType.Standard),
        );
        if (resp.statusCode == 401) {
            await reauthenticate();
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

    Future<Drink> getDrinkByID(Int64 id) async {
        await setAuth();
        final resp = await http.get(
            Uri.parse(Urls.DrinksV1 + "/" + id.toString()),
            headers: headers(HeaderType.Standard),
        );
        if (resp.statusCode == 401) {
            await reauthenticate();
            return getDrinkByID(id);
        }

        var respBody = json.decode(resp.body);
        if (resp.statusCode != 200) {
            return Future.error("error getting drink by id: " + id.toString());
        }

        return Drink.fromJson(respBody["drink"]);
    }

    Future<Int64> createDrink(DrinkRequest d) async {
        await setAuth();
        final resp = await http.post(
            Uri.parse(Urls.DrinksV1 + "/" + "create"),
            headers: headers(HeaderType.Standard),
            body: json.encode(d.toJson()),
        );
        if (resp.statusCode == 401) {
            await reauthenticate();
            return createDrink(d);
        }

        var respBody = json.decode(resp.body);
        if (resp.statusCode == 200) {
            return Int64(respBody["id"]);
        } else {
            return respBody["error"];
        }
    }

    Future<void> deleteDrink(Int64 id) async {
        await setAuth();
        final resp = await http.delete(
            Uri.parse(Urls.DrinksV1 + "/" + id.toString()),
            headers: headers(HeaderType.Standard),
        );
        if (resp.statusCode == 401) {
            await reauthenticate();
            return deleteDrink(id);
        }
        if (resp.statusCode != 200) {
            throw Exception("failed to delete drink");
        }
    }

    Future<bool> updateDrink(Int64 id, DrinkRequest d) async {
        await setAuth();
        final resp = await http.put(
            Uri.parse(Urls.DrinksV1 + "/" + id.toString()),
            headers: headers(HeaderType.Standard),
            body: json.encode(d.toJson()),
        );
        if (resp.statusCode == 401) {
            await reauthenticate();
            return updateDrink(id, d);
        }

        var respBody = json.decode(resp.body);
        if (resp.statusCode == 200) {
            return true;
        } else {
            return respBody["error"];
        }
    }

    Future<Tuple2<bool, String>> changePassword(String newPassword) async {
        await setAuth();
        final resp = await http.post(
            Uri.parse(Urls.AuthV1 + "/change-password"),
            headers: headers(HeaderType.Standard),
            body: json.encode({"new_password": newPassword}),
        );
        if (resp.statusCode == 401) {
            await reauthenticate();
            return changePassword(newPassword);
        }

        var respBody = json.decode(resp.body);
        if (resp.statusCode == 200) {
            return const Tuple2(true, "");
        } else {
            return Tuple2(false, respBody["error"]);
        }
    }
}
