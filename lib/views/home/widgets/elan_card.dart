import 'package:flutter/material.dart';
import 'package:teksat/core/theme/app_theme.dart';
import 'package:teksat/models/elan_model.dart';
import 'package:teksat/views/elan/elan_detay_view.dart';

class ElanCard extends StatelessWidget {
  final ElanModel elan;
  const ElanCard({super.key, required this.elan});

  String _qalanVaxt() {
    try {
      final bitme = DateTime.parse(elan.bitmeVaxti);
      final qalan = bitme.difference(DateTime.now());
      if (qalan.isNegative) return 'Bitib';
      if (qalan.inDays > 0) return '${qalan.inDays}g ${qalan.inHours % 24}s';
      if (qalan.inHours > 0) return '${qalan.inHours}s ${qalan.inMinutes % 60}d';
      return '${qalan.inMinutes}d';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final qalanVaxt = _qalanVaxt();
    final bitmib = qalanVaxt == 'Bitib';

    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => ElanDetayView(elanId: elan.id))),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: elan.foto.startsWith('http')
                    ? Image.network(elan.foto, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder())
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    elan.basliq,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.navyDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${elan.qiymet.toStringAsFixed(0)} ₼',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.electric,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 12,
                        color: bitmib ? Colors.grey : AppTheme.navyLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        qalanVaxt,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: bitmib ? Colors.grey : AppTheme.navyLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.surfaceGrey,
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppTheme.navyLight, size: 40),
      ),
    );
  }
}
