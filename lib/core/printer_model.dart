import 'package:flutter/cupertino.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

import '../label_printer/model/direction.dart';
import '../label_printer/model/label_gap.dart';
import '../label_printer/model/label_size.dart';
import '../label_printer/model/resolution.dart';

enum PrinterType {
  label,
  pos,
}

class PrinterModel {
  int id;

  PrinterType type;
  String name;
  String host;
  int port;

  LabelSize size;
  LabelGap gap;
  Resolution resolution;
  Direction direction;

  PaperSize paperSize;
  String profile;

  PrinterModel.label({
    @required this.id,
    @required this.name,
    @required this.host,
    this.port = 9100,
    @required this.size,
    @required this.gap,
    @required this.resolution,
    this.direction = Direction.portrait,
  }) : type = PrinterType.label;

  PrinterModel.pos({
    @required this.id,
    @required this.name,
    @required this.host,
    this.port = 9100,
    this.paperSize = PaperSize.mm80,
    this.profile = 'profile',
  }) : type = PrinterType.pos;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.index,
        'name': name,
        'host': host,
        'port': port,
        'size': size?.toJson(),
        'gap': gap?.toJson(),
        'resolution': resolution?.toJson(),
        'direction': direction?.index,
        'paperSize': paperSize?.value,
        'profile': profile,
      }..removeWhere((_, value) => value == null);

  factory PrinterModel.fromJson(Map<String, dynamic> json) {
    if (json['type'] == PrinterType.label.index) {
      return PrinterModel.label(
        id: json['id'],
        name: json['name'],
        host: json['host'],
        port: json['port'],
        size: LabelSize.fromJson(json['size']),
        gap: LabelGap.fromJson(json['gap']),
        resolution: Resolution.fromJson(json['resolution']),
        direction: Direction.values.elementAt(
          json['direction'],
        ),
      );
    } else if (json['type'] == PrinterType.pos.index) {
      int paperSizeVal = json['paperSize'];
      PaperSize paperSize;
      if (paperSizeVal == PaperSize.mm58.value) {
        paperSize = PaperSize.mm58;
      } else if (paperSizeVal == PaperSize.mm72.value) {
        paperSize = PaperSize.mm72;
      } else if (paperSizeVal == PaperSize.mm80.value) {
        paperSize = PaperSize.mm80;
      }

      return PrinterModel.pos(
        id: json['id'],
        name: json['name'],
        host: json['host'],
        port: json['port'],
        paperSize: paperSize,
        profile: json['profile'],
      );
    }
    return null;
  }
}
