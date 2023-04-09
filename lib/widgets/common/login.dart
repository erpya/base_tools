import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:base_tools/utils/api.dart';
import '../../utils/movilecontext.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WLogin extends StatefulWidget {
  const WLogin({Key? key}) : super(key: key);

  @override
  State<WLogin> createState() => _WLoginState();
}

class _WLoginState extends State<WLogin> {
  Future<String?> _authUser(LoginData data) async {
    String? errorMessage;
    await MovileApi.getAccount().then((account) async {
      await account!
          .createEmailSession(email: data.name, password: data.password)
          .then((session) {
        MovileApi.setSession(session);
      }).catchError((error, stackTrace) {
        errorMessage = error.message;
      });
    }).catchError((error, stackTrace) {
      errorMessage = error.message;
    });
    return errorMessage;
  }

  _setInitValues() async {
    await MovileApi.getSession()
        .then((session) async => await _validateSession(session));
  }

  @override
  void initState() {
    _setInitValues();
    super.initState();
  }

  _validateSession(
    Session? session,
  ) async {
    await MovileApi.getAccount().then((account) async {
      try {
        Account user = await account!.get();
        MovileContext.setUserId(user.$id);
        MovileContext.setUserName(user.name);
        MovileContext.setUserEmail(user.email);
        if (user.$id.isNotEmpty) {
          Navigator.pop(context);
        }
      } catch (exception) {
        print(exception.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localization = AppLocalizations.of(context);
    return FutureBuilder(
        future: MovileContext.getUserEmail(),
        builder: (context, awaitData) {
          if (awaitData.connectionState == ConnectionState.done) {
            String _currentUsermail = "";
            if (awaitData.hasData) _currentUsermail = awaitData.data.toString();
            return FlutterLogin(
              title: localization?.title,
              logo: const AssetImage('images/logo.png'),
              onLogin: _authUser,
              onSubmitAnimationCompleted: () async {
                await MovileApi.getSession()
                    .then((session) => _validateSession(session));
              },
              onRecoverPassword: (_) => Future(() => null),
              savedEmail: _currentUsermail,
              hideForgotPasswordButton: true,
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
