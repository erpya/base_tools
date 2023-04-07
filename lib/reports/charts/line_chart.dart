// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:base_tools/themes/movile_options.dart';
import 'package:base_tools/layout/adaptive.dart';
import 'package:base_tools/layout/text_scale.dart';
import 'package:base_tools/reports/charts/styles/colors.dart';
import 'package:base_tools/reports/charts/styles/data.dart';
import 'package:base_tools/utils/formatters.dart';
import 'package:intl/intl.dart' as intl;

class RallyLineChart extends StatelessWidget {
  const RallyLineChart({
    super.key,
    this.events = const <DetailedEventData>[],
  });

  final List<DetailedEventData> events;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RallyLineChartPainter(
        dateFormat: dateFormatMonthYear(context),
        numberFormat: usdWithSignFormat(context),
        events: events,
        labelStyle: Theme.of(context).textTheme.bodyMedium!,
        textDirection: MovileOptions.of(context).resolvedTextDirection(),
        textScaleFactor: reducedTextScale(context),
        padding: isDisplayDesktop(context)
            ? const EdgeInsets.symmetric(vertical: 22)
            : EdgeInsets.zero,
      ),
    );
  }
}

class RallyLineChartPainter extends CustomPainter {
  RallyLineChartPainter({
    required this.dateFormat,
    required this.numberFormat,
    required this.events,
    required this.labelStyle,
    required this.textDirection,
    required this.textScaleFactor,
    required this.padding,
  });

  // The style for the labels.
  final TextStyle labelStyle;

  // The text direction for the text.
  final TextDirection? textDirection;

  // The text scale factor for the text.
  final double textScaleFactor;

  // The padding around the text.
  final EdgeInsets padding;

  // The format for the dates.
  final intl.DateFormat dateFormat;

  // The currency format.
  final intl.NumberFormat numberFormat;

  // Events to plot on the line as points.
  final List<DetailedEventData> events;

  // Number of days to plot.
  // This is hardcoded to reflect the dummy data, but would be dynamic in a real
  // app.
  final int numDays = 52;

  // Beginning of window. The end is this plus numDays.
  // This is hardcoded to reflect the dummy data, but would be dynamic in a real
  // app.
  final DateTime startDate = DateTime.utc(2018, 12, 1);

  // Ranges uses to lerp the pixel points.
  // This is hardcoded to reflect the dummy data, but would be dynamic in a real
  // app.
  final double maxAmount = 2000; // minAmount is assumed to be 0

  // The number of milliseconds in a day. This is the inherit period fot the
  // points in this line.
  static const int millisInDay = 24 * 60 * 60 * 1000;

  // Amount to shift the tick drawing by so that the Sunday ticks do not start
  // on the edge.
  final int tickShift = 3;

