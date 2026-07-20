import 'package:flutter/material.dart';
import '../auth/login_view.dart';
import '../../core/theme/app_theme.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _ctrl = PageController();
  int _current = 0;

  final List<_OnboardPage> _pages = [
    _OnboardPage(
      emoji: '🏷️',
      basliq: 'TekSat-a Xoş Gəldin!',
      aciqlama:
          'Azərbaycanda ilk açıq artırma platforması. Əşyalarını sat, ən yaxşı qiyməti tap.',
    ),
    _OnboardPage(
      emoji: '⏱️',
      basliq: 'Canlı Hərrac',
      aciqlama:
          'Elanına vaxt müəyyən et. Vaxt bitənə qədər gələn ən yüksək təklif sahibi qazanır.',
    ),
    _OnboardPage(
      emoji: '💬',
      basliq: 'Birbaşa Mesajlaş',
      aciqlama:
          'Hərrac bitdikdən sonra alıcı ilə birbaşa söhbət et, razılaş, çatdır.',
    ),
  ];

  void _next() {
    if (_current < _pages.length - 1) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) => _PageContent(page: _pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _current ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _current ? AppTheme.electric : AppTheme.surfaceGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(_current == _pages.length - 1 ? 'Başlayaq' : 'Növbəti'),
              ),
            ),
            if (_current < _pages.length - 1)
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const LoginView())),
                child: const Text('Keç',
                    style: TextStyle(color: AppTheme.navyLight, fontSize: 14)),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final String emoji;
  final String basliq;
  final String aciqlama;
  const _OnboardPage(
      {required this.emoji, required this.basliq, required this.aciqlama});
}

class _PageContent extends StatelessWidget {
  final _OnboardPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(page.emoji, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 32),
          Text(
            page.basliq,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.navyDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.aciqlama,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              color: AppTheme.navyLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
