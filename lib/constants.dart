import 'package:flutter/foundation.dart' as Foundation;
import 'dart:io' show Platform;

class Urls {
    static const String liveBaseURL = "https://mixer.nicjohnson.info";
    static final String localBaseURL = Platform.isIOS ? "http://127.0.0.1:30000" : "http://10.0.2.2:30000";
    static final String base = Foundation.kReleaseMode ? liveBaseURL : localBaseURL;
    static final String apiv1 = base + "/api/v1";

    static final String AuthV1 = apiv1 + "/auth";
    static final String Login = AuthV1 + "/login";
    static final String Refresh = AuthV1 + "/refresh";

    static final String DrinksV1 = apiv1 + "/drinks";
    static final String DrinksByUser = DrinksV1 + "/by-user";
    static final String Settings = apiv1 + "/settings";
    static final String PublicUsers = apiv1 + "/users";
}

class Routes {
    static const String Dashboard = "/dashboard";
    static const String Login = "/login";
    static const String DrinkDetails = "/drink-details";
    static const String AddEdit = "/add-edit";
    static const String UserSeach = "/user-search";
    static const String ChangePassword = "/change-password";
    static const String Settings = "/settings";
}

const String AuthHeaderName = "MixerAuth";
