import 'package:flutter/material.dart';
import 'package:teksat/core/theme/app_theme.dart';

/// AdMob tam inteqrasiya olunana qədər istifadə olunan yer tutucu kart.
/// ad_service.dart-dakı bannerAdUnitId hazır olanda, bunun daxilini
/// google_mobile_ads-ın BannerAd widget-i ilə əvəz edə bilərsiniz.
class AdCard extends StatelessWidget {
  final String reklamId;
  const AdCard({super.key, required this.reklamId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.navyLight.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.campaign_outlined, color: AppTheme.navyLight, size: 32),
          const SizedBox(height: 10),
          const Text(
            'Reklam',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.navyLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            reklamId,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9,
              color: AppTheme.navyLight.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
