import 'package:flutter/material.dart';
import 'package:kalender/kalender_extensions.dart';
import 'package:kalender/src/models/calendar_events/calendar_event.dart';

/// A controller for [CalendarEvent]s.
///
/// This is used to store and manage the [CalendarEvent]s.
class EventsController<T extends CalendarEvent<T>> with ChangeNotifier {
  ValueNotifier<Size> feedbackWidgetSize = ValueNotifier(Size.zero);

  Iterable<T> get events => _eventLookUp._idToEventMap.values;

  /// A Map of dates and event ids.
  final _eventLookUp = EventLookUp<T>();

  /// Adds an [CalendarEvent].
  ///
  /// Returns the id assigned to the event.
  int addEvent(T event) {
    final id = _eventLookUp.addEvent(event);
    notifyListeners();
    return id;
  }

  /// Adds a list of [CalendarEvent]'s.
  ///
  /// Returns the id's assigned to the events in order.
  List<int> addEvents(List<T> events) {
    final ids = events.map(addEvent).toList();
    notifyListeners();
    return ids;
  }

  /// Removes an [CalendarEvent].
  void removeEvent(T event) {
    _eventLookUp.removeEvent(event);
    notifyListeners();
  }

  /// Remove an [CalendarEvent] with its id.
  void removeById(int id) {
    _eventLookUp.removeEventById(id);
    notifyListeners();
  }

  /// Removes a list of [CalendarEvent]'s where the [test] returns true.
  void removeWhere(bool Function(T element) test) {
    _eventLookUp._idToEventMap.values.where((event) => test(event)).forEach(removeEvent);
    notifyListeners();
  }

  /// Removes all [CalendarEvent]'s.
  void clearEvents() {
    _eventLookUp.clear();
    notifyListeners();
  }

  /// Updates an [CalendarEvent].
  ///
  /// The [event] is the event that needs to be changed.
  /// The [updatedEvent] is the event that will replace the [event].
  void updateEvent({
    required T event,
    required T updatedEvent,
  }) {
    _eventLookUp.updateEvent(event, updatedEvent);
    notifyListeners();
  }

  /// Retrieve a [CalendarEvent] by it's id if it exists.
  T? eventById(int id) => _eventLookUp.getEventById(id);
  int idByEvent(T event) => _eventLookUp.getIdByEvent(event) ?? -1;

  /// Finds the [CalendarEvent]s that occur during the [dateTimeRange].
  Iterable<T> eventsFromDateTimeRange(
    DateTimeRange dateTimeRange, {
    bool includeMultiDayEvents = true,
    bool includeDayEvents = true,
  }) {
    final eventIds = _eventLookUp.eventIdsFromDateTimeRange(dateTimeRange);
    final events = eventIds.map(_eventLookUp.getEventById).nonNulls;

    if (includeMultiDayEvents && includeDayEvents) {
      return events.where((event) => event.dateTimeRangeAsUtc.overlaps(dateTimeRange));
    } else if (includeMultiDayEvents) {
      return _multiDayEventsFromDateTimeRange(events, dateTimeRange);
    } else if (includeDayEvents) {
      return _dayEventsFromDateTimeRange(events, dateTimeRange);
    } else {
      return [];
    }
  }

  /// Finds the [CalendarEvent]s longer than 1 day that occur during the [dateTimeRange].
  Iterable<T> _multiDayEventsFromDateTimeRange(
    Iterable<T> events,
    DateTimeRange dateTimeRange,
  ) {
    return events.where((event) {
      // If the event is not a multi day event, return false.
      if (!event.isMultiDayEvent) return false;
      return event.dateTimeRangeAsUtc.overlaps(dateTimeRange);
    });
  }

  /// Finds the [CalendarEvent]s that are shorter than 1 day that occur during the [dateTimeRange].
  Iterable<T> _dayEventsFromDateTimeRange(
    Iterable<T> events,
    DateTimeRange dateTimeRange,
  ) {
    return events.where((event) {
      // If the event is a multi day event, return false.
      if (event.isMultiDayEvent) return false;
      return event.dateTimeRangeAsUtc.overlaps(dateTimeRange);
    });
  }
}

class EventLookUp<T extends CalendarEvent<T>> {
  final Map<int, T> _idToEventMap = {};
  final Map<T, int> _eventToIdMap = {};
  final Map<DateTime, Set<int>> _dateIdMap = {};

  int _lastId = 0;
  int get _nextId {
    _lastId++;
    return _lastId;
  }

  /// Adds an event.
  int addEvent(T event) {
    final id = _nextId;

    _idToEventMap[id] = event;
    _eventToIdMap[event] = id;

    final dates = event.datesSpanned;
    for (final date in dates) {
      _dateIdMap.update(date, (value) => value..add(id), ifAbsent: () => {id});
    }

    return id;
  }

  /// Removes an event.
  void removeEvent(T event) {
    final id = getIdByEvent(event);
    if (id == null) return;
    removeEventById(id);
  }

  /// Removes an event by its ID.
  void removeEventById(int id) {
    final event = _idToEventMap.remove(id);

    if (event != null) {
      _eventToIdMap.remove(event);

      final dates = event.datesSpanned;
      for (final date in dates) {
        _dateIdMap.update(date, (value) => value..remove(id));
      }
    }
  }

  /// Update an [event] with the [updatedEvent].
  void updateEvent(T event, T updatedEvent) {
    removeEvent(event);
    addEvent(updatedEvent);
  }

  /// Finds an event by its ID.
  T? getEventById(int id) => _idToEventMap[id];

  /// Finds an event ID by the event object.
  int? getIdByEvent(T event) => _eventToIdMap[event];

  /// Checks if the map contains an event with the given ID.
  bool containsId(int id) => _idToEventMap.containsKey(id);

  /// Checks if the map contains the given event.
  bool containsEvent(T event) => _eventToIdMap.containsKey(event);

  /// Retrieve a [Set] of event id's from the map.
  Set<int> eventIdsFromDateTimeRange(DateTimeRange dateTimeRange) {
    assert(dateTimeRange.isUtc, 'The DateTimeRange must be in UTC.');
    final days = dateTimeRange.dates();
    final eventIds = <int>{};
    for (final day in days) {
      eventIds.addAll(_dateIdMap[day] ?? {});
    }
    return eventIds;
  }

  /// Clears all events from the map.
  void clear() {
    _idToEventMap.clear();
    _eventToIdMap.clear();
    _dateIdMap.clear();
  }
}