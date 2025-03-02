import 'package:flutter/material.dart';
import 'package:kalender/kalender_extensions.dart';

/// A class representing an object that can be displayed by the calendar.
///
/// To use this class, extend it and implement the required methods.
/// * [T] is the type of the class that extends [CalendarEvent].
/// * [T] is used to return the correct type when updating the [CalendarEvent],
///    from within the package.
///
/// Basic example:
/// ```dart
/// class Event extends CalendarEvent<Event> {
///   final String title;
/// 
///   Event({
///     required this.title,
///     required this.dateTimeRange,
///   });
/// 
///   @override
///   final DateTimeRange dateTimeRange;
/// 
///   @override
///   bool get canModify => true;
/// 
///   @override
///   Event updateDateTimeRange({required DateTimeRange dateTimeRange}) {
///     return Event(title: title, dateTimeRange: dateTimeRange);
///   }
/// }
/// ```
///
/// Example with a custom data class:
/// ```dart
/// class Data {
///   final DateTime start;
///   final DateTime end;
///   const Data({required this.start, required this.end});
/// 
///   /// The [DateTimeRange] of the [Data].
///   DateTimeRange get dateTimeRange => DateTimeRange(start: start, end: end);
/// 
///   /// Create a new [Data] with the new dateTimeRange.
///   Data.update(DateTimeRange range) : this(start: range.start, end: range.end);
/// }
/// 
/// class EventData extends CalendarEvent<EventData> {
///   final Data data;
/// 
///   EventData({
///     required this.data,
///   });
/// 
///   @override
///   DateTimeRange get dateTimeRange => data.dateTimeRange;
/// 
///   @override
///   bool get canModify => true;
/// 
///   @override
///   EventData updateDateTimeRange({required DateTimeRange dateTimeRange}) {
///     return EventData(data: Data.update(dateTimeRange));
///   }
/// }
/// ```
@immutable
abstract class CalendarEvent<T> with _EventUtils {
  @override
  DateTimeRange get dateTimeRange;

  /// Whether this [CalendarEvent] can be modified.
  ///
  /// TODO: split this into canResize (start/end), canDrag, canCreate, etc.
  bool get canModify;

  /// Create a new [CalendarEvent] with the new dateTimeRange.
  T updateDateTimeRange({required DateTimeRange dateTimeRange});
}

mixin _EventUtils {
  /// The [DateTimeRange] of the event can be stored in any timezone.
  DateTimeRange get dateTimeRange;

  /// The [DateTimeRange] of the event stored in utc timezone.
  late final DateTimeRange _dateTimeRange = dateTimeRange.toUtc();

  /// The [DateTimeRange] of the [CalendarEvent] in utc time.
  DateTimeRange get dateTimeRangeAsUtc => _dateTimeRange;

  /// The start [DateTime] of the [CalendarEvent] in utc time.
  DateTime get startAsUtc => _dateTimeRange.start;

  /// The end [DateTime] of the [CalendarEvent] in utc time.
  DateTime get endAsUtc => _dateTimeRange.end;

  /// The total duration of the [CalendarEvent] this uses utc time for the calculation.
  Duration get duration => _dateTimeRange.duration;

  /// Whether the [CalendarEvent] is longer than a day.
  bool get isMultiDayEvent => duration.inDays > 0;

  /// The [DateTime]s that the [CalendarEvent] spans. This uses utc time.
  List<DateTime> get datesSpanned => _dateTimeRange.dates();
}

