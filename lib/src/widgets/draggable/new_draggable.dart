import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';

abstract class NewDraggableWidget<T extends CalendarEvent<T>> extends StatelessWidget {
  final CalendarController<T> controller;
  final CalendarCallbacks<T>? callbacks;

  const NewDraggableWidget({
    super.key,
    required this.controller,
    required this.callbacks,
  });

  /// Calculate the DateTimeRange of the new event.
  DateTimeRange calculateDateTimeRange(DateTime date, Offset localPosition);

  /// Create the new event and select it where needed.
  void createNewEvent(DateTime date, Offset localPosition) {
    final dateTimeRange = calculateDateTimeRange(date, localPosition);
    final event = callbacks?.onEventCreate.call(dateTimeRange);
    if (event == null) return;
    controller.setNewEvent(event);
    controller.selectEvent(-1, event);
  }

  /// Deselect the new event.
  void onDragFinished([_, __]) => controller.clearNewEvent();
}
