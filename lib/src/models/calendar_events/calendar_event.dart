import 'package:flutter/material.dart';
import 'package:kalender/src/extensions.dart';
import 'package:kalender/src/models/calendar_events/recurrence.dart';

/// A class representing a object that can be displayed by the calendar.
///
/// A calendar event requires a [DateTimeRange] this is used by the [CalendarView] to render the event.
///
/// Any calculations done with the [_dateTimeRange] should be done in utc time and then converted back to local time.
class CalendarEvent<T extends Object?> {
  /// The data of the [CalendarEvent].
  T? data;

  /// How or if this event recurs.
  final Recurrence recurrence;

  /// The [DateTimeRange] of the [CalendarEvent].
  final DateTimeRange _dateTimeRange;

  /// Whether this [CalendarEvent] can be modified.
  final bool canModify;

  CalendarEvent({
    required DateTimeRange dateTimeRange,
    this.recurrence = const RecurNone(),
    this.data,
    this.canModify = true,
  }) : _dateTimeRange = dateTimeRange;

  CalendarEvent.fromDuration({
    required DateTime start,
    required Duration duration,
    this.recurrence = const RecurNone(),
    this.data,
    this.canModify = true,
  }) : _dateTimeRange = DateTimeRange(start: start, end: start.asUtc.add(duration).asLocal);

  /// The unique id is a reference to the original event added to the [EventsController].
  int _uniqueId = -1;
  int get uniqueId => _uniqueId;
  set uniqueId(int value) {
    if (_uniqueId != -1) return;
    _uniqueId = value;
  }

  /// The id of the [CalendarEvent] is used as a reference to a specific event that is rendered by the [CalendarView].
  ///
  /// The original [CalendarEvent] might be duplicated with different [id]'s based on the [recurrence].
  int _id = -1;
  int get id => _id;
  set id(int value) {
    if (_id != -1) return;
    _id = value;
  }

  /// The [DateTimeRange] of the [CalendarEvent].
  DateTimeRange get dateTimeRange => _dateTimeRange;

  /// The [DateTimeRange] of the [CalendarEvent] in the [DateTime.utc] format.
  DateTimeRange get _dateTimeRangeAsUtc => _dateTimeRange.asUtc;

  /// The start [DateTime] of the [CalendarEvent].
  DateTime get start => dateTimeRange.start.asLocal;

  /// The start [DateTime.utc] of the [CalendarEvent].
  DateTime get _startAsUTC => start.asUtc;

  /// The end [DateTime] of the [CalendarEvent].
  DateTime get end => dateTimeRange.end.asLocal;

  /// The end [DateTime.utc] of the [CalendarEvent].
  DateTime get _endAsUTC => end.asUtc;

  /// Whether the [CalendarEvent] is a multi day event.
  bool get isMultiDayEvent => dateTimeRange.dayDifference >= 1;

  /// The [DateTime]s that the [CalendarEvent] spans.
  List<DateTime> get datesSpanned => dateTimeRange.days;

  /// The [DateTime]s that the [CalendarEvent] spans as UTC [DateTime]s.
  List<DateTime> get datesSpannedAsUtc => _dateTimeRangeAsUtc.days;

  /// The total duration of the [CalendarEvent].
  Duration get duration => dateTimeRange.duration;

  /// Whether the [CalendarEvent] is during the given [DateTimeRange].
  ///
  /// This expects the [DateTimeRange]'s start and end dates to be constructed in the [DateTime.utc] format.
  bool occursDuringDateTimeRange(DateTimeRange dateTimeRange) {
    assert(dateTimeRange.isUtc);
    return _dateTimeRangeAsUtc.occursDuring(dateTimeRange);
  }

  /// Whether the [CalendarEvent] continues before the given [DateTime].
  ///
  /// This expects the [DateTime] to be constructed with [DateTime.utc].
  bool continuesBefore(DateTime date) {
    assert(date.isUtc, 'The $date should be in utc time.');
    return _startAsUTC.isBefore(date.startOfDay);
  }

  /// Whether the [CalendarEvent] continues after the given [DateTime].
  ///
  /// This expects the [DateTime] to be constructed with [DateTime.utc].
  bool continuesAfter(DateTime date) {
    assert(date.isUtc, 'The $date should be in utc time.');
    return _endAsUTC.isAfter(date.endOfDay);
  }

  /// The [DateTimeRange] of the [CalendarEvent] on a specific date.
  ///
  /// This expects the [DateTime] to be constructed with [DateTime.utc].
  DateTimeRange dateTimeRangeOnDate(DateTime date) {
    assert(date.isUtc, 'The $date should be in utc time.');
    return _dateTimeRangeAsUtc.dateTimeRangeOnDate(date);
  }

  /// Copy the [CalendarEvent] with the new values.
  CalendarEvent<T> copyWith({DateTimeRange? dateTimeRange, T? data, Recurrence? recurrence}) {
    return CalendarEvent<T>(
      data: data ?? this.data,
      dateTimeRange: dateTimeRange ?? this.dateTimeRange,
      recurrence: recurrence ?? this.recurrence,
    );
  }

  @override
  String toString() {
    return 'id: $uniqueId, data: $data, start: $start, end: $end';
  }
}
