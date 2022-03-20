class User {
    String username;
    String accessToken;
    String refreshToken;

    User({
        required this.username,
        required this.accessToken,
        required this.refreshToken,
    });

    factory User.fromJson(Map<String, dynamic> respData) {
        return User(
            username: respData["username"],
            accessToken: respData["access_token"],
            refreshToken: respData["refresh_token"],
        );
    }
}
