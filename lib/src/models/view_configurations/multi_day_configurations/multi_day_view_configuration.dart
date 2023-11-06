import 'package:kalender/src/models/view_configurations/view_configuration.dart';

/// This is the base class for all [MultiDayViewConfiguration]s.
abstract class MultiDayViewConfiguration extends ViewConfiguration {
  MultiDayViewConfiguration({
    int? numberOfDays,
    int? firstDayOfWeek,
    bool? paintWeekNumber,
    required double timelineWidth,
    required double daySeparatorLeftOffset,
    required Duration horizontalStepDuration,
    required Duration newEventDuration,
    required bool eventSnapping,
    required bool timeIndicatorSnapping,
    required bool createEvents,
    required bool createMultiDayEvents,
    required double multiDayTileHeight,
    required Duration verticalStepDuration,
    required Duration verticalSnapRange,
  }) {
    _numberOfDays = numberOfDays ?? 1;
    _timelineWidth = timelineWidth;
    _daySeparatorLeftOffset = daySeparatorLeftOffset;
    _horizontalStepDuration = horizontalStepDuration;
    _newEventDuration = newEventDuration;
    _eventSnapping = eventSnapping;
    _timeIndicatorSnapping = timeIndicatorSnapping;
    _createEvents = createEvents;
    _createMultiDayEvents = createMultiDayEvents;
    _multiDayTileHeight = multiDayTileHeight;
    _verticalStepDuration = verticalStepDuration;
    _verticalSnapRange = verticalSnapRange;

    _firstDayOfWeek = firstDayOfWeek ?? 1;
    _paintWeekNumber = paintWeekNumber ?? false;
  }

  /// The number of days to display.
  late int _numberOfDays;
  int get numberOfDays => _numberOfDays;
  set numberOfDays(int value) {
    _numberOfDays = value;
    notifyListeners();
  }

  /// The width of the timeline.
  late double _timelineWidth;
  double get timelineWidth => _timelineWidth;
  set timelineWidth(double value) {
    _timelineWidth = value;
    notifyListeners();
  }

  /// The overlap of the hourLines and the timeline.
  late double _daySeparatorLeftOffset;
  double get daySeparatorLeftOffset => _daySeparatorLeftOffset;
  set daySeparatorLeftOffset(double value) {
    _daySeparatorLeftOffset = value;
    notifyListeners();
  }

  /// The vertical step duration.
  late Duration _horizontalStepDuration;
  Duration get horizontalStepDuration => _horizontalStepDuration;
  set horizontalStepDuration(Duration value) {
    _horizontalStepDuration = value;
    notifyListeners();
  }

  /// The duration of a new event.
  late Duration _newEventDuration;
  Duration get newEventDuration => _newEventDuration;
  set newEventDuration(Duration value) {
    _newEventDuration = value;
    notifyListeners();
  }

  /// Paint the week number.
  late bool _paintWeekNumber;
  bool get paintWeekNumber => _paintWeekNumber;
  set paintWeekNumber(bool value) {
    _paintWeekNumber = value;
    notifyListeners();
  }

  /// The duration where the vertical drag will snap to.
  late Duration _verticalSnapRange;
  Duration get verticalSnapRange => _verticalSnapRange;
  set verticalSnapRange(Duration value) {
    _verticalSnapRange = value;
    notifyListeners();
  }

  /// Enable snapping to events.
  late bool _eventSnapping;
  bool get eventSnapping => _eventSnapping;
  set eventSnapping(bool value) {
    _eventSnapping = value;
    notifyListeners();
  }

  /// Enable snapping to the time indicator.
  late bool _timeIndicatorSnapping;
  bool get timeIndicatorSnapping => _timeIndicatorSnapping;
  set timeIndicatorSnapping(bool value) {
    _timeIndicatorSnapping = value;
    notifyListeners();
  }

  /// The first day of the week.
  late int _firstDayOfWeek;
  int get firstDayOfWeek => _firstDayOfWeek;
  set firstDayOfWeek(int value) {
    _firstDayOfWeek = value;
    notifyListeners();
  }

  /// Can create new events.
  late bool _createEvents;
  bool get createEvents => _createEvents;
  set createEvents(bool value) {
    _createEvents = value;
    notifyListeners();
  }

  /// Can create new multiDay events.
  late bool _createMultiDayEvents;
  bool get createMultiDayEvents => _createMultiDayEvents;
  set createMultiDayEvents(bool value) {
    _createMultiDayEvents = value;
    notifyListeners();
  }

  /// The height of the multiDay tiles.
  late double _multiDayTileHeight;
  double get multiDayTileHeight => _multiDayTileHeight;
  set multiDayTileHeight(double value) {
    _multiDayTileHeight = value;
    notifyListeners();
  }

  /// The duration of the vertical drag step.
  late Duration _verticalStepDuration;
  Duration get verticalStepDuration => _verticalStepDuration;
  set verticalStepDuration(Duration value) {
    _verticalStepDuration = value;
    notifyListeners();
  }
}
