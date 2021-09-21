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

/// Interface for factory that creates [DateTime] and [DateFormat].
///
/// This allows for creating of locale specific date time and date format.
abstract class DateTimeFactory {
  // TODO: Per cbraun@, we need to allow setting the timezone that
  // is used globally (along with other settings like which day the week starts
  // on. Use DateTimeFactory - either return a local DateTime or a UTC date time
  // based on the setting.

  // TODO: We need to incorporate the time zoned calendar here
  // because Dart DateTime doesn't do this. TZDateTime implements DateTime, so
  // we can use DateTime as the interface.
  DateTime createDateTimeFromMilliSecondsSinceEpoch(int millisecondsSinceEpoch);

  DateTime createDateTime(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0]);

  /// Returns a [DateFormat].
  DateFormat createDateFormat(String? pattern);
}

/// A local time [DateTimeFactory].
class LocalDateTimeFactory implements DateTimeFactory {
  const LocalDateTimeFactory();

  @override
  DateTime createDateTimeFromMilliSecondsSinceEpoch(
      int millisecondsSinceEpoch) {
    return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  }

  @override
  DateTime createDateTime(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0]) {
    return DateTime(
        year, month, day, hour, minute, second, millisecond, microsecond);
  }

  /// Returns a [DateFormat].
  @override
  DateFormat createDateFormat(String? pattern) => DateFormat(pattern);
}

/// An UTC time [DateTimeFactory].
class UTCDateTimeFactory implements DateTimeFactory {
  const UTCDateTimeFactory();

  @override
  DateTime createDateTimeFromMilliSecondsSinceEpoch(
      int millisecondsSinceEpoch) {
    return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch,
        isUtc: true);
  }

  @override
  DateTime createDateTime(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0]) {
    return DateTime.utc(
        year, month, day, hour, minute, second, millisecond, microsecond);
  }

  /// Returns a [DateFormat].
  @override
  DateFormat createDateFormat(String? pattern) => DateFormat(pattern);
}
