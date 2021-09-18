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

import '../scale.dart' show Extents;

class DateTimeExtents extends Extents<DateTime> {
  final DateTime start;
  final DateTime end;

  DateTimeExtents({required this.start, required this.end});

  @override
  bool operator ==(Object other) {
    return other is DateTimeExtents && start == other.start && end == other.end;
  }

  @override
  int get hashCode => start.hashCode + (end.hashCode * 37);
}
