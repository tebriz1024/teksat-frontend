class BildirisModel {
  final int id;
  final String tip;
  final String baslik;
  final String mesaj;
  final int? elanId;
  final bool oxunub;
  final String yaranmaVaxti;

  BildirisModel({
    required this.id,
    required this.tip,
    required this.baslik,
    required this.mesaj,
    this.elanId,
    required this.oxunub,
    required this.yaranmaVaxti,
  });

  factory BildirisModel.fromJson(Map<String, dynamic> json) {
    return BildirisModel(
      id: json['id'] ?? 0,
      tip: json['tip'] ?? '',
      baslik: json['baslik'] ?? '',
      mesaj: json['mesaj'] ?? '',
      elanId: json['elan_id'],
      oxunub: json['oxunub'] ?? false,
      yaranmaVaxti: json['yaranma_vaxti'] ?? '',
    );
  }
}
