library nprinters;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'printer_model.dart';

class NPrintersManager {
  NPrintersManager._();

  static final NPrintersManager _instance = NPrintersManager._();

  static NPrintersManager get instance => _instance;

  List<PrinterModel> printers = [];

  static const keyList = 'nprinters_list_printer_model';

  Future<List<PrinterModel>> loadAllPrinters() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      List<String> jsons = prefs.getStringList(keyList);
      printers.clear();
      for (var json in jsons) {
        PrinterModel printer = PrinterModel.fromJson(jsonDecode(json));
        printers.add(printer);
      }
      return printers;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveAllPrinters() async {
    final prefs = await SharedPreferences.getInstance();

    final jsons = printers.map((printer) => jsonEncode(printer)).toList();
    prefs.setStringList(keyList, jsons);
  }

  Future<void> addPrinter(PrinterModel printer) async {
    printers.add(printer);
    await saveAllPrinters();
  }

  Future<bool> removePrinter(PrinterModel printer) async {
    bool ok = printers.remove(printer);
    if (ok) {
      await saveAllPrinters();
    }
    return ok;
  }
}
