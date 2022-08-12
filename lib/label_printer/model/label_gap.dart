class LabelGap {
  /// The gap distance between two labels 0 ≤ m ≤ 25.4 (mm)
  int m;

  /// The offset distance of the gap n ≤ label length (mm)
  int n;

  LabelGap(this.m, [this.n = 0]);

  Map<String, dynamic> toJson() => {
        'm': m,
        'n': n,
      };

  factory LabelGap.fromJson(Map<String, dynamic> json) =>
      LabelGap(json['m'], json['n']);
}
