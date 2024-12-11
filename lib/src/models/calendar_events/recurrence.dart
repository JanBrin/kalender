import 'package:flutter/material.dart';
import 'package:kalender/kalender_extensions.dart';

/// The base class for recurrence.
///
/// It contains
abstract class Recurrence {
  const Recurrence();

  List<DateTimeRange> dateTimeRanges(DateTimeRange originalDateTimeRange);
}

class RecurNone extends Recurrence {
  const RecurNone();

  @override
  List<DateTimeRange> dateTimeRanges(DateTimeRange originalDateTimeRange) => [originalDateTimeRange];
}

class RecurDaily extends Recurrence {
  /// The [DateTimeRange] that this event is recurring for.
  final DateTimeRange recurringDateTimeRange;

  const RecurDaily(this.recurringDateTimeRange);

  Recurrence copyWith(DateTimeRange? recurringDateTimeRange) {
    return RecurDaily(
      recurringDateTimeRange ?? this.recurringDateTimeRange,
    );
  }

  @override
  List<DateTimeRange> dateTimeRanges(DateTimeRange originalDateTimeRange) {
    final dates = recurringDateTimeRange.asUtc.days;
    final recurrences = <DateTimeRange>[];
    for (final dateUtc in dates) {
      final date = dateUtc.asLocal;
      final start = originalDateTimeRange.start.copyWith(year: date.year, month: date.month, day: date.day);
      final end = originalDateTimeRange.end.copyWith(year: date.year, month: date.month, day: date.day);
      recurrences.add(DateTimeRange(start: start, end: end));
    }
    return recurrences;
  }
}

// class Weekly extends Recurrence {
//   const Weekly() : super._();
// }

// class Monthly extends Recurrence {
//   const Monthly() : super._();
// }

// class Annually extends Recurrence {
//   const Annually() : super._();
// }
