import 'package:flutter/material.dart';
import 'package:kalender/src/enumerations.dart';
import 'package:kalender/src/models/calendar_controller.dart';
import 'package:kalender/src/models/tile_layout_controllers/multi_day_tile_layout_controller.dart';
import 'package:kalender/src/providers/calendar_internals.dart';

/// The [Stack] that contains the [MultiDayEvent] that is being modified.
class ChaningMultiDayEventStack<T extends Object?> extends StatelessWidget {
  const ChaningMultiDayEventStack({
    super.key,
    required this.multiDayEventLayout,
  });

  final MultiDayLayoutController<T> multiDayEventLayout;

  @override
  Widget build(BuildContext context) {
    CalendarController<T> controller = CalendarInternals.of<T>(context).controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) {
        if (controller.hasChaningEvent && controller.isMultidayEvent) {
          return ListenableBuilder(
            listenable: controller.chaningEvent!,
            builder: (BuildContext context, Widget? child) {
              PositionedMultiDayTileData<T> arragnedEvent = multiDayEventLayout.arrangeEvent(
                controller.chaningEvent!,
              );
              return MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: Stack(
                  children: [
                    Positioned(
                      top: arragnedEvent.top,
                      left: arragnedEvent.left,
                      width: arragnedEvent.width,
                      height: arragnedEvent.height,
                      child:
                          CalendarInternals.of<T>(context).components.multiDayEventTileBuilder.call(
                                arragnedEvent.event,
                                TileType.selected,
                                arragnedEvent.continuesBefore,
                                arragnedEvent.continuesAfter,
                              ),
                    )
                  ],
                ),
              );
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
