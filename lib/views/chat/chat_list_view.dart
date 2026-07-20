import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/mesaj_model.dart';
import '../../services/api_service.dart';
import 'chat_detail_view.dart';

class ChatListView extends StatefulWidget {
  final int istifadeciId;
  const ChatListView({super.key, required this.istifadeciId});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  List<SohbetModel> _sohbetler = [];
  bool _yuklenir = true;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    if (widget.istifadeciId == 0) {
      setState(() => _yuklenir = false);
      return;
    }
    try {
      final list = await _api.sonSohbetler();
      setState(() {
        _sohbetler = list;
        _yuklenir = false;
      });
    } catch (_) {
      setState(() => _yuklenir = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.white,
        title: const Text('Mesajlar'),
      ),
      body: _yuklenir
          ? const Center(child: CircularProgressIndicator(color: AppTheme.electric))
          : _sohbetler.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  color: AppTheme.electric,
                  onRefresh: _yukle,
                  child: ListView.builder(
                    itemCount: _sohbetler.length,
                    itemBuilder: (_, i) => _SohbetTile(
                      sohbet: _sohbetler[i],
                      istifadeciId: widget.istifadeciId,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailView(
                              istifadeciId: widget.istifadeciId,
                              karsiId: _sohbetler[i].karsiId,
                              karsiAd: _sohbetler[i].karsiAd,
                            ),
                          ),
                        );
                        _yukle();
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('💬', style: TextStyle(fontSize: 60)),
          SizedBox(height: 16),
          Text('Hələ mesajınız yoxdur',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navyDark)),
          SizedBox(height: 8),
          Text('Hərrac qazandıqda söhbət başlayacaq',
              style: TextStyle(color: AppTheme.navyLight, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SohbetTile extends StatelessWidget {
  final SohbetModel sohbet;
  final int istifadeciId;
  final VoidCallback onTap;
  const _SohbetTile(
      {required this.sohbet, required this.istifadeciId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: AppTheme.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.surfaceGrey,
              backgroundImage: sohbet.karsiFoto != null &&
                      sohbet.karsiFoto!.startsWith('http')
                  ? NetworkImage(sohbet.karsiFoto!)
                  : null,
              child: sohbet.karsiFoto == null
                  ? Text(
                      sohbet.karsiAd.isNotEmpty
                          ? sohbet.karsiAd[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          color: AppTheme.navyDark))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sohbet.karsiAd,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: sohbet.kalinGoster
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 15,
                        color: AppTheme.navyDark),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sohbet.sonMesaj,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: sohbet.kalinGoster
                            ? AppTheme.navyDark
                            : AppTheme.navyLight,
                        fontWeight: sohbet.kalinGoster
                            ? FontWeight.w600
                            : FontWeight.w400),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(sohbet.vaxt.length > 10 ? sohbet.vaxt.substring(11, 16) : sohbet.vaxt,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppTheme.navyLight)),
                if (sohbet.kalinGoster) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                        color: AppTheme.electric, shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
