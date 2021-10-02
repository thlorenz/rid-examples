// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:intl/intl.dart' show DateFormat;
import '../../../../common/date_time_factory.dart' show DateTimeFactory;
import 'time_tick_formatter.dart' show TimeTickFormatter;

/// Formatter that can format simple and transition time ticks differently.
class TimeTickFormatterImpl implements TimeTickFormatter {
  final DateFormat _simpleFormat;
  final DateFormat _transitionFormat;
  final CalendarField? transitionField;

  /// Create time tick formatter.
  ///
  /// [dateTimeFactory] factory to use to generate the [DateFormat].
  /// [simpleFormat] format to use for most ticks.
  /// [transitionFormat] format to use when the time unit transitions.
  /// For example showing the month with the date for Jan 1.
  /// [transitionField] the calendar field that indicates transition.
  TimeTickFormatterImpl({
    required DateTimeFactory dateTimeFactory,
    required String? simpleFormat,
    required String? transitionFormat,
    this.transitionField,
  })  : _simpleFormat = dateTimeFactory.createDateFormat(simpleFormat),
        _transitionFormat = dateTimeFactory.createDateFormat(transitionFormat);

  @override
  String formatFirstTick(DateTime date) => _transitionFormat.format(date);

  @override
  String formatSimpleTick(DateTime date) => _simpleFormat.format(date);

  @override
  String formatTransitionTick(DateTime date) => _transitionFormat.format(date);

  @override
  bool isTransition(DateTime tickValue, DateTime prevTickValue) {
    // Transition is always false if no transition field is specified.
    final transitionField = this.transitionField;
    if (transitionField == null) {
      return false;
    }
    final prevTransitionFieldValue =
        getCalendarField(prevTickValue, transitionField);
    final transitionFieldValue = getCalendarField(tickValue, transitionField);
    return prevTransitionFieldValue != transitionFieldValue;
  }

  /// Gets the calendar field for [dateTime].
  int getCalendarField(DateTime dateTime, CalendarField field) {
    switch (field) {
      case CalendarField.year:
        return dateTime.year;
      case CalendarField.month:
        return dateTime.month;
      case CalendarField.date:
        return dateTime.day;
      case CalendarField.hourOfDay:
        return dateTime.hour;
      case CalendarField.minute:
        return dateTime.minute;
      case CalendarField.second:
        return dateTime.second;
    }
  }
}

enum CalendarField {
  year,
  month,
  date,
  hourOfDay,
  minute,
  second,
}
