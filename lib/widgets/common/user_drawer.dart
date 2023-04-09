import 'package:base_tools/sync/sync_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:base_tools/sync/sync_data.dart';
import 'package:base_tools/utils/api.dart';
import 'package:base_tools/utils/login.dart';
import 'package:base_tools/widgets/pin_auth/pin_setup.dart';
import '../../utils/movilecontext.dart';
import 'login.dart';

class UserDrawer extends StatefulWidget {
  final SyncHandler? syncHandler;
  const UserDrawer({Key? key, this.syncHandler}) : super(key: key);

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  String? _userName;
  String? _userMail;
  bool _isLogued = false;
  bool _automaticUpdate = false;
  AppLocalizations? _localization;

  void _refreshData(AppLocalizations? localization) async {
    _isLogued = await LoginUtil.isLoggued();
    String? userMail = await MovileContext.getUserEmail();
    String? userName = await MovileContext.getUserName();
    setState(() {
      _userMail = userMail;
      _userName = userName;
    });
    if (_automaticUpdate) {
      //_movileService.start();
    } else {
      //_movileService.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    _localization = AppLocalizations.of(context);
    _refreshData(_localization);
    final drawerHeader = UserAccountsDrawerHeader(
        accountName: Text(_userName ?? _localization!.navigationDrawerUserName),
        accountEmail:
            Text(_userMail ?? _localization!.navigationDrawerUserName),
        currentAccountPicture:
            const CircleAvatar(backgroundImage: AssetImage("images/logo.jpg")));

    final drawerItems = ListView(
      children: [
        drawerHeader,
        Visibility(
          visible: !_isLogued,
          child: ListTile(
            title: Text(
              _localization!.navigationDrawerLogin,
            ),
            leading: const Icon(Icons.login),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const WLogin()));
            },
          ),
        ),
        Visibility(
          visible: _isLogued,
          child: ListTile(
            title: Text(
              _localization!.navigationDrawerLogout,
            ),
            leading: const Icon(Icons.logout),
            onTap: () {
              MovileApi.logout();
              Navigator.pop(context);
            },
          ),
        ),
        Visibility(
          visible: _isLogued && !_automaticUpdate,
          child: ListTile(
            title: Text(
              _localization!.updateData,
            ),
            leading: const Icon(Icons.sync),
            onTap: () {
              Navigator.pop(context);
              SyncData.downloadData(_localization!, widget.syncHandler, false);
            },
          ),
        ),
        Visibility(
          visible: _isLogued && _automaticUpdate,
          child: ListTile(
            trailing: Checkbox(
              value: _automaticUpdate,
              onChanged: (value) {
                _automaticUpdate = value!;
              },
            ),
            title: Text(
              _localization!.automaticallyUpdate,
            ),
            leading: const Icon(Icons.cloud_sync),
            onTap: () {
              MovileApi.logout();
              Navigator.pop(context);
            },
          ),
        ),
        Visibility(
          visible: true,
          child: ListTile(
            title: Text(
              _localization!.settings,
            ),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WSetupAuthentication()));
            },
          ),
        )
      ],
    );
    return Drawer(
      child: drawerItems,
    );
  }
}
