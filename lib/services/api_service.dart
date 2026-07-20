import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/elan_model.dart';
import '../models/istifadeci_model.dart';
import '../models/mesaj_model.dart';
import '../models/watchlist_model.dart';
import '../models/bildiris_model.dart';
import '../models/reyting_model.dart';
import 'session_manager.dart';

class ApiService {
  // ─── KÖMƏKÇI: hər qorunan sorğuya token əlavə edir ──────────────────────────
  Future<Map<String, String>> _authHeaders() async {
    final token = await SessionManager.tokenGetir();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ─── AUTH ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> qeydiyyat(String ad, String email, String sifre) async {
    final res = await http.post(
      Uri.parse(ApiConstants.qeydiyyat),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ad': ad, 'email': email, 'sifre': sifre}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> giris(String mail, String sifre) async {
    final res = await http.post(
      Uri.parse(ApiConstants.giris),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mail': mail, 'sifre': sifre}),
    );
    return _handle(res);
  }

  // ─── ELANLAR ─────────────────────────────────────────────────────────────────

  Future<List<FeedItem>> anaSefifeElanlar({int? kategoriyaId, String? axtar}) async {
    final params = <String, String>{};
    if (kategoriyaId != null && kategoriyaId != 0) {
      params['kateqoriya_id'] = kategoriyaId.toString();
    }
    if (axtar != null && axtar.trim().isNotEmpty) {
      params['axtar'] = axtar.trim();
    }
    final uri = Uri.parse(ApiConstants.elanlar)
        .replace(queryParameters: params.isEmpty ? null : params);
    final res = await http.get(uri);
    final data = _handle(res);
    final list = data['elanlar'] as List;
    return list.map((e) => FeedItem.fromJson(e)).toList();
  }

  Future<ElanDetayModel> elanDetay(int elanId) async {
    final res = await http.get(Uri.parse('${ApiConstants.elanDetay}/$elanId'));
    final data = _handle(res);
    final elan = ElanModel.fromJson(data['elan']);
    final teklifler = (data['teklifler_tablosu'] as List)
        .map((t) => TeklifModel.fromJson(t))
        .toList();
    return ElanDetayModel(elan: elan, teklifler: teklifler);
  }

  // DİQQƏT: 'sahibId' artıq lazım deyil — server bunu tokendən bilir
  Future<Map<String, dynamic>> elanYarat({
    required String basliq,
    required int kategoriyaId,
    required double baslangicQiymeti,
    required String bitmeVaxti,
    String? aciqlama,
    File? foto,
  }) async {
    final headers = await _authHeaders();
    final req = http.MultipartRequest('POST', Uri.parse(ApiConstants.elanlar));
    if (headers['Authorization'] != null) {
      req.headers['Authorization'] = headers['Authorization']!;
    }
    req.fields['basliq'] = basliq;
    req.fields['kategoriya_id'] = kategoriyaId.toString();
    req.fields['baslangic_qiymeti'] = baslangicQiymeti.toString();
    req.fields['bitme_vaxti'] = bitmeVaxti;
    if (aciqlama != null) req.fields['aciqlama'] = aciqlama;
    if (foto != null) {
      req.files.add(await http.MultipartFile.fromPath('file', foto.path));
    }
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  // DİQQƏT: 'istifadeciId' artıq lazım deyil, 'maksimumTeklif' YENİ (auto-bid üçün)
  Future<Map<String, dynamic>> teklifVer(int elanId, double qiymet, {double? maksimumTeklif}) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.teklifVer),
      headers: headers,
      body: jsonEncode({
        'elan_id': elanId,
        'teklif_qiymeti': qiymet,
        if (maksimumTeklif != null) 'maksimum_teklif': maksimumTeklif,
      }),
    );
    return _handle(res);
  }

  // ─── İZLƏMƏ SİYAHISI (YENİ) ──────────────────────────────────────────────────

  Future<void> izlemeyeElaveEt(int elanId) async {
    final headers = await _authHeaders();
    final res = await http.post(Uri.parse('${ApiConstants.izleme}/$elanId'), headers: headers);
    _handle(res);
  }

  Future<void> izlemedenCixar(int elanId) async {
    final headers = await _authHeaders();
    final res = await http.delete(Uri.parse('${ApiConstants.izleme}/$elanId'), headers: headers);
    _handle(res);
  }

  Future<List<WatchlistItemModel>> izlemeSiyahisi() async {
    final headers = await _authHeaders();
    final res = await http.get(Uri.parse('${ApiConstants.izleme}/'), headers: headers);
    final data = _handle(res);
    return (data['izleme_siyahisi'] as List)
        .map((w) => WatchlistItemModel.fromJson(w))
        .toList();
  }

