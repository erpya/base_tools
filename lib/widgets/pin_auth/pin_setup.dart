import 'package:flutter/material.dart';
import 'package:base_tools/utils/utils.dart';
import 'package:base_tools/widgets/pin_auth/pin_input.dart';
import 'package:pin_lock/pin_lock.dart';
import 'package:base_tools/localization/base_tools_localizations.dart';

class WSetupAuthentication extends StatelessWidget {
  const WSetupAuthentication({super.key});

  @override
  Widget build(BuildContext context) {
    late final Authenticator globalAuthenticator;
    BaseToolsLocalizations? localization = BaseToolsLocalizations.of(context);
    return FutureBuilder(
        future: Utils.getPinAuthenticator(),
        builder: (context, awaitData) {
          if (awaitData.connectionState == ConnectionState.done) {
            if (awaitData.hasData) {
              globalAuthenticator = awaitData.data as Authenticator;
            }
            return Scaffold(
              appBar: AppBar(title: Text(localization!.settings)),

              /// Put [AuthenticationSetupWidget] in your settings screen, or wherever you want
              /// your user expects to be able to change pin preferences
              body: AuthenticationSetupWidget(
                /// Pass in a reference to an [Authenticator] singleton
                authenticator: globalAuthenticator,

                /// Pin input widget can be the same as on the lock screen, or you can provide a custom UI
                /// that you want to use when setting it up
                pinInputBuilder: (index, state) =>
                    PinInputField(state: state, index: index),

                /// Overview refers to the first thing your user sees when getting to settings, before they have made
                /// any action, as well as after they made an action (such as changing pincode)
                /// See [OverviewConfiguration] for all the data available to you
                overviewBuilder: (config) => Center(
                  /// [isLoading] indicates that user's preferences are still being fetched
                  child: config.isLoading
                      ? const CircularProgressIndicator()
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  /// [isPinEnabled] is only `null` while [isLoading] is `true`
                                  Text(localization.settingPinCode),
                                  Switch(
                                    value: config.isPinEnabled!,

                                    /// [onTogglePin] callback is passed to a button (or a switch) that user
                                    /// clicks to change their preferences
                                    onChanged: (_) => config.onTogglePin(),
                                  ),
                                ],
                              ),

                              /// In case of something going wrong, [OverviewConfiguration] provides an [error] property
                              if (config.error != null)
                                Text(config.error!.toString(),
                                    style: const TextStyle(color: Colors.red)),

                              /// If biometric authentication is available, provide an option to toggle it on or off
                              if (config.isBiometricAuthAvailable == true)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(localization.useFingerprint),
                                    Switch(
                                      value: config.isBiometricAuthEnabled!,
                                      onChanged: (_) =>
                                          config.onToggleBiometric(),
                                    ),
                                  ],
                                ),

                              /// If pin is enabled, you can give your user an option to change it
                              if (config.isPinEnabled == true)
                                ElevatedButton(
                                  /// If you do not the pincode to be changable, simply never trigger [config.onPasswordChangeRequested]
                                  /// If this callback is never triggered, the [changingWidget] builder is never needed, so it is
                                  /// save to have it simply return a `Container` or a `SizedBox`
                                  onPressed: config.onPasswordChangeRequested,
                                  child: Text(localization.changePassCode),
                                ),
                            ],
                          ),
                        ),
                ),

                /// EnablingWidget is a builder that describes what [AuthenticationSetupWidget] looks like while pin code is being enabled
                /// See [EnablingPinConfiguration] for more detail
                enablingWidget: (configuration) => Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(localization.fillPinCode),

                      /// Make sure [configuration.pinInputWidget] and [configuration.pinConfirmationWidget] are visible on the screen, since
                      /// they are the main point of interaction between your user and the PinLock package
                      configuration.pinInputWidget,
                      const SizedBox(height: 24),
                      Text(localization.repeatPinCode),

                      /// [pinInputWidget] and [pinConfirmationWidget] can be presented side by side or one by one
                      configuration.pinConfirmationWidget,

                      /// [configuration.error] provides details if something goes wrong (e.g., pins don't match)
                      if (configuration.error != null)
                        Text(configuration.error.toString(),
                            style: const TextStyle(color: Colors.red)),

                      /// [configuration.canSubmitChange] can optionaly be used to hide or disable submit button
                      /// It is also possible to listen for this property and programatically trigger [config.onSubmitChange],
                      /// for example if you want to make a call to the library as soon as the fields are filled, without
                      /// making the user press a button
                      if (configuration.canSubmitChange)
                        ElevatedButton(
                          onPressed: configuration.onSubmitChange,
                          child: Text(localization.updateData),
                        )
                    ],
                  ),
                ),

                /// DisablingWidget is a builder that describes what [AuthenticationSetupWidget] looks like while pin code is being disabled
                /// See [DisablingPinConfiguration] for more detail
                disablingWidget: (configuration) => Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(localization.fillPinCode),

                      /// Make sure [configuration.pinInputWidget] is visible on the screen
                      configuration.pinInputWidget,

                      /// Display errors if there is any
                      if (configuration.error != null)
                        Text(
                          configuration.error.toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      if (configuration.canSubmitChange)
                        ElevatedButton(
                            onPressed: configuration.onChangeSubmitted,
                            child: Text(localization.updateData))
                    ],
                  ),
                ),

                changingWidget: (configuration) => Column(
                  children: [
                    Text(localization.currentPin),
                    configuration.oldPinInputWidget,
                    if (_isCurrentPinIssue(configuration.error))
                      Text(
                        configuration.error!.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    Text(localization.newPin),
                    configuration.newPinInputWidget,
                    Text(localization.confirmNewPin),
                    configuration.confirmNewPinInputWidget,
                    if (configuration.error != null &&
                        !_isCurrentPinIssue(configuration.error))
                      Text(
                        configuration.error!.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    if (configuration.canSubmitChange)
                      ElevatedButton(
                        onPressed: configuration.onSubimtChange,
                        child: Text(localization.updateData),

                        //child: const Text('Save'),
                      )
                  ],
                ),
              ),
            );
          } else {
            return Text("${localization!.loading}...");
          }
        });
  }

  bool _isCurrentPinIssue(LocalAuthFailure? error) {
    return error == LocalAuthFailure.wrongPin ||
        error == LocalAuthFailure.tooManyAttempts;
  }
}
