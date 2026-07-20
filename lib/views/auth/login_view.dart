import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/session_manager.dart';
import '../../services/socket_service.dart';
import '../home/home_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _mailCtrl = TextEditingController();
  final _sifreCtrl = TextEditingController();
  final _api = ApiService();
  bool _yuklenir = false;
  bool _sifreGorsen = false;

  Future<void> _girisEt() async {
    if (_mailCtrl.text.isEmpty || _sifreCtrl.text.isEmpty) return;
    setState(() => _yuklenir = true);
    try {
      final data = await _api.giris(_mailCtrl.text.trim(), _sifreCtrl.text);
      await SessionManager.saxla(
        id: data['id'] ?? 0,
        ad: data['istifadeci_adi'] ?? '',
        mail: data['mail'] ?? _mailCtrl.text,
        token: data['access_token'] ?? '',
      );
      SocketService().qosul(); // arxa planda WebSocket-ə qoşul
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeView()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _yuklenir = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.navyDark, AppTheme.navyMid],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text('T', style: TextStyle(color: AppTheme.white, fontSize: 36, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Xoş Gəldin',
                style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.navyDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Hesabınıza daxil olun',
                style: TextStyle(fontSize: 14, color: AppTheme.navyLight),
              ),
              const SizedBox(height: 36),
              TextField(
                controller: _mailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-poçt',
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.navyLight),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sifreCtrl,
                obscureText: !_sifreGorsen,
                decoration: InputDecoration(
                  labelText: 'Şifrə',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.navyLight),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _sifreGorsen ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.navyLight),
                    onPressed: () => setState(() => _sifreGorsen = !_sifreGorsen),
                  ),
                ),
                onSubmitted: (_) => _girisEt(),
              ),
              const SizedBox(height: 28),
              _yuklenir
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.electric))
                  : ElevatedButton(
                      onPressed: _girisEt,
                      child: const Text('Daxil ol'),
                    ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Hesabınız yoxdur?',
                      style: TextStyle(color: AppTheme.navyLight, fontSize: 14)),
                  TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegisterView())),
                    child: const Text('Qeydiyyat',
                        style: TextStyle(
                            color: AppTheme.electric,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
