// helpers/data_time_helper.dart
import 'package:intl/intl.dart';

class DateTimeHelper {
  static String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  static String getCurrentTime() {
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm');
    return formatter.format(now);
  }

  static String getDataTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(now);
  }

  static DateTime dataTime() {
    return DateTime.now();
  }
}
