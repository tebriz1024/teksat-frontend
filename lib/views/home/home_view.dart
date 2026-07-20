import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/elan_model.dart';
import '../../services/api_service.dart';
import '../../services/session_manager.dart';
import '../../services/socket_service.dart';
import '../auth/login_view.dart';
import '../chat/chat_list_view.dart';
import '../elan/elan_yarat_view.dart';
import '../profile/profile_view.dart';
import '../watchlist/watchlist_view.dart';
import '../notifications/notifications_view.dart';
import 'widgets/elan_card.dart';
import 'widgets/ad_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _navIndex = 0;
  int _secilenKategoriya = 0; // 0 = Hamısı
  List<FeedItem> _feed = [];
  bool _yuklenir = true;
  Map<String, dynamic>? _session;
  int _oxunmamisBildiris = 0;
  final _api = ApiService();
  final _axtarCtrl = TextEditingController();
  Timer? _axtarDebounce;
  StreamSubscription? _socketSub;

  final List<Map<String, dynamic>> _kategoriyalar = [
    {'id': 0, 'ad': 'Hamısı'},
    {'id': 1, 'ad': 'Elektronika'},
    {'id': 44, 'ad': 'Oyun'},
    {'id': 4, 'ad': 'Kolleksiya'},
    {'id': 5, 'ad': 'Nəqliyyat'},
    {'id': 49, 'ad': 'Geyim'},
    {'id': 6, 'ad': 'Mebellər'},
    {'id': 55, 'ad': 'Ev və Bağ'},
    {'id': 60, 'ad': 'İdman'},
    {'id': 65, 'ad': 'Uşaq'},
    {'id': 70, 'ad': 'Gözəllik'},
    {'id': 30, 'ad': 'Saatlar'},
    {'id': 13, 'ad': 'İmzalı'},
    {'id': 31, 'ad': 'Komikslər'},
    {'id': 32, 'ad': 'Figurlar'},
    {'id': 75, 'ad': 'Musiqi Alətləri'},
    {'id': 79, 'ad': 'Sənət'},
    {'id': 84, 'ad': 'Sikkə/Filateliya'},
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _session = await SessionManager.getir();
    if (_session == null && mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginView()));
      return;
    }
    await _fetchFeed();
    _bildirisSayiniYenile();

    // Bildiriş badge-i canlı yenilənsin deyə socket axınına qulaq asırıq
    _socketSub = SocketService().axin.listen((hadise) {
      if (hadise['tip'] == 'bildiris' && mounted) {
        setState(() => _oxunmamisBildiris++);
      }
    });
  }

  Future<void> _bildirisSayiniYenile() async {
    try {
      final say = await _api.oxunmamisBildirisSayi();
      if (mounted) setState(() => _oxunmamisBildiris = say);
    } catch (_) {}
  }

  Future<void> _fetchFeed() async {
    setState(() => _yuklenir = true);
    try {
      final feed = await _api.anaSefifeElanlar(
        kategoriyaId: _secilenKategoriya == 0 ? null : _secilenKategoriya,
        axtar: _axtarCtrl.text,
      );
      setState(() {
        _feed = feed;
        _yuklenir = false;
      });
    } catch (_) {
      setState(() => _yuklenir = false);
    }
  }

  void _axtarisDeyisdi(String deyer) {
    _axtarDebounce?.cancel();
    _axtarDebounce = Timer(const Duration(milliseconds: 450), _fetchFeed);
  }

  void _elanYarat() async {
    if (_session == null) return;
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ElanYaratView()));
    _fetchFeed();
  }

  @override
  void dispose() {
    _axtarDebounce?.cancel();
    _socketSub?.cancel();
    _axtarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
    return const Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: Center(child: CircularProgressIndicator(color: AppTheme.electric)),
    );
  }
  return Scaffold(
    backgroundColor: AppTheme.offWhite,
    body: IndexedStack(
      index: _navIndex,
      children: [
          _buildHome(),
          ChatListView(istifadeciId: _session?['id'] ?? 0),
          WatchlistView(onGeriDon: () => setState(() => _navIndex = 0)),
          ProfileView(istifadeciId: _session?['id'] ?? 0),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHome() {
    return SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            backgroundColor: AppTheme.white,
            floating: true,
            snap: true,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppTheme.navyDark, AppTheme.navyMid]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('T',
                        style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('TekSat',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.navyDark)),
              ],
            ),
            actions: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppTheme.navyMid),
                    onPressed: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const NotificationsView()));
                      _bildirisSayiniYenile();
                    },
                  ),
                  if (_oxunmamisBildiris > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: Colors.redAccent, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          _oxunmamisBildiris > 9 ? '9+' : '$_oxunmamisBildiris',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: Column(
                children: [
                  _buildAxtarisBar(),
                  _buildKategoriyaBar(),
                ],
              ),
            ),
          ),
        ],
        body: _yuklenir
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.electric))
            : RefreshIndicator(
                color: AppTheme.electric,
                onRefresh: _fetchFeed,
                child: _feed.isEmpty
                    ? _emptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: _feed.length,
                        itemBuilder: (_, i) {
                          final item = _feed[i];
                          if (item.tip == 'reklam') {
                            return AdCard(reklamId: item.reklamId ?? '');
                          }
                          return ElanCard(elan: item.elan!);
                        },
                      ),
              ),
      ),
    );
  }

  Widget _buildAxtarisBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: _axtarCtrl,
        onChanged: _axtarisDeyisdi,
        decoration: InputDecoration(
          hintText: 'Elan axtar...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.navyLight, size: 20),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: true,
          fillColor: AppTheme.surfaceGrey,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildKategoriyaBar() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _kategoriyalar.length,
        itemBuilder: (_, i) {
          final kat = _kategoriyalar[i];
          final aktiv = _secilenKategoriya == kat['id'];
          return GestureDetector(
            onTap: () {
              setState(() => _secilenKategoriya = kat['id']);
              _fetchFeed(); // ARTIQ REAL İŞLƏYİR — əvvəlki versiyada bu çağırılmırdı
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: aktiv ? AppTheme.navyDark : AppTheme.surfaceGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                kat['ad'],
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: aktiv ? AppTheme.white : AppTheme.navyMid,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: AppTheme.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Ana Səhifə'),
          _navItem(1, Icons.chat_bubble_rounded, Icons.chat_bubble_outline, 'Mesajlar'),
          _navItem(2, Icons.bookmark_rounded, Icons.bookmark_outline, 'İzləmə'),
          _navItem(3, Icons.person_rounded, Icons.person_outline, 'Profil'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData aktiv, IconData qeyriAktiv, String label) {
    final isAktiv = _navIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isAktiv ? aktiv : qeyriAktiv,
              color: isAktiv ? AppTheme.electric : AppTheme.navyLight, size: 22),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  color: isAktiv ? AppTheme.electric : AppTheme.navyLight,
                  fontWeight: isAktiv ? FontWeight.w600 : FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: _elanYarat,
      backgroundColor: AppTheme.electric,
      foregroundColor: AppTheme.white,
      elevation: 6,
      child: const Icon(Icons.add, size: 28),
    );
  }

  Widget _emptyState() {
    final axtarisAktiv = _axtarCtrl.text.isNotEmpty || _secilenKategoriya != 0;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(axtarisAktiv ? '🔍' : '🏷️', style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(axtarisAktiv ? 'Nəticə tapılmadı' : 'Hələ elan yoxdur',
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navyDark)),
          const SizedBox(height: 8),
          Text(axtarisAktiv ? 'Başqa söz və ya kateqoriya sınayın' : 'İlk elanı sən paylaş!',
              style: const TextStyle(color: AppTheme.navyLight)),
          const SizedBox(height: 24),
          if (!axtarisAktiv)
            ElevatedButton.icon(
              onPressed: _elanYarat,
              icon: const Icon(Icons.add),
              label: const Text('Elan paylaş'),
            ),
        ],
      ),
    );
  }
}
