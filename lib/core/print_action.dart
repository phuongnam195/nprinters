import 'dart:ui' as ui;

import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:image/image.dart';

import 'printer_model.dart';
import '../label_printer/label_printer_command.dart';
import '../label_printer/model/direction.dart';
import '../utils/logger.dart';
import '../utils/utils.dart';

class PrintAction {
  PrinterModel model;
  static bool enableLog = false;

  PrintAction(this.model, {bool showLog = false}) {
    enableLog = showLog;
  }

  Future<List<int>> text(String text) async {
    if (model.type == PrinterType.label) {
      return _textLabel(text);
    } else if (model.type == PrinterType.pos) {
      return _textPos(text);
    }
    return [];
  }

  Future<List<int>> image(Image image, {bool isFlip = false, double colorThreshold = 0.8}) async {
    if (model.type == PrinterType.label) {
      return _imageLabel(image, isFlip, colorThreshold);
    } else if (model.type == PrinterType.pos) {
      return _imagePos(image);
    }
    return [];
  }

  Future<List<int>> _textLabel(String text) async {
    Logger.line();
    Logger.out('Print TEXT with label printer');
    List<int> bytes = [];
    bytes += LabelPrinterCommand.size(model.size.width, model.size.length);
    bytes += LabelPrinterCommand.gap(model.gap.m, model.gap.n);
    bytes += LabelPrinterCommand.cls();
    bytes += LabelPrinterCommand.text(10, 10, content: text);
    bytes += LabelPrinterCommand.print(1, 1);
    Logger.line();
    return bytes;
  }

  Future<List<int>> _textPos(String text) async {
    final profile = await CapabilityProfile.load(name: model.profile);
    final generator = Generator(model.paperSize, profile);
    List<int> bytes = [];
    bytes += generator.text(text);
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> _imageLabel(Image image, bool isFlip, double colorThreshold) async {
    if (model.direction == Direction.landscape) {
      image = copyRotate(image, 90);
    }
    Logger.line();
    Logger.out('Print IMAGE (${image.width} x ${image.height}) with label printer');
    List<int> bytes = [];
    bytes += LabelPrinterCommand.cls();
    bytes += LabelPrinterCommand.speed(5);
    bytes += LabelPrinterCommand.size(model.size.width, model.size.length);
    bytes += LabelPrinterCommand.gap(model.gap.m, model.gap.n);
    bytes += LabelPrinterCommand.direction(1);

    double labelWidth = model.size.width * model.resolution.dpmm;

    int fullWidth = (labelWidth ~/ 8) * 8;
    int fullHeight = (image.height * fullWidth) ~/ image.width;
    image = copyResize(image, width: fullWidth, height: fullHeight);

    if (isFlip) {
      flip(image, Flip.horizontal);
    }

    List<int> bitmap = [];

    for (int i = 0; i < image.height; i++) {
      for (int j = 0; j < dotsToBytes(image.width); j++) {
        int bit = 0;
        for (int k = 0; k < 8; k++) {
          int x = j * 8 + k;
          int y = i;
          int pixel = image.getPixel(x, y);
          final color = ui.Color(pixel);

          int newColor = 1;
          if ((0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255 < colorThreshold) {
            newColor = 0;
          }
          bit = (bit << 1) ^ newColor;
        }
        bitmap.add(bit);
      }
    }

    bytes += LabelPrinterCommand.bitmap(
      0,
      0,
      width: dotsToBytes(image.width),
      height: image.height,
      bitmap: bitmap,
    );

    bytes += LabelPrinterCommand.print(1);

    Logger.line();
    return bytes;
  }

  Future<List<int>> _imagePos(Image image) async {
    int width = model.paperSize.width;
    int height = width * image.height ~/ image.width;
    image = copyResize(image, width: width, height: height);

    final profile = await CapabilityProfile.load(name: model.profile);
    final generator = Generator(model.paperSize, profile);
    List<int> bytes = [];
    bytes += generator.image(image);
    bytes += generator.cut();
    return bytes;
  }
}
