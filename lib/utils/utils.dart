import 'dart:convert';

extension StringToBytes on String {
  List<int> toBytes() {
    return utf8.encode(this);
  }
}

int dotsToBytes(int dots) => (dots / 8).ceil();
