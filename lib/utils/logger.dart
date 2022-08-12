// ignore_for_file: avoid_print

import '../core/print_action.dart';

class Logger {
  static void out(dynamic s) {
    if (PrintAction.enableLog) {
      print(s);
    }
  }

  static void command(String s) {
    if (PrintAction.enableLog) {
      print(' > $s');
    }
  }

  static void line() {
    if (PrintAction.enableLog) {
      print('-' * 30);
    }
  }
}