  // Arbitrary unit of space for absolute positioned painting.
  final double space = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final labelHeight = space + space * (textScaleFactor - 1);
    final ticksHeight = 3 * space;
    final ticksTop = size.height - labelHeight - ticksHeight - space;
    final labelsTop = size.height - labelHeight;
    _drawLine(
      canvas,
      Rect.fromLTWH(0, 0, size.width, size.height - labelHeight - ticksHeight),
    );
    _drawXAxisTicks(
      canvas,
      Rect.fromLTWH(0, ticksTop, size.width, ticksHeight),
    );
    _drawXAxisLabels(
      canvas,
      Rect.fromLTWH(0, labelsTop, size.width, labelHeight),
    );
  }

  // Since we're only using fixed dummy data, we can set this to false. In a
  // real app we would have the data as part of the state and repaint when it's
  // changed.
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (size) {
      final amounts = _amountsPerDay(numDays);

      // We divide the graph and the amounts into [numGroups] groups, with
      // [numItemsPerGroup] amounts per group.
      const numGroups = 10;
      final numItemsPerGroup = amounts.length ~/ numGroups;

      // For each group we calculate the median value.
      final medians = List.generate(
        numGroups,
        (i) {
          final middleIndex = i * numItemsPerGroup + numItemsPerGroup ~/ 2;
          if (numItemsPerGroup.isEven) {
            return (amounts[middleIndex] + amounts[middleIndex + 1]) / 2;
          } else {
            return amounts[middleIndex];
          }
        },
      );

      // Return a list of [CustomPainterSemantics] with the length of
      // [numGroups], all have the same width with the median amount as label.
      return List.generate(numGroups, (i) {
        return CustomPainterSemantics(
          rect: Offset((i / numGroups) * size.width, 0) &
              Size(size.width / numGroups, size.height),
          properties: SemanticsProperties(
            label: numberFormat.format(medians[i]),
            textDirection: textDirection,
          ),
        );
      });
    };
  }

  /// Returns the amount of money in the account for the [numDays] given
  /// from the [startDate].
  List<double> _amountsPerDay(int numDays) {
    // Arbitrary value for the first point. In a real app, a wider range of
    // points would be used that go beyond the boundaries of the screen.
    var lastAmount = 600.0;

    // Align the points with equal deltas (1 day) as a cumulative sum.
    var startMillis = startDate.millisecondsSinceEpoch;

    final amounts = <double>[];
    for (var i = 0; i < numDays; i++) {
      final endMillis = startMillis + millisInDay * 1;
      final filteredEvents = events.where(
        (e) {
          return startMillis <= e.date.millisecondsSinceEpoch &&
              e.date.millisecondsSinceEpoch < endMillis;
        },
      ).toList();
      lastAmount += sumOf<DetailedEventData>(filteredEvents, (e) => e.amount);
      amounts.add(lastAmount);
      startMillis = endMillis;
    }
    return amounts;
  }

  void _drawLine(Canvas canvas, Rect rect) {
    final linePaint = Paint()
      ..color = ReportColors.accountColor(2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Try changing this value between 1, 7, 15, etc.
    const smoothing = 1;

    final amounts = _amountsPerDay(numDays + smoothing);
    final points = <Offset>[];
    for (var i = 0; i < amounts.length; i++) {
      final x = i / numDays * rect.width;
      final y = (maxAmount - amounts[i]) / maxAmount * rect.height;
      points.add(Offset(x, y));
    }

    // Add last point of the graph to make sure we take up the full width.
    points.add(
      Offset(
        rect.width,
        (maxAmount - amounts[numDays - 1]) / maxAmount * rect.height,
      ),
    );

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < numDays - smoothing + 2; i += smoothing) {
      final x1 = points[i].dx;
      final y1 = points[i].dy;
      final x2 = (x1 + points[i + smoothing].dx) / 2;
      final y2 = (y1 + points[i + smoothing].dy) / 2;
      path.quadraticBezierTo(x1, y1, x2, y2);
    }
    canvas.drawPath(path, linePaint);
  }

  /// Draw the X-axis increment markers at constant width intervals.
  void _drawXAxisTicks(Canvas canvas, Rect rect) {
    for (var i = 0; i < numDays; i++) {
      final x = rect.width / numDays * i;
      canvas.drawRect(
        Rect.fromPoints(
          Offset(x, i % 7 == tickShift ? rect.top : rect.center.dy),
          Offset(x, rect.bottom),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = ReportColors.gray25,
      );
    }
  }

  /// Set X-axis labels under the X-axis increment markers.
  void _drawXAxisLabels(Canvas canvas, Rect rect) {
    final selectedLabelStyle = labelStyle.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: labelStyle.fontSize! * textScaleFactor,
    );
    final unselectedLabelStyle = labelStyle.copyWith(
      fontWeight: FontWeight.w700,
      color: ReportColors.gray25,
      fontSize: labelStyle.fontSize! * textScaleFactor,
    );

    // We use toUpperCase to format the dates. This function uses the language
    // independent Unicode mapping and thus only works in some languages.
    final leftLabel = TextPainter(
      text: TextSpan(
        text: dateFormat.format(startDate).toUpperCase(),
        style: unselectedLabelStyle,
      ),
      textDirection: textDirection,
    );
    leftLabel.layout();
    leftLabel.paint(canvas,
        Offset(rect.left + space / 2 + padding.vertical, rect.topCenter.dy));

    final centerLabel = TextPainter(
      text: TextSpan(
        text: dateFormat
            .format(DateTime(startDate.year, startDate.month + 1))
            .toUpperCase(),
        style: selectedLabelStyle,
      ),
      textDirection: textDirection,
    );
    centerLabel.layout();
    final x = (rect.width - centerLabel.width) / 2;
    final y = rect.topCenter.dy;
    centerLabel.paint(canvas, Offset(x, y));

    final rightLabel = TextPainter(
      text: TextSpan(
        text: dateFormat
            .format(DateTime(startDate.year, startDate.month + 2))
            .toUpperCase(),
        style: unselectedLabelStyle,
      ),
      textDirection: textDirection,
    );
    rightLabel.layout();
    rightLabel.paint(
      canvas,
      Offset(rect.right - centerLabel.width - space / 2 - padding.vertical,
          rect.topCenter.dy),
    );
  }
}
