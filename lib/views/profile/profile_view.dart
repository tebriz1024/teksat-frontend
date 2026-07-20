import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../models/istifadeci_model.dart';
import '../../models/elan_model.dart';
import '../../services/api_service.dart';
import '../../services/session_manager.dart';
import '../../services/socket_service.dart';
import '../auth/login_view.dart';
import '../elan/elan_detay_view.dart';

class ProfileView extends StatefulWidget {
  final int istifadeciId;
  const ProfileView({super.key, required this.istifadeciId});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _api = ApiService();
  IstifadeciModel? _profil;
  List<ElanModel> _elanlar = [];
  bool _yuklenir = true;
  bool _ozProfilim = false;

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
    setState(() => _yuklenir = true);
    try {
      final session = await SessionManager.getir();
      final profil = await _api.profilGetir(widget.istifadeciId);
      final elanlar = await _api.istifadeciElanlar(widget.istifadeciId);
      setState(() {
        _profil = profil;
        _elanlar = elanlar;
        _ozProfilim = session?['id'] == widget.istifadeciId;
        _yuklenir = false;
      });
    } catch (_) {
      setState(() => _yuklenir = false);
    }
  }

  Future<void> _cixisEt() async {
    SocketService().ayril();
    await SessionManager.sil();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => const LoginView()), (_) => false);
  }

  void _duzelismeDialoquAc() {
    if (_profil == null) return;
    final adCtrl = TextEditingController(text: _profil!.ad);
    final bioCtrl = TextEditingController(text: _profil!.bio ?? '');
    File? yeniFoto;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Profili Düzəlt',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.navyDark)),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
                      if (picked != null) setSheetState(() => yeniFoto = File(picked.path));
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.surfaceGrey,
                      backgroundImage: yeniFoto != null ? FileImage(yeniFoto!) : null,
                      child: yeniFoto == null
                          ? const Icon(Icons.camera_alt_outlined, color: AppTheme.navyLight)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(controller: adCtrl, decoration: const InputDecoration(labelText: 'Ad')),
                const SizedBox(height: 12),
                TextField(controller: bioCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Bio')),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _api.profilYenile(adCtrl.text.trim(), bio: bioCtrl.text.trim(), foto: yeniFoto);
                      if (ctx.mounted) Navigator.pop(ctx);
                      _yukle();
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
                      }
                    }
                  },
                  child: const Text('Yadda saxla'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.istifadeciId == 0) {
      return const Scaffold(body: Center(child: Text('Giriş edilməyib')));
    }
    if (_yuklenir) {
      return const Scaffold(
        backgroundColor: AppTheme.offWhite,
        body: Center(child: CircularProgressIndicator(color: AppTheme.electric)),
      );
    }
    if (_profil == null) {
      return const Scaffold(body: Center(child: Text('Profil tapılmadı')));
    }

    final profil = _profil!;

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.white,
        title: const Text('Profil'),
        actions: [
          if (_ozProfilim)
            IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.navyMid),
              onPressed: _cixisEt,
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.electric,
        onRefresh: _yukle,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppTheme.surfaceGrey,
                backgroundImage: profil.profilFoto != null && profil.profilFoto!.startsWith('http')
                    ? NetworkImage(profil.profilFoto!)
                    : null,
                child: profil.profilFoto == null || !profil.profilFoto!.startsWith('http')
                    ? Text(profil.ad.isNotEmpty ? profil.ad[0].toUpperCase() : '?',
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 30, fontWeight: FontWeight.w700, color: AppTheme.navyDark))
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            Text(profil.ad,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.navyDark)),
            const SizedBox(height: 4),
            Text(profil.email,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.navyLight)),
            const SizedBox(height: 10),
            // Reytinq
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: AppTheme.warning, size: 20),
                const SizedBox(width: 4),
                Text(
                  profil.reytingSayi > 0
                      ? '${profil.ortalamaReyting} (${profil.reytingSayi} rəy)'
                      : 'Hələ rəy yoxdur',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.navyMid),
                ),
              ],
            ),
            if (profil.bio != null && profil.bio!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(profil.bio!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.navyMid, height: 1.5)),
            ],
            if (_ozProfilim) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _duzelismeDialoquAc,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Profili Düzəlt'),
              ),
            ],
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 12),
            Text(_ozProfilim ? 'Mənim Elanlarım' : '${profil.ad}-in Elanları',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navyDark)),
            const SizedBox(height: 14),
            if (_elanlar.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(_ozProfilim ? 'Hələ elanınız yoxdur' : 'Elan yoxdur',
                      style: const TextStyle(color: AppTheme.navyLight)),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
                ),
                itemCount: _elanlar.length,
                itemBuilder: (_, i) {
                  final e = _elanlar[i];
                  return InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ElanDetayView(elanId: e.id))),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                              child: e.foto.startsWith('http')
                                  ? Image.network(e.foto, fit: BoxFit.cover, width: double.infinity,
                                      errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceGrey))
                                  : Container(color: AppTheme.surfaceGrey,
                                      child: const Icon(Icons.image_outlined, color: AppTheme.navyLight)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.basliq, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.navyDark)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text('${e.qiymet.toStringAsFixed(0)} ₼',
                                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.electric)),
                                    const Spacer(),
                                    if (e.durum == 'deaktiv')
                                      const Text('Bitib', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
