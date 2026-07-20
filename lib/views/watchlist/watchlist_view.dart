import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/watchlist_model.dart';
import '../../services/api_service.dart';
import '../elan/elan_detay_view.dart';

class WatchlistView extends StatefulWidget {
  final VoidCallback? onGeriDon;
  const WatchlistView({super.key, this.onGeriDon});

  @override
  State<WatchlistView> createState() => _WatchlistViewState();
}

class _WatchlistViewState extends State<WatchlistView> {
  List<WatchlistItemModel> _siyahi = [];
  bool _yuklenir = true;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _yuklenir = true);
    try {
      final list = await _api.izlemeSiyahisi();
      setState(() {
        _siyahi = list;
        _yuklenir = false;
      });
    } catch (_) {
      setState(() => _yuklenir = false);
    }
  }

  Future<void> _cixar(int elanId) async {
    try {
      await _api.izlemedenCixar(elanId);
      _yukle();
    } catch (_) {}
  }

  String _qalanVaxt(String bitmeVaxti) {
    try {
      final bitme = DateTime.parse(bitmeVaxti);
      final qalan = bitme.difference(DateTime.now());
      if (qalan.isNegative) return 'Bitib';
      if (qalan.inDays > 0) return '${qalan.inDays}g ${qalan.inHours % 24}s qalıb';
      if (qalan.inHours > 0) return '${qalan.inHours}s ${qalan.inMinutes % 60}d qalıb';
      return '${qalan.inMinutes}d qalıb';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.white,
        title: const Text('İzləmə Siyahım'),
      ),
      body: _yuklenir
          ? const Center(child: CircularProgressIndicator(color: AppTheme.electric))
          : _siyahi.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  color: AppTheme.electric,
                  onRefresh: _yukle,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _siyahi.length,
                    itemBuilder: (_, i) {
                      final item = _siyahi[i];
                      final bitib = _qalanVaxt(item.bitmeVaxti) == 'Bitib';
                      return Dismissible(
                        key: ValueKey(item.elanId),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _cixar(item.elanId),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => ElanDetayView(elanId: item.elanId)));
                              _yukle();
                            },
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: item.foto.startsWith('http')
                                        ? Image.network(item.foto, fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceGrey))
                                        : Container(
                                            color: AppTheme.surfaceGrey,
                                            child: const Icon(Icons.image_outlined, color: AppTheme.navyLight)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.basliq,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: AppTheme.navyDark)),
                                      const SizedBox(height: 4),
                                      Text('${item.hazirkiQiymet.toStringAsFixed(0)} ₼',
                                          style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.electric,
                                              fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text(
                                        bitib ? 'Hərrac bitib' : _qalanVaxt(item.bitmeVaxti),
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11,
                                            color: bitib ? Colors.grey : AppTheme.navyLight),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppTheme.navyLight),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔖', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text('İzləmə siyahınız boşdur',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navyDark)),
          const SizedBox(height: 8),
          const Text('Bəyəndiyiniz elanları 🔖 ilə buraya əlavə edin',
              style: TextStyle(color: AppTheme.navyLight, fontSize: 13)),
          if (widget.onGeriDon != null) ...[
            const SizedBox(height: 24),
            OutlinedButton(onPressed: widget.onGeriDon, child: const Text('Elanlara bax')),
          ],
        ],
      ),
    );
  }
}
