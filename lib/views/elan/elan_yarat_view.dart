import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

class ElanYaratView extends StatefulWidget {
  const ElanYaratView({super.key});

  @override
  State<ElanYaratView> createState() => _ElanYaratViewState();
}

class _ElanYaratViewState extends State<ElanYaratView> {
  final _basliqCtrl = TextEditingController();
  final _aciqlamaCtrl = TextEditingController();
  final _qiymetCtrl = TextEditingController();
  final _api = ApiService();
  File? _foto;
  bool _yuklenir = false;
  int _secilenKategoriya = 1;
  DateTime _bitmeVaxti = DateTime.now().add(const Duration(days: 3));

  final List<Map<String, dynamic>> _kategoriyalar = [
    {'id': 1, 'ad': 'Elektronika'},
    {'id': 44, 'ad': 'Oyun'},
    {'id': 4, 'ad': 'Kolleksiya Kartları'},
    {'id': 5, 'ad': 'Nəqliyyat'},
    {'id': 49, 'ad': 'Geyim və Aksesuarlar'},
    {'id': 6, 'ad': 'Mebellər'},
    {'id': 55, 'ad': 'Ev və Bağ'},
    {'id': 60, 'ad': 'İdman və Açıq Hava'},
    {'id': 65, 'ad': 'Uşaq və Körpə Məhsulları'},
    {'id': 70, 'ad': 'Gözəllik və Sağlamlıq'},
    {'id': 13, 'ad': 'İmzalı Əşyalar'},
    {'id': 30, 'ad': 'Saatlar'},
    {'id': 31, 'ad': 'Komikslər'},
    {'id': 32, 'ad': 'Figurlar'},
    {'id': 75, 'ad': 'Musiqi Alətləri'},
    {'id': 79, 'ad': 'Sənət Əsərləri'},
    {'id': 84, 'ad': 'Sikkə və Filateliya'},
  ];

  Future<void> _fotoCek() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _foto = File(picked.path));
  }

  Future<void> _vaxtSec() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _bitmeVaxti,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.electric),
        ),
        child: child!,
      ),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_bitmeVaxti),
    );
    if (time == null) return;
    setState(() {
      _bitmeVaxti =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _elanYarat() async {
    if (_basliqCtrl.text.isEmpty || _qiymetCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Başlıq və qiyməti doldurun')));
      return;
    }
    final qiymet = double.tryParse(_qiymetCtrl.text);
    if (qiymet == null) return;

    setState(() => _yuklenir = true);
    try {
      final bitmeStr =
          '${_bitmeVaxti.year}-${_bitmeVaxti.month.toString().padLeft(2, '0')}-${_bitmeVaxti.day.toString().padLeft(2, '0')} ${_bitmeVaxti.hour.toString().padLeft(2, '0')}:${_bitmeVaxti.minute.toString().padLeft(2, '0')}:00';
      await _api.elanYarat(
        basliq: _basliqCtrl.text.trim(),
        kategoriyaId: _secilenKategoriya,
        baslangicQiymeti: qiymet,
        bitmeVaxti: bitmeStr,
        aciqlama: _aciqlamaCtrl.text.isNotEmpty ? _aciqlamaCtrl.text.trim() : null,
        foto: _foto,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Elanınız yaradıldı!'),
          backgroundColor: AppTheme.electric,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _yuklenir = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('Elan Paylaş'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.navyDark,
        elevation: 0,
        actions: [
          _yuklenir
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.electric)))
              : TextButton(
                  onPressed: _elanYarat,
                  child: const Text('Paylaş',
                      style: TextStyle(
                          color: AppTheme.electric,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _fotoCek,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceGrey, width: 2),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: _foto != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(_foto!, fit: BoxFit.cover))
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: AppTheme.navyLight, size: 48),
                          SizedBox(height: 8),
                          Text('Şəkil əlavə et',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppTheme.navyLight,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            _label('Başlıq'),
            TextField(
              controller: _basliqCtrl,
              decoration: const InputDecoration(hintText: 'Məhsulunuzu təsvir edin'),
            ),
            const SizedBox(height: 16),
            _label('Açıqlama (istəyə bağlı)'),
            TextField(
              controller: _aciqlamaCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Ətraflı məlumat...'),
            ),
            const SizedBox(height: 16),
            _label('Kateqoriya'),
            DropdownButtonFormField<int>(
              value: _secilenKategoriya,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.surfaceGrey)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.surfaceGrey)),
              ),
              items: _kategoriyalar
                  .map((k) => DropdownMenuItem<int>(value: k['id'], child: Text(k['ad'])))
                  .toList(),
              onChanged: (v) => setState(() => _secilenKategoriya = v!),
            ),
            const SizedBox(height: 16),
            _label('Başlanğıc Qiymət (₼)'),
            TextField(
              controller: _qiymetCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixIcon: Icon(Icons.monetization_on_outlined, color: AppTheme.navyLight),
              ),
            ),
            const SizedBox(height: 16),
            _label('Hərrac Bitmə Vaxtı'),
            GestureDetector(
              onTap: _vaxtSec,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceGrey, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppTheme.navyLight, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '${_bitmeVaxti.day}.${_bitmeVaxti.month}.${_bitmeVaxti.year}  ${_bitmeVaxti.hour.toString().padLeft(2, '0')}:${_bitmeVaxti.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: AppTheme.navyDark,
                          fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit_outlined, color: AppTheme.electric, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _yuklenir ? null : _elanYarat,
              child: const Text('Elanı Paylaş'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.navyMid)),
    );
  }
}
