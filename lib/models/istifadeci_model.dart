class IstifadeciModel {
  final int id;
  final String ad;
  final String email;
  final String? bio;
  final String? profilFoto;
  final double ortalamaReyting;
  final int reytingSayi;

  IstifadeciModel({
    required this.id,
    required this.ad,
    required this.email,
    this.bio,
    this.profilFoto,
    this.ortalamaReyting = 0.0,
    this.reytingSayi = 0,
  });

  factory IstifadeciModel.fromJson(Map<String, dynamic> json) {
    return IstifadeciModel(
      id: json['id'] ?? 0,
      ad: json['ad'] ?? '',
      email: json['email'] ?? json['mail'] ?? '',
      bio: json['bio'],
      profilFoto: json['profil_foto'],
      ortalamaReyting: (json['ortalama_reyting'] ?? 0.0).toDouble(),
      reytingSayi: json['reyting_sayi'] ?? 0,
    );
  }
}

class SessionData {
  final int istifadeciId;
  final String ad;
  final String mail;
  final String accessToken;

  SessionData({
    required this.istifadeciId,
    required this.ad,
    required this.mail,
    required this.accessToken,
  });
}
