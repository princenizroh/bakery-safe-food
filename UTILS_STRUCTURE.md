# Utils Structure Documentation

## 📁 Struktur Utils yang Sudah Diperbaiki

```
lib/utils/
├── colors.dart          # Semua definisi warna aplikasi
├── fonts.dart           # Semua style font/typography
├── app_icons.dart       # Semua referensi icon yang digunakan
├── constants.dart       # Konstanta spacing, radius, sizes, dll
├── format_helper.dart   # Helper untuk format currency, date, dll
└── utils.dart          # Export semua utils (single import point)
```

## 🎨 colors.dart

Berisi semua definisi warna yang digunakan di aplikasi:

### Primary Colors
- `primary` - Warna utama aplikasi (Orange)
- `secondary` - Warna sekunder (Light Orange)
- `accent` - Warna aksen (Yellow)

### Background Colors
- `background` - Background aplikasi
- `cardBackground` - Background card/container
- `surfaceLight` - Background surface ringan

### Text Colors
- `textPrimary` - Warna text utama (gelap)
- `textSecondary` - Warna text sekunder (abu-abu)
- `textLight` - Warna text ringan
- `textWhite` - Warna text putih

### Status Colors
- `success` - Hijau untuk status berhasil
- `error` - Merah untuk status error
- `warning` - Kuning untuk warning
- `info` - Biru untuk informasi

### Other Colors
- `divider` - Warna pemisah/divider
- `border` - Warna border
- `star` - Warna bintang rating
- `discount` - Warna badge diskon

### Transparent Overlays
- `primaryLight` - Primary dengan alpha 0.1
- `secondaryLight` - Secondary dengan alpha 0.2
- `blackOverlay` - Black dengan alpha 0.5
- `whiteOverlay` - White dengan alpha 0.9

## 📝 fonts.dart

Berisi semua style typography yang digunakan:

### Heading Styles
- `h1` - 32px, Bold
- `h2` - 24px, Bold
- `h3` - 20px, Bold
- `h4` - 18px, Bold
- `h5` - 16px, Bold

### Body Text Styles
- `bodyLarge` - 16px, Normal
- `bodyMedium` - 14px, Normal
- `bodySmall` - 12px, Normal

### Caption & Label
- `caption` - 12px, Normal, Secondary color
- `captionBold` - 12px, Bold, Secondary color
- `label` - 14px, Medium weight

### Button Text
- `button` - 16px, Semi-bold
- `buttonSmall` - 14px, Semi-bold

### Special Styles
- `price` - Style untuk harga (18px, Bold, Primary)
- `priceOld` - Style untuk harga coret
- `discount` - Style untuk badge diskon
- `badge` - Style untuk badge umum

## 🎯 app_icons.dart

Berisi referensi semua icon yang digunakan, dikelompokkan berdasarkan kategori:

### Navigation Icons
- home, map, orders, profile

### Action Icons
- search, filter, logout, back, forward, close, clear

### Form Icons
- email, password, passwordShow, passwordHide, person, phone

### Content Icons
- bakery, package, location, time, star, rating

### Action Buttons
- add, remove, addCircle, removeCircle, edit, delete

### Status Icons
- check, checkCircle, error, warning, info

## 📏 constants.dart

Berisi semua konstanta yang digunakan di aplikasi:

### Spacing
- `spacingXs` - 4px
- `spacingSm` - 8px
- `spacingMd` - 16px
- `spacingLg` - 24px
- `spacingXl` - 32px
- `spacingXxl` - 48px

### Border Radius
- `radiusXs` - 4px
- `radiusSm` - 8px
- `radiusMd` - 12px
- `radiusLg` - 16px
- `radiusXl` - 24px
- `radiusCircle` - 999px

### Icon Sizes
- `iconXs` - 16px
- `iconSm` - 20px
- `iconMd` - 24px
- `iconLg` - 32px
- `iconXl` - 48px
- `iconXxl` - 64px

### Image Sizes
- `imageSmall` - 80px
- `imageMedium` - 100px
- `imageLarge` - 200px
- `imageHeight` - 200px

### Button & Input Heights
- `buttonHeightSm` - 36px
- `buttonHeightMd` - 48px
- `buttonHeightLg` - 56px
- `inputHeight` - 48px

### Animation Durations
- `animationDurationFast` - 150ms
- `animationDurationNormal` - 300ms
- `animationDurationSlow` - 500ms

### Order Status
- `orderStatusPending`
- `orderStatusConfirmed`
- `orderStatusReady`
- `orderStatusCompleted`
- `orderStatusCancelled`

## 🔧 format_helper.dart

Helper functions untuk formatting:

### Methods
- `formatCurrency(double)` - Format ke Rupiah
- `formatDistance(double)` - Format jarak (km/m)
- `formatDate(DateTime)` - Format tanggal
- `formatTime(DateTime)` - Format waktu
- `formatDateTime(DateTime)` - Format tanggal + waktu
- `getTimeFromString(String)` - Parse string waktu

## 📦 utils.dart (Barrel Export)

Single import point untuk semua utils:

```dart
import 'package:bakery/utils/utils.dart';

// Sekarang bisa akses semua:
// - AppColors
// - AppFonts
// - AppIcons
// - AppConstants
// - FormatHelper
```

## 💡 Cara Penggunaan

### Import Single File
```dart
import '../utils/colors.dart';
import '../utils/fonts.dart';
import '../utils/app_icons.dart';
```

### Atau Import Semua Sekaligus
```dart
import '../utils/utils.dart';
```

### Contoh Penggunaan

```dart
// Warna
Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: AppFonts.h1,
  ),
)

// Icon
Icon(AppIcons.home, size: AppConstants.iconMd)

// Spacing
SizedBox(height: AppConstants.spacingMd)

// Border Radius
BorderRadius.circular(AppConstants.radiusMd)

// Format
Text(FormatHelper.formatCurrency(50000))
```

## ✅ Keuntungan Struktur Ini

1. **Organized** - Semua resource di satu tempat
2. **Maintainable** - Ganti warna/font cukup 1 tempat
3. **Consistent** - Semua dev menggunakan value yang sama
4. **Autocomplete** - IDE bisa suggest semua option
5. **Type Safe** - Error saat compile bukan runtime
6. **Clean Code** - Tidak ada magic number/string
7. **Scalable** - Mudah ditambah resource baru

## 🎯 Best Practices

1. **Jangan hardcode values** - Selalu gunakan constants
2. **Gunakan semantic naming** - `primary` bukan `orange`
3. **Konsisten** - Gunakan naming convention yang sama
4. **Document** - Beri comment untuk values penting
5. **Group by category** - Kelompokkan berdasarkan fungsi

---

**Note:** Struktur ini sudah tested dengan `flutter analyze` dan tidak ada error/warning! ✅
