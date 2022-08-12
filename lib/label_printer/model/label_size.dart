class LabelSize {
  /// Label width (mm)
  int width;

  /// Label length (mm)
  int length;

  LabelSize(this.width, this.length);

  Map<String, dynamic> toJson() => {
        'width': width,
        'length': length,
      };

  factory LabelSize.fromJson(Map<String, dynamic> json) =>
      LabelSize(json['width'], json['length']);
}
