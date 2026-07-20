class ApiConstants {
  // ⚠️ Render.com-a deploy etdikdən sonra bunu öz Render URL-inizlə əvəz edin.
  // Məsələn: 'https://teksat-backend.onrender.com'
  // Emulator üçün: 10.0.2.2   Real cihaz üçün: kompüterinizin lokal IP-si
  static const String baseUrl = 'https://teksat-backend-1.onrender.com';

  // WebSocket eyni server, sadəcə http→ws, https→wss
  static String get wsBaseUrl {
    if (baseUrl.startsWith('https')) return baseUrl.replaceFirst('https', 'wss');
    return baseUrl.replaceFirst('http', 'ws');
  }

  // Auth
  static const String qeydiyyat = '$baseUrl/qeydiyyat';
  static const String giris = '$baseUrl/giris';

  // Elanlar
  static const String elanlar = '$baseUrl/elanlar/';
  static const String elanDetay = '$baseUrl/teklifler/detay';

  // Teklifler
  static const String teklifVer = '$baseUrl/teklifler/ver';

  // Mesajlar
  static const String sonSohbetler = '$baseUrl/mesajlar/son-sohbetler';
  static const String sohbetTarixcesi = '$baseUrl/mesajlar/tarixce';
  static const String mesajGonder = '$baseUrl/mesajlar/gonder';

  // Profil
  static const String profil = '$baseUrl/profil';
  static const String profilYenile = '$baseUrl/profil/yenile';

  // İzləmə siyahısı (YENİ)
  static const String izleme = '$baseUrl/izleme';

  // Bildirişlər (YENİ)
  static const String bildirisler = '$baseUrl/bildirisler';

  // Reytinqlər (YENİ)
  static const String reytinqler = '$baseUrl/reytinqler';
}
