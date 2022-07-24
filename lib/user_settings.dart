import 'package:flutter/material.dart';
import 'package:mixer/api_service.dart';
import 'package:mixer/common.dart';
import 'package:mixer/views/hamburger.dart';
import 'package:mixer/constants.dart';
import 'package:mixer/models/settings.dart';
import 'package:tuple/tuple.dart';

class UserSettings extends StatefulWidget {
    const UserSettings({
        Key? key,
    }) : super(key: key);

    @override
    _UserSettingsState createState() => _UserSettingsState();
}


class  _UserSettingsState extends State<UserSettings> {

    Settings? settings;

    @override
    Widget build(BuildContext context) {
        Future<Settings> fSettings = ApiServiceMgr.getInstance().getSettings();

        return FutureBuilder(
            future: fSettings,
            builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                    case ConnectionState.done:
                        if (snapshot.hasError) {
                            return errorScreen("Error: ${snapshot.error}", context);
                        }
                        return UserSettingsView(settings: snapshot.data as Settings);
                    default:
                        if (snapshot.hasError) {
                            return errorScreen("Error: ${snapshot.error}", context);
                        }
                        return loadingSpinner(context);
                }
            }
        );
    }
}


class UserSettingsView extends StatefulWidget {
    Settings settings;
    Future<Tuple2<bool, String>>? future;

    UserSettingsView({
        Key? key,
        required this.settings,
    }) : super(key: key);

    @override
    _UserSettingsViewState createState() => _UserSettingsViewState();
}

class _UserSettingsViewState extends State<UserSettingsView> {

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text("Settings"),
                actions: const <Widget>[
                    Hamburger(),
                ],
            ),
            floatingActionButton: getFloatingActionButton(context),
            body: widget.future == null ? buildSettingsPage(context) : loadingSpinner(context),
        );
    }

    Widget buildSettingsPage(BuildContext context) {
        return Container(
            padding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 15.0,
            ),
            child: SingleChildScrollView(
                child: Column(
                    children: [
                        profileCheckbox(),
                    ],
                ),
            ),
        );
    }

    Widget getFloatingActionButton(BuildContext context) {
        if (widget.future == null) {
            return FloatingActionButton(
                child: const Icon(Icons.save),
                onPressed: () {
                    submitUpdate(context);
                },
            );
        } else {
            return Container();
        }
    }

    Widget profileCheckbox() {
        return Row(
            children: [
                Checkbox(
                    value: widget.settings.publicProfile,
                    onChanged: (bool? value) {
                        setState(() {
                            widget.settings.publicProfile = value!;
                        });
                    },
                ),
                const Text("Public Profile"),
            ],
        );
    }

    void submitUpdate(BuildContext context) {
        setState(() {
            widget.future = ApiServiceMgr.getInstance().updateSettings(widget.settings);
            widget.future!.then((val) {
                Navigator.of(context).pushNamedAndRemoveUntil(Routes.Dashboard, (route) => false);
            }).catchError((e) {
                showErrorSnackbar(context, e);
            });
        });
    }
}
