import 'package:flutter/material.dart';
import 'package:kalender/kalender_extensions.dart';
import 'package:kalender/src/models/calendar_events/calendar_event.dart';

/// A controller for [CalendarEvent]s.
///
/// This is used to store and manage the [CalendarEvent]s.
class EventsController<T extends Object?> with ChangeNotifier {
  ValueNotifier<Size> feedbackWidgetSize = ValueNotifier(Size.zero);

  final EventsMap<T> _eventMap = EventsMap<T>();

  /// The list of original [CalendarEvent]s.
  Iterable<CalendarEvent<T>> get events => _eventMap._events.values;

  /// Get a event with [CalendarEvent.uniqueId].
  CalendarEvent<T>? getEventById(int uniqueId) => _eventMap._events[uniqueId];

  /// Get a rendered event with [CalendarEvent.id].
  ///
  /// Rendered events include events duplicates of an event that is recurring.
  CalendarEvent<T>? getRenderedById(int id) => _eventMap._renderedEvents[id];

  /// Adds an [CalendarEvent] to the [EventsController].
  void addEvent(CalendarEvent<T> event) {
    _eventMap.addOriginal(event);
    notifyListeners();
  }

  /// Adds a list of [CalendarEvent]s to the [EventsController].
  void addEvents(List<CalendarEvent<T>> events) {
    for (final event in events) {
      _eventMap.addOriginal(event);
    }
    notifyListeners();
  }

  /// Removes an [CalendarEvent] from the list of [CalendarEvent]s.
  void removeEvent(CalendarEvent<T> event) {
    _eventMap.removeOriginal(event);
    notifyListeners();
  }

  /// Removes a list of [CalendarEvent]s from the list of [CalendarEvent]s.
  ///
  /// The events will be removed where [test] returns true.
  void removeWhere(bool Function(int key, CalendarEvent<T> element) test) {
    _eventMap.removeWhere(test);
    notifyListeners();
  }

  /// Removes all [CalendarEvent]s from [_eventMap].
  void clearEvents() {
    _eventMap.clear();
    notifyListeners();
  }

  /// Updates an [CalendarEvent].
  ///
  /// The [event] is the event that needs to be changed.
  /// The [updatedEvent] is the event that will replace the [event].
  void updateEvent({
    required CalendarEvent<T> event,
    required CalendarEvent<T> updatedEvent,
  }) {
    _eventMap.updateEvent(event, updatedEvent);
    notifyListeners();
  }

  /// Finds the [CalendarEvent]s that occur during the [dateTimeRange].
  Iterable<CalendarEvent<T>> eventsFromDateTimeRange(
    DateTimeRange dateTimeRange, {
    bool includeMultiDayEvents = true,
    bool includeDayEvents = true,
  }) {
    final eventIds = _eventMap.eventIdsFromDateTimeRange(dateTimeRange);
    final events = eventIds.map((id) => _eventMap._renderedEvents[id]).nonNulls;

    if (includeMultiDayEvents && includeDayEvents) {
      return events.where((event) => event.occursDuringDateTimeRange(dateTimeRange));
    } else if (includeMultiDayEvents) {
      return _multiDayEventsFromDateTimeRange(events, dateTimeRange);
    } else if (includeDayEvents) {
      return _dayEventsFromDateTimeRange(events, dateTimeRange);
    } else {
      return [];
    }
  }

  /// Finds the [CalendarEvent]s longer than 1 day that occur during the [dateTimeRange].
  Iterable<CalendarEvent<T>> _multiDayEventsFromDateTimeRange(
    Iterable<CalendarEvent<T>> events,
    DateTimeRange dateTimeRange,
  ) {
    return events.where((event) {
      // If the event is not a multi day event, return false.
      if (!event.isMultiDayEvent) return false;
      return event.occursDuringDateTimeRange(dateTimeRange);
    });
  }

  /// Finds the [CalendarEvent]s that are shorter than 1 day that occur during the [dateTimeRange].
  Iterable<CalendarEvent<T>> _dayEventsFromDateTimeRange(
    Iterable<CalendarEvent<T>> events,
    DateTimeRange dateTimeRange,
  ) {
    return events.where((event) {
      // If the event is a multi day event, return false.
      if (event.isMultiDayEvent) return false;
      return event.occursDuringDateTimeRange(dateTimeRange);
    });
  }
}

class EventsMap<T extends Object?> {
  /// Map of all the [CalendarEvent].
  ///
  /// {[CalendarEvent.uniqueId] : [CalendarEvent]}
  ///
  final Map<int, CalendarEvent<T>> _events = {};

  /// All the events that should be rendered.
  final Map<int, CalendarEvent<T>> _renderedEvents = {};

  /// The last id assigned to an event.
  int _lastId = 0;
  int get _nextId {
    _lastId++;
    return _lastId;
  }

  /// The last recurring id assigned to an event.
  int _lastRecurringId = 0;
  int get _nextRecurringId {
    _lastRecurringId++;
    return _lastRecurringId;
  }

  /// Map of [DateTime.utc] and [CalendarEvent.uniqueId]s on the date.
  ///
  /// TODO: split into day and multi-day events.
  final Map<DateTime, Set<int>> _dateIds = {};

