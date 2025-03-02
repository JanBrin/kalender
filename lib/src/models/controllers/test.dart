// import 'package:flutter/material.dart';
// import 'package:kalender/kalender.dart';

// class EventLookupMap<T extends CalendarEvent<T>> {
//   final Map<int, T> _idToEventMap = {};
//   final Map<T, int> _eventToIdMap = {};

//   /// Adds an event to the map.
//   void addEvent(int id, T event) {
//     _idToEventMap[id] = event;
//     _eventToIdMap[event] = id;
//   }

//   /// Removes an event from the map.
//   void removeEvent(int id) {
//     final event = _idToEventMap.remove(id);
//     if (event != null) {
//       _eventToIdMap.remove(event);
//     }
//   }

//   /// Finds an event by its ID.
//   T? getEventById(int id) {
//     return _idToEventMap[id];
//   }

//   /// Finds an event ID by the event object.
//   int? getIdByEvent(T event) {
//     return _eventToIdMap[event];
//   }

//   /// Clears all events from the map.
//   void clear() {
//     _idToEventMap.clear();
//     _eventToIdMap.clear();
//   }

//   /// Checks if the map contains an event with the given ID.
//   bool containsId(int id) {
//     return _idToEventMap.containsKey(id);
//   }

//   /// Checks if the map contains the given event.
//   bool containsEvent(T event) {
//     return _eventToIdMap.containsKey(event);
//   }
// }

// /// A controller for [CalendarEvent]s.
// ///
// /// This is used to store and manage the [CalendarEvent]s.
// class EventsController<T extends CalendarEvent<T>> with ChangeNotifier {
//   ValueNotifier<Size> feedbackWidgetSize = ValueNotifier(Size.zero);

//   /// The map for efficient event lookup.
//   final EventLookupMap<T> _eventLookupMap = EventLookupMap<T>();

//   /// The list of [CalendarEvent]s.
//   Iterable<T> get events => _eventLookupMap._idToEventMap.values;

//   /// A Map of dates and event ids.
//   final _dateMap = DateMap<T>();

//   int _lastId = 0;
//   int get _nextId {
//     _lastId++;
//     return _lastId;
//   }

//   /// Adds an [CalendarEvent] to the [EventsController].
//   ///
//   /// Returns the id assigned to the event.
//   int addEvent(T event) {
//     final id = _assignIdAndAdd(event);
//     notifyListeners();
//     return id;
//   }

//   /// Adds a list of [CalendarEvent]s to the [EventsController].
//   ///
//   /// Returns the id's assigned to the events in order.
//   List<int> addEvents(List<T> events) {
//     final ids = events.map(_assignIdAndAdd).toList();
//     notifyListeners();
//     return ids;
//   }

//   /// Removes an [CalendarEvent] from the list of [CalendarEvent]s.
//   void removeEvent(T event) {
//     assert(event.id != -1, 'The id of the event must be set before removing it.');
//     _eventLookupMap.removeEvent(event.id);
//     _dateMap.removeEvent(event);
//     notifyListeners();
//   }

//   /// Remove an [CalendarEvent] with its id.
//   void removeById(int id) {
//     assert(id != -1, 'Must be a valid id.');
//     final event = _eventLookupMap.getEventById(id);
//     if (event != null) {
//       _dateMap.removeEvent(event);
//       _eventLookupMap.removeEvent(id);
//       notifyListeners();
//     }
//   }

//   /// Removes a list of [CalendarEvent]s from the list of [CalendarEvent]s.
//   ///
//   /// The events will be removed where [test] returns true.
//   void removeWhere(bool Function(int key, T element) test) {
//     _eventLookupMap._idToEventMap.removeWhere(
//       (key, event) {
//         final remove = test(key, event);
//         if (remove) {
//           _dateMap.removeEvent(event);
//           _eventLookupMap.removeEvent(key);
//         }
//         return remove;
//       },
//     );
//     notifyListeners();
//   }

//   /// Removes all [CalendarEvent]s from [_events].
//   void clearEvents() {
//     _eventLookupMap.clear();
//     _dateMap.clear();
//     notifyListeners();
//   }

