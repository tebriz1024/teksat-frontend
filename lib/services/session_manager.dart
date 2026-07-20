import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyId = 'istifadeci_id';
  static const _keyAd = 'ad';
  static const _keyMail = 'mail';
  static const _keyToken = 'token';

  static Future<void> saxla({
    required int id,
    required String ad,
    required String mail,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyId, id);
    await prefs.setString(_keyAd, ad);
    await prefs.setString(_keyMail, mail);
    await prefs.setString(_keyToken, token);
  }

  static Future<Map<String, dynamic>?> getir() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_keyId);
    if (id == null) return null;
    return {
      'id': id,
      'ad': prefs.getString(_keyAd) ?? '',
      'mail': prefs.getString(_keyMail) ?? '',
      'token': prefs.getString(_keyToken) ?? '',
    };
  }

  static Future<String?> tokenGetir() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> sil() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> girislidir() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyId);
  }
}
