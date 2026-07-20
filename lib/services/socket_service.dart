import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../core/constants/api_constants.dart';
import 'session_manager.dart';

/// Backend-dəki /ws/{istifadeci_id} ünvanına qoşulur, gələn hər hadisəni
/// (tip: 'mesaj' və ya 'bildiris') bir Stream vasitəsilə bütün tətbiqə ötürür.
///
/// DİQQƏT: dart:io-nun öz WebSocket sinifini istifadə edir — pubspec.yaml-a
/// əlavə heç bir paket (web_socket_channel və s.) əlavə etməyə EHTİYAC YOXDUR.
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  WebSocket? _socket;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  /// Digər view-lar bu axına qulaq asaraq canlı mesaj/bildiriş alır
  Stream<Map<String, dynamic>> get axin => _controller.stream;

  bool get qosuludur => _socket != null;

  Future<void> qosul() async {
    if (_socket != null) return; // artıq qoşuludur

    final session = await SessionManager.getir();
    if (session == null) return;

    final istifadeciId = session['id'];
    final token = session['token'];

    try {
      final uri = '${ApiConstants.wsBaseUrl}/ws/$istifadeciId?token=$token';
      _socket = await WebSocket.connect(uri);

      _socket!.listen(
        (xam) {
          try {
            final decoded = jsonDecode(xam) as Map<String, dynamic>;
            _controller.add(decoded);
          } catch (_) {
            // JSON deyilsə sadəcə görməzdən gəlirik
          }
        },
        onDone: () {
          _socket = null;
          // Bağlantı qopanda 5 saniyə sonra avtomatik yenidən cəhd et
          Future.delayed(const Duration(seconds: 5), qosul);
        },
        onError: (_) {
          _socket = null;
        },
        cancelOnError: true,
      );
    } catch (_) {
      _socket = null; // server hələ açıq deyilsə səssizcə uğursuz olur
    }
  }

  /// REST-ə alternativ olaraq, socket üzərindən birbaşa mesaj göndərmək
  void mesajGonderSocketIle(int alanId, String mesajMetni, {int? elanId}) {
    _socket?.add(jsonEncode({
      'alan_id': alanId,
      'elan_id': elanId,
      'mesaj_metni': mesajMetni,
    }));
  }

  void ayril() {
    _socket?.close();
    _socket = null;
  }
}
