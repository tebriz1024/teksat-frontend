import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/session_manager.dart';
import '../../services/socket_service.dart';
import '../home/home_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _adCtrl = TextEditingController();
  final _mailCtrl = TextEditingController();
  final _sifreCtrl = TextEditingController();
  final _api = ApiService();
  bool _yuklenir = false;
  bool _sifreGorsen = false;

  Future<void> _qeydiyyat() async {
    if (_adCtrl.text.isEmpty || _mailCtrl.text.isEmpty || _sifreCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bütün sahələri doldurun')));
      return;
    }
    setState(() => _yuklenir = true);
    try {
      await _api.qeydiyyat(_adCtrl.text.trim(), _mailCtrl.text.trim(), _sifreCtrl.text);
      final girisData = await _api.giris(_mailCtrl.text.trim(), _sifreCtrl.text);
      await SessionManager.saxla(
        id: girisData['id'] ?? 0,
        ad: girisData['istifadeci_adi'] ?? _adCtrl.text,
        mail: girisData['mail'] ?? _mailCtrl.text,
        token: girisData['access_token'] ?? '',
      );
      SocketService().qosul();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => const HomeView()), (_) => false);
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
      appBar: AppBar(
        title: const Text('Qeydiyyat'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.navyDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Hesab yaradın',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.navyDark),
            ),
            const SizedBox(height: 6),
            const Text('TekSat-a qoşulun',
                style: TextStyle(fontSize: 14, color: AppTheme.navyLight)),
            const SizedBox(height: 32),
            TextField(
              controller: _adCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                prefixIcon: Icon(Icons.person_outline, color: AppTheme.navyLight),
              ),
            ),
            const SizedBox(height: 16),
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
            ),
            const SizedBox(height: 28),
            _yuklenir
                ? const Center(child: CircularProgressIndicator(color: AppTheme.electric))
                : ElevatedButton(
                    onPressed: _qeydiyyat,
                    child: const Text('Qeydiyyatdan keç'),
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
