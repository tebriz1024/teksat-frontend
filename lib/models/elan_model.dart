class ElanModel {
  final int id;
  final int sahibId;
  final String basliq;
  final double qiymet;
  final String foto;
  final String bitmeVaxti;
  final int? kategoriyaId;
  final String? aciqlama;
  final String? durum;

  ElanModel({
    required this.id,
    required this.sahibId,
    required this.basliq,
    required this.qiymet,
    required this.foto,
    required this.bitmeVaxti,
    this.kategoriyaId,
    this.aciqlama,
    this.durum,
  });

  factory ElanModel.fromJson(Map<String, dynamic> json) {
    return ElanModel(
      id: json['id'] ?? 0,
      sahibId: json['sahib_id'] ?? 0,
      basliq: json['basliq'] ?? '',
      qiymet: (json['qiymet'] ?? json['baslangic_qiymeti'] ?? 0.0).toDouble(),
      foto: json['foto'] ?? json['elan_foto'] ?? '',
      bitmeVaxti: json['bitme_vaxti'] ?? '',
      kategoriyaId: json['kategoriya_id'],
      aciqlama: json['aciqlama'],
      durum: json['durum'],
    );
  }
}

class FeedItem {
  final String tip; // 'elan' və ya 'reklam'
  final ElanModel? elan;
  final String? reklamId;

  FeedItem({required this.tip, this.elan, this.reklamId});

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      tip: json['tip'],
      elan: json['tip'] == 'elan' ? ElanModel.fromJson(json['detay']) : null,
      reklamId: json['tip'] == 'reklam' ? json['reklam_id'] : null,
    );
  }
}

// Təklif modeli — DİQQƏT: maksimum_teklif HEÇ VAXT backend-dən gəlmir (gizli saxlanılır)
class TeklifModel {
  final double qiymet;
  final String vaxt;
  final String istifadeciAd;
  final int istifadeciId;

  TeklifModel({
    required this.qiymet,
    required this.vaxt,
    required this.istifadeciAd,
    required this.istifadeciId,
  });

  factory TeklifModel.fromJson(Map<String, dynamic> json) {
    return TeklifModel(
      qiymet: (json['qiymet'] ?? 0.0).toDouble(),
      vaxt: json['vaxt'] ?? '',
      istifadeciAd: json['istifadeci_ad'] ?? '',
      istifadeciId: json['istifadeci_id'] ?? 0,
    );
  }
}

class ElanDetayModel {
  final ElanModel elan;
  final List<TeklifModel> teklifler;

  ElanDetayModel({required this.elan, required this.teklifler});
}
