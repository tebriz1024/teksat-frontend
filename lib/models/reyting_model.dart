class ReytingModel {
  final int xal;
  final String? serh;
  final String tarix;
  final String verenAd;

  ReytingModel({
    required this.xal,
    this.serh,
    required this.tarix,
    required this.verenAd,
  });

  factory ReytingModel.fromJson(Map<String, dynamic> json) {
    return ReytingModel(
      xal: json['xal'] ?? 0,
      serh: json['serh'],
      tarix: json['tarix'] ?? '',
      verenAd: json['veren_ad'] ?? '',
    );
  }
}
