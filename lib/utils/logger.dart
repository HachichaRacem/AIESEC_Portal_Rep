import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Logger {
  static Future<void> log(String message) async {
    final Directory logDirectory = Platform.isWindows
        ? await getApplicationSupportDirectory()
        : (await getExternalStorageDirectories())![0];
    final DateTime date = DateTime.now();
    final String today =
        "${date.year.toString().padLeft(2, "0")}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";
    final String time =
        "${date.hour.toString().padLeft(2, "0")}:${date.minute.toString().padLeft(2, "0")}:${date.second.toString().padLeft(2, "0")}";
    await File('${logDirectory.path}/logs.txt').writeAsString(
        "[$today $time]$message\n",
        mode: FileMode.append,
        flush: true);
  }
}
