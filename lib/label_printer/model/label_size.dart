class LabelSize {
  /// Label width (mm)
  double width;

  /// Label length (mm)
  double length;

  LabelSize(this.width, this.length);

  Map<String, dynamic> toJson() => {
        'width': width,
        'length': length,
      };

  factory LabelSize.fromJson(Map<String, dynamic> json) =>
      LabelSize(json['width'], json['length']);
}
