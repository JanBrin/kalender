import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final datesToTest = [
  DateTime.now(),
  // America/New_York
  DateTime(2020, 3, 8, 2), // 2020	Sunday, 8 March, 02:00	Sunday, 1 November, 02:00
  DateTime(2020, 11, 1, 2),
  DateTime(2021, 3, 14, 2), // 2021	Sunday, 14 March, 02:00	Sunday, 7 November, 02:00
  DateTime(2021, 11, 7, 2),
  DateTime(2022, 3, 13, 2), // 2022	Sunday, 13 March, 02:00	Sunday, 6 November, 02:00
  DateTime(2022, 11, 6, 2),
  DateTime(2023, 3, 12, 2), // 2023	Sunday, 12 March, 02:00	Sunday, 5 November, 02:00
  DateTime(2023, 11, 5, 2),
  DateTime(2024, 3, 10, 2), // 2024	Sunday, 10 March, 02:00	Sunday, 3 November, 02:00
  DateTime(2024, 11, 3, 2),
  DateTime(2025, 3, 9, 2), // 2025	Sunday, 9 March, 02:00	Sunday, 2 November, 02:00
  DateTime(2025, 11, 2, 2),

  // Europe/London
  DateTime(2020, 3, 29, 1), // 2020	Sunday, 29 March, 01:00	Sunday, 25 October, 02:00
  DateTime(2020, 10, 25, 2),
  DateTime(2021, 3, 28, 1), // 2021	Sunday, 28 March, 01:00	Sunday, 31 October, 02:00
  DateTime(2021, 10, 31, 2),
  DateTime(2022, 3, 27, 1), // 2022	Sunday, 27 March, 01:00	Sunday, 30 October, 02:00
  DateTime(2022, 10, 30, 2),
  DateTime(2023, 3, 26, 1), // 2023	Sunday, 26 March, 01:00	Sunday, 29 October, 02:00
  DateTime(2023, 10, 29, 2),
  DateTime(2024, 3, 31, 1), // 2024	Sunday, 31 March, 01:00	Sunday, 27 October, 02:00
  DateTime(2024, 10, 27, 2),
  DateTime(2025, 3, 30, 1), // 2025	Sunday, 30 March, 01:00	Sunday, 26 October, 02:00
  DateTime(2025, 10, 26, 2),

  // Australia/Sydney
  DateTime(2020, 4, 5, 3), // 2020 Sunday, 5 April, 03:00	Sunday, 4 October, 02:00
  DateTime(2020, 10, 4, 2),
  DateTime(2021, 4, 4, 3), // 2021 Sunday, 4 April, 03:00	Sunday, 3 October, 02:00
  DateTime(2021, 10, 3, 2),
  DateTime(2022, 4, 3, 3), // 2022 Sunday, 3 April, 03:00	Sunday, 2 October, 02:00
  DateTime(2022, 10, 2, 2),
  DateTime(2023, 4, 2, 3), // 2023 Sunday, 2 April, 03:00	Sunday, 1 October, 02:00
  DateTime(2023, 10, 1, 2),
  DateTime(2024, 4, 7, 3), // 2024 Sunday, 7 April, 03:00	Sunday, 6 October, 02:00
  DateTime(2024, 10, 6, 2),
  DateTime(2025, 4, 6, 3), // 2025 Sunday, 6 April, 03:00	Sunday, 5 October, 02:00
  DateTime(2025, 10, 5, 2),
];

void testWithTimeZones({
  required void Function(String timezone, Iterable<DateTime> testDates) body,
  List<DateTime>? dates,
}) {
  final timezone = Platform.environment['TZ'] ?? 'UTC';
  return group(timezone, () {
    final isUtc = timezone == 'UTC';
    final testDates = dates ?? (isUtc ? datesToTest.map((e) => e.toUtc()) : datesToTest);
    body(timezone, testDates);
  });
}
