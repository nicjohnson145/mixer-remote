import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mixer_remote/constants.dart';
import 'package:mixer_remote/user.dart';
import 'package:mixer_remote/user_preferences.dart';

enum Status {
    NotLoggedIn,
    LoggedIn,
    Authenticating,
}

class AuthProvider with ChangeNotifier {
    Status _loggedInStatus = Status.NotLoggedIn;
    Status get loggedInStatus => _loggedInStatus;

    Future<Map<String, dynamic>> login(String username, String password) async {
        final Map<String, dynamic> loginData = {
            "username": username,
            "password": password,
        };

        _loggedInStatus = Status.Authenticating;
        notifyListeners();

        http.Response resp = await http.post(
            Uri.parse(Urls.Login),
            body: json.encode(loginData),
        );

        if (resp.statusCode != 200) {
            _loggedInStatus = Status.NotLoggedIn;
            notifyListeners();
            return {
                'status': false,
                'message': json.decode(resp.body)["error"],
            };
        }

        _loggedInStatus = Status.LoggedIn;
        notifyListeners();
        User user = User.fromJson(json.decode(resp.body));
        var up = UserPreferences();
        up.saveUser(user);

        return {
            'status': true,
            'message': 'Successful',
            'user': user,
        };
    }

    static onError(error) {
        print("the error is $error.detail");
        return {
            'status': false,
            'message': 'Unsuccessful Request',
            'data': error,
        };
    }
}

class UserProvider with ChangeNotifier {
    User? _user;

    User? get user => _user;

    void setUser(User user) {
        _user = user;
        notifyListeners();
    }
}
