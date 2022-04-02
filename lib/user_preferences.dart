import 'package:mixer/user.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class PrefKeys {
    static const String AccessToken = "access_token";
    static const String RefreshToken = "refresh_token";
    static const String Username = "username";
}

class UserPreferences {
    saveUser(User user) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setString(PrefKeys.AccessToken, user.accessToken);
        await prefs.setString(PrefKeys.RefreshToken, user.refreshToken);
        await prefs.setString(PrefKeys.Username, user.username);
    }

    removeUser() async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove(PrefKeys.AccessToken);
        await prefs.remove(PrefKeys.RefreshToken);
        await prefs.remove(PrefKeys.Username);
    }

    Future<User> getUser() async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String? username = prefs.getString(PrefKeys.Username);
        String? accessToken = prefs.getString(PrefKeys.AccessToken);
        String? refreshToken = prefs.getString(PrefKeys.RefreshToken);

        return User(
            username:  username == null ? "" : username.toString(),
            accessToken: accessToken == null ? "" : accessToken.toString(),
            refreshToken:  refreshToken == null ? "" : refreshToken.toString(),
        );
    }

    Future<String> _getString(String key) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString(key);
        return token.toString();
    }

    Future<String> getAccessToken() async {
        return _getString(PrefKeys.AccessToken);
    }

    Future<String> getRefreshToken() async {
        return _getString(PrefKeys.RefreshToken);
    }

    Future<String> getUsername() async {
        return _getString(PrefKeys.Username);
    }
}
