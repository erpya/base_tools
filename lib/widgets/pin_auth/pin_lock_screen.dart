import 'package:flutter/material.dart';
import 'package:pin_lock/pin_lock.dart';
import 'package:base_tools/localization/base_tools_localizations.dart';

/// Specify what your lock screen should look like based on
/// current state. See [LockScreenConfiguration] documentation for a list of all
/// available information
class PinLockScreen extends StatelessWidget {
  final LockScreenConfiguration configuration;

  const PinLockScreen(this.configuration, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    BaseToolsLocalizations? localization = BaseToolsLocalizations.of(context);
    String getError(String? objectError) {
      if (objectError != null) {
        if (objectError.toLowerCase().contains("wrongpin")) {
          return localization!.invalidPin;
        } else if (objectError.toLowerCase().contains("manyattempts")) {
          return localization!.invalidPin;
        } else if (objectError
            .toLowerCase()
            .contains("biometricauthenticationfailed")) {
          return localization!.biometricAuthenticationFailed;
        }
      }
      return objectError ?? "";
    }

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(localization!.fillPinCode),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// [LockScreenConfiguration] provides [pinInputWidget] drawn based on
              /// your instructions given to [AuthenticatorWidget]. You need to make sure that it is
              /// visible on your lock screen, while PinLock package takes care of its state
              configuration.pinInputWidget,

              /// You can check whether biometric authentication is available, and
              /// adjust your UI accordingly
              if (configuration.availableBiometricMethods.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.fingerprint),
                  onPressed: configuration.onBiometricAuthenticationRequested,
                ),
            ],
          ),

          /// [LockScreenConfiguration] provides the [error] property, based on which you can display
          /// an error message to your user based on the specific [LocalAuthFailure]
          if (configuration.error != null)
            Text(
              getError(configuration.error.toString()),
              style: const TextStyle(color: Colors.red),
            )
        ],
      ),
    );
  }
}
