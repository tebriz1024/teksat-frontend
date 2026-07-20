import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/bildiris_model.dart';
import '../../services/api_service.dart';
import '../elan/elan_detay_view.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<BildirisModel> _bildirisler = [];
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
      final list = await _api.bildirisleriGetir();
      setState(() {
        _bildirisler = list;
        _yuklenir = false;
      });
    } catch (_) {
      setState(() => _yuklenir = false);
    }
  }

  IconData _ikon(String tip) {
    switch (tip) {
      case 'outbid':
        return Icons.trending_up;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        title: const Text('Bildirişlər'),
      ),
      body: _yuklenir
          ? const Center(child: CircularProgressIndicator(color: AppTheme.electric))
          : _bildirisler.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  color: AppTheme.electric,
                  onRefresh: _yukle,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bildirisler.length,
                    itemBuilder: (_, i) {
                      final b = _bildirisler[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: b.oxunub ? AppTheme.white : AppTheme.electric.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: InkWell(
                          onTap: () async {
                            if (!b.oxunub) {
                              await _api.bildirisOxunduIsarele(b.id);
                            }
                            if (b.elanId != null && mounted) {
                              await Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => ElanDetayView(elanId: b.elanId!)));
                            }
                            _yukle();
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.electric.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_ikon(b.tip), color: AppTheme.electric, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(b.baslik,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: b.oxunub ? FontWeight.w500 : FontWeight.w700,
                                            fontSize: 14,
                                            color: AppTheme.navyDark)),
                                    const SizedBox(height: 4),
                                    Text(b.mesaj,
                                        style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            color: AppTheme.navyMid,
                                            height: 1.4)),
                                    const SizedBox(height: 6),
                                    Text(
                                      b.yaranmaVaxti.length > 16
                                          ? b.yaranmaVaxti.substring(0, 16)
                                          : b.yaranmaVaxti,
                                      style: const TextStyle(
                                          fontFamily: 'Poppins', fontSize: 10, color: AppTheme.navyLight),
                                    ),
                                  ],
                                ),
                              ),
                              if (!b.oxunub)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      color: AppTheme.electric, shape: BoxShape.circle),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔔', style: TextStyle(fontSize: 60)),
          SizedBox(height: 16),
          Text('Hələ bildirişiniz yoxdur',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navyDark)),
          SizedBox(height: 8),
          Text('Kimsə sizi ötəndə burada görəcəksiniz',
              style: TextStyle(color: AppTheme.navyLight, fontSize: 13)),
        ],
      ),
    );
  }
}
