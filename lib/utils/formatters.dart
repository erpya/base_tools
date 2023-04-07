// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:base_tools/themes/movile_options.dart';
import 'package:intl/intl.dart';

/// Get the locale string for the context.
String locale(BuildContext context) =>
    MovileOptions.of(context).locale.toString();

/// Currency formatter for USD.
NumberFormat usdWithSignFormat(BuildContext context, {int decimalDigits = 2}) {
  return NumberFormat.currency(
    locale: locale(context),
    name: '\$',
    decimalDigits: decimalDigits,
  );
}

/// Percent formatter with two decimal points.
NumberFormat percentFormat(BuildContext context, {int decimalDigits = 2}) {
  return NumberFormat.decimalPercentPattern(
    locale: locale(context),
    decimalDigits: decimalDigits,
  );
}

String formatAmount(BuildContext context, num value) {
  var format = NumberFormat("###,###,###,###,##0.00");
  if(!kIsWeb) {
    format = NumberFormat("###,###,###,###,##0.00", Platform.localeName);
  }
  return format.format(value);
  return NumberFormat("###,###,###,###,##0.00", locale(context)).format(value);
}

String formatQuantity(BuildContext context, num value) =>
    NumberFormat("###,###,###,###,##0.00").format(value);


/// Date formatter with year / number month / day.
DateFormat shortDateFormat(BuildContext context) =>
    DateFormat.yMd(locale(context));

/// Date formatter with year / month / day.
DateFormat longDateFormat(BuildContext context) =>
    DateFormat.yMMMMd(locale(context));

/// Date formatter with abbreviated month and day.
DateFormat dateFormatAbbreviatedMonthDay(BuildContext context) =>
    DateFormat.MMMd(locale(context));

/// Date formatter with year and abbreviated month.
DateFormat dateFormatMonthYear(BuildContext context) =>
    DateFormat.yMMM(locale(context));

/// Date formatter with year and abbreviated month.
DateFormat dateFormatHours(BuildContext context) =>
    DateFormat.Hms(locale(context));