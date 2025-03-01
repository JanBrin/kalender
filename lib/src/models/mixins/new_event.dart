import 'package:kalender/kalender.dart';

mixin NewEvent<T extends CalendarEvent<T>> {
  /// The event that is being created by the controller.
  T? _newEvent;
  T? get newEvent => _newEvent;

  void setNewEvent(T event) {
    if (_newEvent == event) return;
    _newEvent = event;
  }

  void clearNewEvent() {
    _newEvent = null;
  }
}
