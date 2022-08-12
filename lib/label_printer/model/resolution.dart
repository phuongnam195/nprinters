class Resolution {
  int dpi;
  int dpmm;

  Resolution(this.dpi, this.dpmm);

  factory Resolution.dpi203() => Resolution(203, 8);
  factory Resolution.dpi300() => Resolution(300, 12);
  factory Resolution.dpi600() => Resolution(600, 24);

  Map<String, dynamic> toJson() => {
        'dpi': dpi,
        'dpmm': dpmm,
      };

  factory Resolution.fromJson(Map<String, dynamic> json) =>
      Resolution(json['dpi'], json['dpmm']);
}
