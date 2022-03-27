class Urls {
    static const String liveBaseURL = "https://mixer.nicjohnson.info";
    static const String localBaseURL = "http://10.0.2.2:30000";
    static const String base = localBaseURL;
    static const String apiv1 = base + "/api/v1";

    static const String Login = apiv1 + "/auth/login";

    static const String DrinksV1 = apiv1 + "/drinks";
    static const String DrinksByUser = DrinksV1 + "/by-user";
}

class Routes {
    static const String Dashboard = "/dashboard";
    static const String Login = "/login";
    static const String DrinkDetails = "/drink-details";
}

const String AuthHeaderName = "MixerAuth";
