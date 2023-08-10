import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:base_tools/localization/base_tools_localizations.dart';
import 'package:base_tools/utils/movilecontext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:base_tools/utils/api.dart';

class WLogin extends StatefulWidget {
  final Widget? parentWitget;
  const WLogin({Key? key, this.parentWitget}) : super(key: key);

  @override
  State<WLogin> createState() => _WLoginState();
}

class _WLoginState extends State<WLogin> {
  Future<String?> _authUser(LoginData data) async {
    String? errorMessage;
    Account? account = MovileApi.getAccount();
    await account!
        .createEmailSession(email: data.name, password: data.password)
        .then((session) {
      MovileApi.setSession(session);
    }).catchError((error, stackTrace) {
      errorMessage = error.message;
    });
    return errorMessage;
  }

  _setInitValues() async {
    await MovileApi.getSession().then((session) async {
      if (session != null) await _validateSession(session);
    });
  }

  @override
  void initState() {
    super.initState();
    _setInitValues();
  }

  _validateSession(Session? session) async {
    Account? account = MovileApi.getAccount();
    await account!.get().then((user) {
      MovileContext.setUserId(user.$id);
      MovileContext.setUserName(user.name);
      MovileContext.setUserEmail(user.email);
      if (user.$id.isNotEmpty) {
        if (widget.parentWitget == null) {
          Navigator.pop(context);
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => widget.parentWitget!));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    BaseToolsLocalizations? localization = BaseToolsLocalizations.of(context);
    return FutureBuilder(
        future: _setInitValues(),
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