  /// Map containing the original event's id and recurring events ids.
  final Map<int, Set<int>> _recurringEvents = {};

  /// Clear all events.
  void clear() {
    _events.clear();
    _renderedEvents.clear();
    _recurringEvents.clear();
    _dateIds.clear();
    _lastId = 0;
    _lastRecurringId = 0;
  }

  int _assignId(CalendarEvent<T> event) {
    if (event.uniqueId == -1) event.uniqueId = _nextId;
    return event.uniqueId;
  }

  void addOriginal(CalendarEvent<T> event) {
    final id = _assignId(event);
    assert(id != -1, 'To add an event an id must be assigned');

    // Add the event to the map.
    _events[id] = event;

    _add(event);
  }

  void _add(CalendarEvent<T> event) {
    final id = event.uniqueId;

    // Create and add all the recurring events.
    final recurrences = event.recurrence.dateTimeRanges(event.dateTimeRange);
    for (final recurrence in recurrences) {
      final recurringId = _nextRecurringId;
      final recurringEvent = event.copyWith(dateTimeRange: recurrence)
        ..uniqueId = id
        ..id = recurringId;

      _renderedEvents[recurringId] = recurringEvent;

      // Add the recurring id to the recurringEvents of the original event.
      _recurringEvents.update(id, (value) => value..add(recurringId), ifAbsent: () => {recurringId});

      // Add the recurring event's id to the _dateIds.
      final dates = recurringEvent.datesSpannedAsUtc;
      for (final date in dates) {
        _dateIds.update(date, (value) => value..add(recurringId), ifAbsent: () => {recurringId});
      }
    }
  }

  void removeOriginal(CalendarEvent<T> event) {
    final id = event.uniqueId;
    assert(id != -1, 'To add an event an id must be assigned');

    // Remove the event from the map.
    _events.remove(id);

    _remove(event);
  }

  void _remove(CalendarEvent<T> event) {
    final id = event.uniqueId;
    final recurringIds = _recurringEvents[id] ?? <int>{};

    for (final recurringId in recurringIds) {
      final recurringEvent = _renderedEvents[recurringId]!;
      final dates = recurringEvent.datesSpannedAsUtc;
      for (final date in dates) {
        _dateIds.update(date, (value) => value..remove(recurringId));
      }
    }
  }

  void removeWhere(bool Function(int key, CalendarEvent<T> element) test) {
    // TODO: implement this.
  }

  void updateEvent(CalendarEvent<T> event, CalendarEvent<T> updatedEvent) {
    final id = event.uniqueId;
    assert(id != -1, 'To add an event an id must be assigned');

    final originalEvent = _events[id]!;
    final updatedOriginal = originalEvent.copyWith(
      dateTimeRange: updatedEvent.dateTimeRange,
      data: updatedEvent.data,
      recurrence: updatedEvent.recurrence,
    );

    updatedEvent.uniqueId = id;

    removeOriginal(originalEvent);
    addOriginal(updatedOriginal);
  }

  /// Retrieve a [Set] of event id's from the map.
  Set<int> eventIdsFromDateTimeRange(DateTimeRange dateTimeRange) {
    final days = dateTimeRange.asUtc.days;
    final eventIds = <int>{};
    for (final day in days) {
      eventIds.addAll(_dateIds[day] ?? {});
    }
    return eventIds;
  }
}

// /// A class for searching the events by date more efficiently.
// class DateMap {
//   /// Map of the [DateTime] and event ids.
//   ///
//   /// This must become a List of ids since recurring events might in fact have multiple events present.
//   final Map<DateTime, Set<int>> _dateMap = {};

// /// The id of the recurring event.
// /// recurring event : original event.
// final Map<int, int> _recurringEvents = {};

// /// The id of the original event : alternative events.
// final Map<int, Set<int>> _recurringEventsMap = {};

//   /// Clear the [_dateMap].
//   void clear() => _dateMap.clear();

//   /// Add an [event] to the map.
//   void addEvent(CalendarEvent event) {
//     final id = event.id;
//     final dates = event.datesSpannedAsUtc;
//     for (final date in dates) {
//       _dateMap.update(
//         date,
//         (value) => value..add(id),
//         ifAbsent: () => {id},
//       );
//     }
//   }

//   /// Remove an [event] from the map.
//   void removeEvent(CalendarEvent event) {
//     final id = event.id;
//     final dates = event.datesSpannedAsUtc;
//     for (final date in dates) {
//       _dateMap.update(
//         date,
//         (value) => value..remove(id),
//       );
//     }
//   }

//   /// Update an [event] in the map with the [updatedEvent].
//   void updateEvent(CalendarEvent event, CalendarEvent updatedEvent) {
//     removeEvent(event);
//     addEvent(updatedEvent);
//   }

//   /// Retrieve a [Set] of event id's from the map.
//   Set<int> eventIdsFromDateTimeRange(DateTimeRange dateTimeRange) {
//     final days = dateTimeRange.asUtc.days;
//     final eventIds = <int>{};
//     for (final day in days) {
//       eventIds.addAll(_dateMap[day] ?? {});
//     }
//     return eventIds;
//   }
// }
