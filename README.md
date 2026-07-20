# TekSat Flutter Frontend v2

Bu, yeni backend-ə (v2) uyğunlaşdırılmış Flutter kodudur. `lib/` qovluğunun
tamamını köhnə layihənizin üzərinə köçürün (əvəz edin).

## ⚠️ Deploy etməzdən əvvəl MÜTLƏQ edin

`lib/core/constants/api_constants.dart` faylında:
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```
Bunu Render-ə deploy etdikdən sonra öz Render URL-inizlə əvəz edin, məsələn:
```dart
static const String baseUrl = 'https://teksat-backend.onrender.com';
```

## Nə Dəyişdi

### 🐛 Düzəldilən problemlər
- **Import bug** (`elan_card.dart`) — səhv qovluq yolu düzəldildi
- **Kateqoriya filtri artıq REAL işləyir** — əvvəllər düyməyə basanda heç nə
  dəyişmirdi, indi `_fetchFeed()` çağırılır
- **Əskik fayllar tamamlandı** — `ad_card.dart` və `profile_view.dart` heç vaxt
  yaradılmamışdı, `home_view.dart` onları import edirdi amma fayllar yox idi

### ✨ Yeni ekranlar/xüsusiyyətlər
| Ekran | Nə edir |
|---|---|
| `views/watchlist/watchlist_view.dart` | İzləmə siyahısı, sağa sürüşdürüb silmə |
| `views/notifications/notifications_view.dart` | Bildirişlər, ana səhifədəki zəng ikonundan açılır |
| `views/profile/profile_view.dart` | Profil, reytinq göstəricisi, öz elanların, düzəliş formu, çıxış |
| `services/socket_service.dart` | WebSocket — real-vaxtlı mesaj/bildiriş (əlavə paket lazım deyil, `dart:io` istifadə edir) |
| Axtarış çubuğu (`home_view.dart`) | Ana səhifədə, debounce ilə (yazdıqca 450ms sonra axtarır) |
| Auto-bid sahəsi (`elan_detay_view.dart`) | "Maksimum təklif" — sistem sizin adınıza avtomatik təklif verə bilər |

### 🔑 Auth axını dəyişdi
Token indi `SessionManager`-də saxlanılır və hər sorğuya avtomatik əlavə olunur
(`api_service.dart`-dakı `_authHeaders()`). Siz özünüz heç nə etmirsiniz —
sadəcə bilin ki, artıq `sahib_id`, `istifadeci_id` kimi sahələri metodlara
göndərmirsiniz (`elanYarat`, `teklifVer`, `mesajGonder`, `profilYenile` — bunların
imzası dəyişib, köhnə çağırışlarınız varsa xəta verəcək).

## Quraşdırma

```bash
flutter pub get
flutter run
```

Mən bu kodu compile edə bilmədim (sandbox-da pub.dev-ə şəbəkə girişi yoxdur) —
`flutter analyze` işlədib, hər hansı xəta çıxarsa mənə deyin, birgə düzəldərik.
