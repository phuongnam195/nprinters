import 'dart:convert';
import 'dart:ui' as ui;

import 'package:image/image.dart';
import 'package:flutter/foundation.dart';

import '../utils/logger.dart';
import '../utils/utils.dart';

class TsplCommand {
  TsplCommand._();

  static List<int> print(int m, [int n = 1]) {
    String command = 'PRINT $m,$n\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command defines the print speed
  static List<int> speed(int n) {
    String command = 'SPEED $n\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command clears the image buffer
  static List<int> cls() {
    String command = 'CLS\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command defines the label width and length
  /// [m] Label width (mm)
  /// [n] Label length (mm)
  static List<int> size(double m, double n) {
    String command = 'SIZE $m' + (m > 0 ? ' mm' : '') + ',$n' + (n > 0 ? ' mm' : '') + '\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command sets the distance between two labels
  static List<int> gap(double m, double n) {
    String command = 'GAP $m' + (m > 0 ? ' mm' : '') + ',$n' + (n > 0 ? ' mm' : '') + '\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command defines the printout direction and mirror image. This will be stored in the printer memory
  /// [n] 0 or 1. Please refer to the illustrations in page 14, Label Formatting Commands pdf
  /// [m] 0 if print normal image, 1 if print mirror image
  static List<int> direction(int n, [int m]) {
    String command = 'DIRECTION $n' + (m != null ? ',$m' : '') + '\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command draws bitmap images (as opposed to BMP graphic files).
  /// [x] Specify the x-coordinate
  /// [y] Specify the y-coordinate
  /// [width] Image width (bytes)
  /// [height] Image height (dots)
  /// [mode] Graphic modes listed below (0 = OVERWRITE, 1 = OR, 2 = XOR)
  /// [bitmap] Bitmap data
  static List<int> bitmap(
    int x,
    int y, {
    @required int width,
    @required int height,
    int mode = 0,
    @required List<int> bitmap,
  }) {
    String command = 'BITMAP $x,$y,$width,$height,$mode,';
    List<int> bytes = command.toBytes();
    bytes += bitmap;
    bytes += '\n'.toBytes();
    if (bitmap.length >= 64) {
      Logger.command(command + '[${bitmap.length} bytes]');
    } else {
      String str = command + '[';
      str += '${bitmap[0]}';
      bitmap.forEach((b) {
        str += ',$b';
      });
      str += ']';
      Logger.command(str);
    }
    return bytes;
  }

  static List<int> image(
    int x,
    int y, {
    int width,
    int height,
    @required Image image,
    int rotation = 0,
  }) {
    if (rotation != 0) {
      image = copyRotate(image, rotation, interpolation: Interpolation.linear);
    }

    int expectWidth = width ?? image.width;
    int expectHeight = height ?? image.height;

    int actualWidth = (expectWidth ~/ 8) * 8;
    int actualHeight = (expectHeight * actualWidth) ~/ expectWidth;

    image = copyResize(image, width: actualWidth, height: actualHeight);

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
          if ((0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255 < 0.4) {
            newColor = 0;
          }
          bit = (bit << 1) ^ newColor;
        }
        bitmap.add(bit);
      }
    }

    return TsplCommand.bitmap(
      x,
      y,
      width: dotsToBytes(image.width),
      height: image.height,
      bitmap: bitmap,
    );
  }

  /// This command prints text on label
  /// [x] The x-coordinate of the text
  /// [y] The y-coordinate of the text
  /// [font] Font name: "0"-"8", "ROMAN.TTF"
  /// [rotation] The rotation angle of text: 0, 90, 180, 270
  /// [xMul] Horizontal multiplication, up to 10x
  /// [yMul] Vertical multiplication, up to 10x
  /// [content] Content to print, put in quotation marks
  static List<int> text(
    dynamic x,
    dynamic y, {
    String font = '3',
    int rotation = 0,
    int xMul = 1,
    int yMul = 1,
    @required String content,
  }) {
    String command = 'TEXT $x,$y,"$font",$rotation,$xMul,$yMul,"$content"\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command prints paragraph on label
  /// [x] The x-coordinate of the text
  /// [y] The y-coordinate of the text
  /// [width] The width of block for the paragraph in dots
  /// [height] The height of block for the paragraph in dots
  /// [font] Font name
  /// [rotation] The rotation angle of text: 0, 90, 180, 270
  /// [xMul] Horizontal multiplication, up to 10x
  /// [yMul] Vertical multiplication, up to 10x
  /// [space] Add or delete the space between lines (in dots)
  /// [align] 0: default (left), 1: left, 2: center, 3: right
  /// [fit] 0: default (no shrink), 1: shrink
  /// [content] Data in block. The maximum data length is 4092 bytes.
  static List<int> block(
    dynamic x,
    dynamic y, {
    @required dynamic width,
    @required dynamic height,
    String font = '3',
    int rotation = 0,
    int xMul = 1,
    int yMul = 1,
    int space,
    int align = 0,
    int fit = 0,
    @required String content,
  }) {
    String command =
        'BLOCK $x,$y,$width,$height,"$font",$rotation,$xMul,$yMul,${space != null ? '$space,' : ''}${align != null ? '$align,' : ''}${fit != null ? '$fit,' : ''}"$content"\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command prints barcode on label
  /// [x] The x-coordinate of the barcode
  /// [y] The y-coordinate of the barcode
  /// [eccLevel] Error correction level: L, M, Q, H
  /// [cellWidth] Cell width: 1~10
  /// [mode] Auto / manual encode: A, M
  /// [rotation] Rotation angle: 0, 90, 180, 270
  /// [model] M1: original version, M2: enhanced version
  /// [mask] S0~S8, default is S7
  /// [content] The encodable character set
  static List<int> qrCode(
    int x,
    int y, {
    String eccLevel = 'H',
    int cellWidth = 5,
    String mode = 'A',
    int rotation = 0,
    String model = 'M2',
    String mask = 'S7',
    @required String content,
  }) {
    String command = 'QRCODE $x,$y,$eccLevel,$cellWidth,$mode,$rotation,${model == 'M2' ? 'M2,' : ''}"$content"\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command prints barcode on label
  /// [x] The x-coordinate of the barcode
  /// [y] The y-coordinate of the barcode
  /// [codeType] Code type: 128, 128M, 39, 93,...
  /// [height] Barcode height
  /// [humanReadable] 0: not readable, 1: readable (left), 2: readable (center), 3: readable (right)
  /// [rotation] Rotation angle: 0, 90, 180, 270
  /// [narrow] Width of narrow element (in dots)
  /// [wide] Width of wide element (in dots)
  /// [alignment] 0: default (left), 1: left, 2: center, 3: right
  /// [content] Content of barcode
  static List<int> barcode(
    int x,
    int y, {
    @required String codeType,
    @required int height,
    int humanReadable = 0,
    int rotation = 0,
    int narrow = 2,
    int wide = 2,
    int alignment = 0,
    @required String content,
  }) {
    String utf8Content = utf8.decode(utf8.encode(content));
    String command =
        'BARCODE $x,$y,"$codeType",$height,$humanReadable,$rotation,$narrow,$wide,$alignment,"$utf8Content"\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command draws a bar on the label format
  /// [x] The upper left corner x-coordinate (in dots)
  /// [y] The upper left corner y-coordinate (in dots)
  /// [width] Bar width (in dots)
  /// [height] Bar height (in dots)
  static List<int> bar(int x, int y, {int width, int height}) {
    String command = 'BAR $x,$y,$width,$height\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command draws rectangles on the label
  /// [x] Specify x-coordinate of upper left corner (in dots)
  /// [y] Specify y-coordinate of upper left corner (in dots)
  /// [xEnd] Specify x-coordinate of lower right corner (in dots)
  /// [yEnd] Specify y-coordinate of lower right corner (in dots)
  /// [thickness] Line thickness (in dots)
  /// [radius] Optional. Specify the round corner. Default is 0.
  static List<int> box(
    int x,
    int y,
    int xEnd,
    int yEnd, {
    int thickness = 1,
    int radius = 0,
  }) {
    String command = 'BOX $x,$y,$xEnd,$yEnd,$thickness';
    if (radius > 0) {
      command += ',$radius';
    }
    command += '\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command defines the code page of international character set.
  /// [n] Name or number of code page, which can be divided into 7-bit code page and 8-bit code page
  static List<int> codePage([String n = 'UTF-8']) {
    String command = 'CODEPAGE $n\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// Returns the width of barcode in dot
  /// [variableName] Variable name 
  /// [content]  Barcode content
  /// [codeType] Barcode type
  /// [name] Barcode type
  /// [narrow] The width of narrow bar
  /// [wide] The width of wide bar
  static List<int> barcodePixel({
    @required String variableName,
    @required String content,
    @required String codeType,
    @required int narrow,
    @required int wide,
  }) {
    String command = '$variableName=BARCODEPIXEL("$content","$codeType",$narrow,$wide)\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// Download a program file or a data file
  /// [fileName] File name
  /// [n] Optional. F: to main board flash memory, E: to expansion memory module
  /// [dataSize] For data file. The size of data to download
  /// [dataContent] For data file. The content of data to download
  static List<int> download(String fileName, {String n, int dataSize, List<int> dataContent}) {
    String command = 'DOWNLOAD ${n != null ? '$n,' : ''}"$fileName"';
    if (dataSize != null && dataContent != null) {
      command += ',$dataSize,';
      List<int> bytes = command.toBytes() + dataContent;
      Logger.command(command + '[${dataContent[0]},${dataContent[1]},...${dataContent[dataContent.length - 1]}]');
      return bytes;
    }
    Logger.command(command);
    return command.toBytes();
  }
}
