import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'services/session_manager.dart';
import 'services/socket_service.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';
import 'views/onboarding/onboarding_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const TekSatApp());
}

class TekSatApp extends StatelessWidget {
  const TekSatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TekSat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashGate(),
    );
  }
}

/// Açılışda sessiya yoxlanır:
/// - İlk dəfə açılırsa → Onboarding
/// - Giriş edilibsə → Ana Səhifə (+ WebSocket qoşulur)
/// - Giriş edilməyibsə → Giriş Ekranı
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
    _yonlendir();
  }

  Future<void> _yonlendir() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final girisli = await SessionManager.girislidir();
    if (!mounted) return;

    if (!girisli) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginView()));
      return;
    }

    // Giriş edilibsə, WebSocket-ə qoşulmağa cəhd et (arxa planda, gözləmədən)
    SocketService().qosul();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeView()));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navyDark,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.navyMid, AppTheme.navyLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.electric.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 4)
                  ],
                ),
                child: const Center(
                  child: Text('T',
                      style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins')),
                ),
              ),
              const SizedBox(height: 24),
              const Text('TekSat',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.white,
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text('Azərbaycanda Açıq Hərrac',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppTheme.electricLight,
                      letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
