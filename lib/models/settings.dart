class Settings {
    bool publicProfile;

    Settings({
        required this.publicProfile,
    });

    factory Settings.fromJson(Map<String, dynamic> d) {
        return Settings(
            publicProfile: d['public_profile'],
        );
    }

    Map<String, dynamic> toJson() {
        var j = {
            "public_profile": publicProfile,
        };
        return {
            "settings": j,
        };
    }
}
