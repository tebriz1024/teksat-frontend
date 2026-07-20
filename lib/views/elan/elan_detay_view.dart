import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/elan_model.dart';
import '../../services/api_service.dart';
import '../../services/session_manager.dart';

class ElanDetayView extends StatefulWidget {
  final int elanId;
  const ElanDetayView({super.key, required this.elanId});

  @override
  State<ElanDetayView> createState() => _ElanDetayViewState();
}

class _ElanDetayViewState extends State<ElanDetayView> {
  ElanDetayModel? _detay;
  bool _yuklenir = true;
  bool _aciqlamGoster = false;
  bool _autoBidAcIq = false;
  bool _izlemedeVar = false;
  final _teklifCtrl = TextEditingController();
  final _maksimumCtrl = TextEditingController();
  final _api = ApiService();
  Map<String, dynamic>? _session;
  Timer? _timer;
  String _qalanVaxt = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _session = await SessionManager.getir();
    await _yukle();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _sayacYenile());
  }

  Future<void> _yukle() async {
    setState(() => _yuklenir = true);
    try {
      final d = await _api.elanDetay(widget.elanId);
      setState(() {
        _detay = d;
        _yuklenir = false;
      });
      _sayacYenile();
    } catch (_) {
      setState(() => _yuklenir = false);
    }
  }

  void _sayacYenile() {
    if (_detay == null) return;
    try {
      final bitme = DateTime.parse(_detay!.elan.bitmeVaxti);
      final qalan = bitme.difference(DateTime.now());
      if (!mounted) return;
      if (qalan.isNegative) {
        setState(() => _qalanVaxt = '⏱ Hərrac bitdi');
        _timer?.cancel();
      } else {
        final s = qalan.inSeconds % 60;
        final m = qalan.inMinutes % 60;
        final h = qalan.inHours % 24;
        final g = qalan.inDays;
        setState(() {
          _qalanVaxt = g > 0
              ? '${g}g ${h}s ${m}d ${s}sn'
              : h > 0
                  ? '${h}s ${m}d ${s}sn'
                  : '${m}d ${s}sn';
        });
      }
    } catch (_) {}
  }

  Future<void> _izlemeToggle() async {
    try {
      if (_izlemedeVar) {
        await _api.izlemedenCixar(widget.elanId);
      } else {
        await _api.izlemeyeElaveEt(widget.elanId);
      }
      setState(() => _izlemedeVar = !_izlemedeVar);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    }
  }

  Future<void> _teklifVer() async {
    final qiymetText = _teklifCtrl.text.trim();
    if (qiymetText.isEmpty) return;
    final qiymet = double.tryParse(qiymetText);
    if (qiymet == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Düzgün qiymət daxil edin')));
      return;
    }
    double? maksimum;
    if (_autoBidAcIq && _maksimumCtrl.text.trim().isNotEmpty) {
      maksimum = double.tryParse(_maksimumCtrl.text.trim());
    }

    try {
      final netice = await _api.teklifVer(widget.elanId, qiymet, maksimumTeklif: maksimum);
      _teklifCtrl.clear();
      _maksimumCtrl.clear();
      await _yukle();
      if (mounted) {
        final avtomatik = netice['avtomatik_devreye_girdi'] == true;
        final qazandiniz = netice['qazanan_id'] == _session?['id'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(qazandiniz
                ? 'Təklifiniz qəbul edildi, hazırda öndəsiniz!'
                : avtomatik
                    ? 'Təklifiniz qeydə alındı, amma başqasının auto-bid sistemi sizi keçdi.'
                    : 'Təklifiniz qəbul edildi!'),
            backgroundColor: qazandiniz ? AppTheme.success : AppTheme.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _teklifCtrl.dispose();
    _maksimumCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_yuklenir) {
      return const Scaffold(
        backgroundColor: AppTheme.white,
        body: Center(child: CircularProgressIndicator(color: AppTheme.electric)),
      );
    }

    if (_detay == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Elan tapılmadı')),
      );
    }

    final elan = _detay!.elan;
    final teklifler = _detay!.teklifler;
    final ozElanidir = elan.sahibId == _session?['id'];

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.white,
            foregroundColor: AppTheme.navyDark,
            actions: [
              if (!ozElanidir)
                IconButton(
                  icon: Icon(_izlemedeVar ? Icons.bookmark : Icons.bookmark_outline,
                      color: _izlemedeVar ? AppTheme.electric : AppTheme.navyDark),
                  onPressed: _izlemeToggle,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: elan.foto.startsWith('http')
                  ? Image.network(elan.foto, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceGrey))
                  : Container(color: AppTheme.surfaceGrey,
                      child: const Icon(Icons.image_outlined,
                          color: AppTheme.navyLight, size: 60)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(elan.basliq,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.navyDark)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.electric.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${elan.qiymet.toStringAsFixed(0)} ₼ başlanğıc',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.electric),
                        ),
                      ),
                    ],
                  ),
                  if (_qalanVaxt.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.navyDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer, color: AppTheme.electric, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _qalanVaxt,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: AppTheme.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (elan.aciqlama != null && elan.aciqlama!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => setState(() => _aciqlamGoster = !_aciqlamGoster),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Açıqlama',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.navyDark)),
                                Icon(
                                    _aciqlamGoster
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: AppTheme.navyLight),
                              ],
                            ),
                            if (_aciqlamGoster) ...[
                              const SizedBox(height: 8),
                              Text(elan.aciqlama!,
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: AppTheme.navyMid,
                                      fontSize: 14,
                                      height: 1.5)),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  if (!ozElanidir) ...[
                    const Text('Təklif ver',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.navyDark)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _teklifCtrl,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              hintText: 'Qiymətinizi yazın (₼)',
                              prefixIcon: Icon(Icons.monetization_on_outlined,
                                  color: AppTheme.navyLight),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _teklifVer,
                          style: ElevatedButton.styleFrom(minimumSize: const Size(80, 52)),
                          child: const Text('Təklif\net'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // AUTO-BID (proxy bidding) — YENİ
                    InkWell(
                      onTap: () => setState(() => _autoBidAcIq = !_autoBidAcIq),
                      child: Row(
                        children: [
                          Icon(_autoBidAcIq ? Icons.check_box : Icons.check_box_outline_blank,
                              color: AppTheme.electric, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Auto-bid: mənim adıma avtomatik təklif versin',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.navyMid),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_autoBidAcIq) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _maksimumCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: 'Maksimum nə qədərə qədər ödəyə bilərsiniz? (₼)',
                          prefixIcon: Icon(Icons.trending_up, color: AppTheme.navyLight),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Kimsə sizi keçəndə, sistem avtomatik olaraq (bu limitə qədər) sizin adınıza yeni təklif verəcək.',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppTheme.navyLight),
                      ),
                    ],
                  ] else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Bu sizin öz elanınızdır — özünüzə təklif verə bilməzsiniz.',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.navyMid),
                      ),
                    ),

                  if (teklifler.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text('Canlı Təkliflər',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.navyDark)),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: teklifler.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
                        itemBuilder: (_, i) {
                          final t = teklifler[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: i == 0
                                  ? AppTheme.electric.withOpacity(0.15)
                                  : AppTheme.surfaceGrey,
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    color: i == 0 ? AppTheme.electric : AppTheme.navyLight,
                                    fontSize: 12),
                              ),
                            ),
                            title: Text(t.istifadeciAd,
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppTheme.navyDark)),
                            subtitle: Text(t.vaxt,
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    color: AppTheme.navyLight)),
                            trailing: Text(
                              '${t.qiymet.toStringAsFixed(0)} ₼',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: i == 0 ? AppTheme.electric : AppTheme.navyMid),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