  // ─── BİLDİRİŞLƏR (YENİ) ──────────────────────────────────────────────────────

  Future<List<BildirisModel>> bildirisleriGetir({bool yalnizOxunmamis = false}) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('${ApiConstants.bildirisler}/').replace(
        queryParameters: yalnizOxunmamis ? {'yalniz_oxunmamis': 'true'} : null);
    final res = await http.get(uri, headers: headers);
    final data = _handle(res);
    return (data['bildirisler'] as List).map((b) => BildirisModel.fromJson(b)).toList();
  }

  Future<void> bildirisOxunduIsarele(int bildirisId) async {
    final headers = await _authHeaders();
    await http.post(Uri.parse('${ApiConstants.bildirisler}/$bildirisId/oxundu'), headers: headers);
  }

  Future<int> oxunmamisBildirisSayi() async {
    final headers = await _authHeaders();
    final res = await http.get(Uri.parse('${ApiConstants.bildirisler}/sayi'), headers: headers);
    final data = _handle(res);
    return data['oxunmamis_sayi'] ?? 0;
  }

  // ─── REYTİNQLƏR (YENİ) ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> reytingVer({
    required int elanId,
    required int alinanId,
    required int xal,
    String? serh,
  }) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse('${ApiConstants.reytinqler}/'),
      headers: headers,
      body: jsonEncode({'elan_id': elanId, 'alinan_id': alinanId, 'xal': xal, 'serh': serh}),
    );
    return _handle(res);
  }

  Future<List<ReytingModel>> istifadeciReytingleri(int istifadeciId) async {
    final res = await http.get(Uri.parse('${ApiConstants.reytinqler}/istifadeci/$istifadeciId'));
    final data = _handle(res);
    return (data['reytingler'] as List).map((r) => ReytingModel.fromJson(r)).toList();
  }

  // ─── MESAJLAR ────────────────────────────────────────────────────────────────
  // DİQQƏT: artıq path-də istifadəçi ID-si yoxdur, token bunu daşıyır

  Future<List<SohbetModel>> sonSohbetler() async {
    final headers = await _authHeaders();
    final res = await http.get(Uri.parse(ApiConstants.sonSohbetler), headers: headers);
    final data = _handle(res);
    return (data['sohbetler'] as List).map((s) => SohbetModel.fromJson(s)).toList();
  }

  Future<List<MesajModel>> sohbetTarixcesi(int karsiId) async {
    final headers = await _authHeaders();
    final res = await http.get(
        Uri.parse('${ApiConstants.sohbetTarixcesi}/$karsiId'), headers: headers);
    final data = _handle(res);
    return (data['mesajlar'] as List).map((m) => MesajModel.fromJson(m)).toList();
  }

  Future<Map<String, dynamic>> mesajGonder(int alanId, String mesaj, {int? elanId}) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse(ApiConstants.mesajGonder),
      headers: headers,
      body: jsonEncode({'alan_id': alanId, 'elan_id': elanId, 'mesaj_metni': mesaj}),
    );
    return _handle(res);
  }

  // ─── PROFİL ──────────────────────────────────────────────────────────────────

  Future<IstifadeciModel> profilGetir(int istifadeciId) async {
    final res = await http.get(Uri.parse('${ApiConstants.profil}/$istifadeciId'));
    return IstifadeciModel.fromJson(_handle(res));
  }

  // DİQQƏT: artıq 'istifadeciId' lazım deyil — yalnız öz profilini yeniləyə bilər
  Future<Map<String, dynamic>> profilYenile(String ad, {String? bio, File? foto}) async {
    final headers = await _authHeaders();
    final req = http.MultipartRequest('POST', Uri.parse(ApiConstants.profilYenile));
    if (headers['Authorization'] != null) {
      req.headers['Authorization'] = headers['Authorization']!;
    }
    req.fields['ad'] = ad;
    if (bio != null) req.fields['bio'] = bio;
    if (foto != null) {
      req.files.add(await http.MultipartFile.fromPath('file', foto.path));
    }
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  Future<List<ElanModel>> istifadeciElanlar(int istifadeciId) async {
    final res = await http.get(Uri.parse('${ApiConstants.profil}/$istifadeciId/elanlar'));
    final data = _handle(res);
    return (data['elanlar'] as List).map((e) => ElanModel.fromJson(e)).toList();
  }

  // ─── KÖMƏKÇI ─────────────────────────────────────────────────────────────────

  Map<String, dynamic> _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(utf8.decode(res.bodyBytes));
    }
    final err = jsonDecode(utf8.decode(res.bodyBytes));
    throw Exception(err['detail'] ?? 'Server xətası (${res.statusCode})');
  }
}