//   /// Updates an [CalendarEvent].
//   ///
//   /// The [event] is the event that needs to be changed.
//   /// The [updatedEvent] is the event that will replace the [event].
//   void updateEvent({
//     required T event,
//     required T updatedEvent,
//   }) {
//     updatedEvent.id = event.id;
//     _eventLookupMap.addEvent(event.id, updatedEvent);
//     _dateMap.updateEvent(event, updatedEvent);
//     notifyListeners();
//   }

//   /// Retrieve a [CalendarEvent] by its id if it exists.
//   T? byId(int id) => _eventLookupMap.getEventById(id);

//   /// Assigns an id to the [event] and adds it to the [_events] Map.
//   int _assignIdAndAdd(T event) {
//     assert(event.id == -1, 'The id of the event must not be set manually.');

//     event.id = _nextId;
//     _dateMap.addEvent(event);
//     _eventLookupMap.addEvent(event.id, event);

//     return event.id;
//   }

//   /// Finds the [CalendarEvent]s that occur during the [dateTimeRange].
//   Iterable<T> eventsFromDateTimeRange(
//     DateTimeRange dateTimeRange, {
//     bool includeMultiDayEvents = true,
//     bool includeDayEvents = true,
//   }) {
//     final eventIds = _dateMap.eventIdsFromDateTimeRange(dateTimeRange);
//     final events = eventIds.map((id) => _eventLookupMap.getEventById(id)).whereType<T>();

//     if (includeMultiDayEvents && includeDayEvents) {
//       return events.where((event) => event.dateTimeRangeAsUtc.overlaps(dateTimeRange));
//     } else if (includeMultiDayEvents) {
//       return _multiDayEventsFromDateTimeRange(events, dateTimeRange);
//     } else if (includeDayEvents) {
//       return _dayEventsFromDateTimeRange(events, dateTimeRange);
//     } else {
//       return [];
//     }
//   }

//   /// Finds the [CalendarEvent]s longer than 1 day that occur during the [dateTimeRange].
//   Iterable<T> _multiDayEventsFromDateTimeRange(
//     Iterable<T> events,
//     DateTimeRange dateTimeRange,
//   ) {
//     return events.where((event) {
//       // If the event is not a multi day event, return false.
//       if (!event.isMultiDayEvent) return false;
//       return event.dateTimeRangeAsUtc.overlaps(dateTimeRange);
//     });
//   }

//   /// Finds the [CalendarEvent]s that are shorter than 1 day that occur during the [dateTimeRange].
//   Iterable<T> _dayEventsFromDateTimeRange(
//     Iterable<T> events,
//     DateTimeRange dateTimeRange,
//   ) {
//     return events.where((event) {
//       // If the event is a multi day event, return false.
//       if (event.isMultiDayEvent) return false;
//       return event.dateTimeRangeAsUtc.overlaps(dateTimeRange);
//     });
//   }
// }

// /// A class for searching the events by date more efficient.
// class DateMap<T extends CalendarEvent<T>> {
//   /// Map of the [DateTime] and event ids.
//   ///
//   /// The [DateTime] is the date.
//   /// The [Set] of [int] is the ids of the events.
//   final Map<DateTime, Set<int>> _dateMap = {};

//   /// Clear the [_dateMap].
//   void clear() => _dateMap.clear();

//   /// Add an [event] to the map.
//   void addEvent(T event) {
//     final id = event.id;
//     final dates = event.datesSpanned;
//     for (final date in dates) {
//       _dateMap.update(
//         date,
//         (value) => value..add(id),
//         ifAbsent: () => {id},
//       );
//     }
//   }

//   /// Remove an [event] from the map.
//   void removeEvent(T event) {
//     final id = event.id;
//     final dates = event.datesSpanned;
//     for (final date in dates) {
//       _dateMap.update(
//         date,
//         (value) => value..remove(id),
//       );
//     }
//   }

//   /// Update an [event] in the map with the [updatedEvent].
//   void updateEvent(T event, T updatedEvent) {
//     removeEvent(event);
//     addEvent(updatedEvent);
//   }

//   /// Retrieve a [Set] of event id's from the map.
//   Set<int> eventIdsFromDateTimeRange(DateTimeRange dateTimeRange) {
//     assert(dateTimeRange.isUtc, 'The DateTimeRange must be in UTC.');
//     final days = dateTimeRange.dates();
//     final eventIds = <int>{};
//     for (final day in days) {
//       eventIds.addAll(_dateMap[day] ?? {});
//     }
//     return eventIds;
//   }
// }
