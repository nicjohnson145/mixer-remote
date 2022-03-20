import 'package:mixer_remote/constants.dart';
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

    Map<String, String> authHeaders() {
        return {
            AuthHeaderName: accessToken,
        };
    }

    Future<DrinkList> getDrinksByUser(String username) async {
        final resp = await http.get(
            Uri.parse(Urls.DrinksByUser + "/" + username),
            headers: authHeaders(),
        );

        var respBody = json.decode(resp.body);
        if (resp.statusCode == 200) {
            return DrinkList.fromJson(respBody);
        } else {
            throw Exception(respBody["error"]);
        }
    }

} 
