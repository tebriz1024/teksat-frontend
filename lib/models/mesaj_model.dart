class MesajModel {
  final int id;
  final int gonderenId;
  final int alanId;
  final String mesaj;
  final String vaxt;
  final int oxunub;

  MesajModel({
    required this.id,
    required this.gonderenId,
    required this.alanId,
    required this.mesaj,
    required this.vaxt,
    required this.oxunub,
  });

  factory MesajModel.fromJson(Map<String, dynamic> json) {
    return MesajModel(
      id: json['id'] ?? 0,
      gonderenId: json['gonderen_id'] ?? 0,
      alanId: json['alan_id'] ?? 0,
      mesaj: json['mesaj'] ?? '',
      vaxt: json['vaxt'] ?? '',
      oxunub: json['oxunub'] ?? 0,
    );
  }
}

class SohbetModel {
  final int karsiId;
  final String karsiAd;
  final String? karsiFoto;
  final String sonMesaj;
  final String vaxt;
  final bool kalinGoster;
  final int? elanId;

  SohbetModel({
    required this.karsiId,
    required this.karsiAd,
    this.karsiFoto,
    required this.sonMesaj,
    required this.vaxt,
    required this.kalinGoster,
    this.elanId,
  });

  factory SohbetModel.fromJson(Map<String, dynamic> json) {
    return SohbetModel(
      karsiId: json['karsi_id'] ?? 0,
      karsiAd: json['karsi_ad'] ?? '',
      karsiFoto: json['karsi_foto'],
      sonMesaj: json['son_mesaj'] ?? '',
      vaxt: json['vaxt'] ?? '',
      kalinGoster: json['kalin_goster'] ?? false,
      elanId: json['elan_id'],
    );
  }
}
