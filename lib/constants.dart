import 'package:flutter/foundation.dart' as Foundation;

class Urls {
    static const String liveBaseURL = "https://mixer.nicjohnson.info";
    static const String localBaseURL = "http://10.0.2.2:30000";
    static const String base = Foundation.kReleaseMode ? liveBaseURL : localBaseURL;
    static const String apiv1 = base + "/api/v1";

    static const String AuthV1 = apiv1 + "/auth";
    static const String Login = AuthV1 + "/login";
    static const String Refresh = AuthV1 + "/refresh";

    static const String DrinksV1 = apiv1 + "/drinks";
    static const String DrinksByUser = DrinksV1 + "/by-user";
}

class Routes {
    static const String Dashboard = "/dashboard";
    static const String Login = "/login";
    static const String DrinkDetails = "/drink-details";
    static const String AddEdit = "/add-edit";
    static const String UserSeach = "/user-search";
    static const String ChangePassword = "/change-password";
}

const String AuthHeaderName = "MixerAuth";
