class WatchlistItemModel {
  final int elanId;
  final String basliq;
  final double baslangicQiymeti;
  final double hazirkiQiymet;
  final String foto;
  final String bitmeVaxti;
  final String durum;

  WatchlistItemModel({
    required this.elanId,
    required this.basliq,
    required this.baslangicQiymeti,
    required this.hazirkiQiymet,
    required this.foto,
    required this.bitmeVaxti,
    required this.durum,
  });

  factory WatchlistItemModel.fromJson(Map<String, dynamic> json) {
    return WatchlistItemModel(
      elanId: json['elan_id'] ?? 0,
      basliq: json['basliq'] ?? '',
      baslangicQiymeti: (json['baslangic_qiymeti'] ?? 0.0).toDouble(),
      hazirkiQiymet: (json['hazirki_qiymet'] ?? 0.0).toDouble(),
      foto: json['foto'] ?? '',
      bitmeVaxti: json['bitme_vaxti'] ?? '',
      durum: json['durum'] ?? 'aktiv',
    );
  }
}
