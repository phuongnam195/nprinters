import '../utils/logger.dart';
import '../utils/utils.dart';

class LabelPrinterCommand {
  LabelPrinterCommand._();

  static List<int> print(int m, [int n = 1]) {
    String command = 'PRINT $m,$n\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command clears the image buffer
  static List<int> cls() {
    String command = 'CLS\n';
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
      int x, int y, int width, int height, int mode, List<int> bitmap) {
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

  /// This command defines the printout direction and mirror image. This will be stored in the printer memory
  /// [n] 0 or 1. Please refer to the illustrations in page 14, Label Formatting Commands pdf
  /// [m] 0 if print normal image, 1 if print mirror image
  static List<int> direction(int n, [int m]) {
    String command = 'DIRECTION $n' + (m != null ? ',$m' : '') + '\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command prints text on label
  /// [x] The x-coordinate of the text
  /// [y] The y-coordinate of the text
  /// [font] Font name: "0"-"8", "ROMAN.TTF"
  /// [rotation] The rotation angle of text: 0, 90, 180, 270
  /// [xMul] Horizontal multiplication, up to 10x
  /// [yMul] Vertical multiplication, up to 10x
  /// [content] Content to print, put in quotation marks
  static List<int> text(int x, int y, String font, int rotation, int xMul,
      int yMul, String content) {
    String command = 'TEXT $x,$y,"$font",$rotation,$xMul,$yMul,"$content"\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command defines the label width and length
  /// [m] Label width (mm)
  /// [n] Label length (mm)
  static List<int> size(int m, int n) {
    String command =
        'SIZE $m' + (m > 0 ? ' mm' : '') + ',$n' + (n > 0 ? ' mm' : '') + '\n';
    Logger.command(command);
    return command.toBytes();
  }

  /// This command sets the distance between two labels
  static List<int> gap(int m, int n) {
    String command =
        'GAP $m' + (m > 0 ? ' mm' : '') + ',$n' + (n > 0 ? ' mm' : '') + '\n';
    Logger.command(command);
    return command.toBytes();
  }
}
