import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/mesaj_model.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';

class ChatDetailView extends StatefulWidget {
  final int istifadeciId;
  final int karsiId;
  final String karsiAd;
  const ChatDetailView({
    super.key,
    required this.istifadeciId,
    required this.karsiId,
    required this.karsiAd,
  });

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  List<MesajModel> _mesajlar = [];
  final _textCtrl = TextEditingController();
  final _scroll = ScrollController();
  final _api = ApiService();
  Timer? _timer;
  StreamSubscription? _socketSub;

  @override
  void initState() {
    super.initState();
    _yukle();
    // WebSocket qoşulusa dərhal, olmasa da 8 saniyədə bir "ehtiyat" yeniləmə
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => _yukle());
    _socketSub = SocketService().axin.listen((hadise) {
      if (hadise['tip'] == 'mesaj' &&
          (hadise['gonderen_id'] == widget.karsiId || hadise['alan_id'] == widget.karsiId)) {
        _yukle(); // canlı mesaj gəldi, dərhal yenilə
      }
    });
  }

  Future<void> _yukle() async {
    try {
      final list = await _api.sohbetTarixcesi(widget.karsiId);
      if (!mounted) return;
      setState(() => _mesajlar = list);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
        }
      });
    } catch (_) {}
  }

  Future<void> _gonder() async {
    final mesaj = _textCtrl.text.trim();
    if (mesaj.isEmpty) return;
    _textCtrl.clear();
    try {
      // WebSocket qoşuludursa ordan, deyilsə REST ilə göndər
      if (SocketService().qosuludur) {
        SocketService().mesajGonderSocketIle(widget.karsiId, mesaj);
      } else {
        await _api.mesajGonder(widget.karsiId, mesaj);
      }
      await _yukle();
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _socketSub?.cancel();
    _textCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.navyDark,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.electric.withOpacity(0.15),
              child: Text(
                widget.karsiAd.isNotEmpty ? widget.karsiAd[0].toUpperCase() : '?',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: AppTheme.electric,
                    fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.karsiAd),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _mesajlar.isEmpty
                ? const Center(
                    child: Text('Söhbəti siz başladın',
                        style: TextStyle(color: AppTheme.navyLight)))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _mesajlar.length,
                    itemBuilder: (_, i) {
                      final m = _mesajlar[i];
                      final menim = m.gonderenId == widget.istifadeciId;
                      return _MesajBubble(mesaj: m, menim: menim);
                    },
                  ),
          ),
          Container(
            color: AppTheme.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    decoration: InputDecoration(
                      hintText: 'Mesajınızı yazın...',
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                              const BorderSide(color: AppTheme.surfaceGrey)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                              const BorderSide(color: AppTheme.surfaceGrey)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                              const BorderSide(color: AppTheme.electric)),
                    ),
                    onSubmitted: (_) => _gonder(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _gonder,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                        color: AppTheme.electric, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded,
                        color: AppTheme.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MesajBubble extends StatelessWidget {
  final MesajModel mesaj;
  final bool menim;
  const _MesajBubble({required this.mesaj, required this.menim});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: menim ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: menim ? AppTheme.electric : AppTheme.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(menim ? 16 : 4),
            bottomRight: Radius.circular(menim ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
                color: AppTheme.navyDark.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment:
              menim ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              mesaj.mesaj,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  color: menim ? AppTheme.white : AppTheme.navyDark,
                  fontSize: 14,
                  height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              mesaj.vaxt.length > 15 ? mesaj.vaxt.substring(11, 16) : mesaj.vaxt,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: menim
                      ? AppTheme.white.withOpacity(0.7)
                      : AppTheme.navyLight),
            ),
          ],
        ),
      ),
    );
  }
}
