# Setup Guide - SafeFood Application

## 📋 Prerequisites

Sebelum memulai, pastikan Anda sudah menginstall:
- Flutter SDK (versi 3.9.0 atau lebih baru)
- Android Studio atau VS Code
- Android SDK atau Xcode (untuk iOS)
- Git (optional)

## 🚀 Langkah-langkah Setup

### 1. Clone/Download Project

Jika menggunakan Git:
```bash
git clone <repository-url>
cd bakery
```

Atau download ZIP dan extract ke folder yang diinginkan.

### 2. Install Dependencies

Buka terminal di root project dan jalankan:
```bash
flutter pub get
```

Tunggu hingga semua package ter-download.

### 3. Konfigurasi Google Maps API

#### Dapatkan API Key

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Login dengan akun Google
3. Buat project baru atau pilih project yang sudah ada
4. Buka **API & Services** > **Library**
5. Cari dan enable:
   - Maps SDK for Android
   - Maps SDK for iOS (jika develop untuk iOS)
6. Buka **API & Services** > **Credentials**
7. Klik **Create Credentials** > **API Key**
8. Copy API Key yang dihasilkan

#### Konfigurasi Android

1. Buka file: `android/app/src/main/AndroidManifest.xml`
2. Cari baris:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```
3. Ganti `YOUR_GOOGLE_MAPS_API_KEY` dengan API Key Anda

#### Konfigurasi iOS (Optional)

1. Buka file: `ios/Runner/AppDelegate.swift`
2. Tambahkan di bagian import:
   ```swift
   import GoogleMaps
   ```
3. Tambahkan di fungsi `application`:
   ```swift
   GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
   ```

### 4. Konfigurasi Permission

#### Android
Permissions sudah ditambahkan di `AndroidManifest.xml`:
- INTERNET
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION

#### iOS (jika develop untuk iOS)
Tambahkan di `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location when in the background.</string>
```

### 5. Verifikasi Setup

Jalankan command berikut untuk memastikan tidak ada error:
```bash
flutter doctor
```

Pastikan semua centang hijau atau minimal Android/iOS SDK terinstall.

### 6. Run Aplikasi

#### Menggunakan Emulator/Simulator
```bash
flutter run
```

#### Menggunakan Device Fisik
1. Enable **Developer Mode** di HP
2. Enable **USB Debugging**
3. Hubungkan HP ke komputer
4. Jalankan:
   ```bash
   flutter devices
   flutter run -d <device-id>
   ```

## 🗂️ Struktur Project

```
bakery/
├── android/                 # Android native code
├── ios/                     # iOS native code
├── lib/                     # Source code Flutter
│   ├── controllers/         # Business logic controllers
│   ├── core/               # Core configurations
│   │   └── theme.dart      # App theme
│   ├── database/           # Local database
│   │   └── database_helper.dart
│   ├── models/             # Data models
│   │   ├── user_model.dart
│   │   ├── bakery_model.dart
│   │   ├── product_model.dart
│   │   └── order_model.dart
│   ├── routes/             # App routes
│   │   └── app_routes.dart
│   ├── screens/            # UI Screens
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── bakery_detail_screen.dart
│   │   ├── map_screen.dart
│   │   ├── order_confirm_screen.dart
│   │   └── my_orders_screen.dart
│   ├── services/           # Services
│   │   ├── auth_service.dart
│   │   ├── bakery_service.dart
│   │   └── order_service.dart
│   ├── utils/              # Utilities
│   │   └── format_helper.dart
│   ├── widgets/            # Reusable widgets
│   │   ├── bakery_card.dart
│   │   ├── product_card.dart
│   │   └── order_card.dart
│   └── main.dart           # Entry point
├── pubspec.yaml            # Dependencies
└── README_SAFEFOOD.md      # Documentation
```

## 🔧 Dependencies yang Digunakan

### State Management
- `provider: ^6.1.1` - State management solution

### Database
- `sqflite: ^2.3.0` - SQLite database
- `path_provider: ^2.1.1` - Path management
- `path: ^1.8.3` - File path utilities

### Maps & Location
- `google_maps_flutter: ^2.5.0` - Google Maps integration
- `geolocator: ^10.1.0` - Location services
- `geocoding: ^2.1.1` - Address geocoding

### UI & Utilities
- `intl: ^0.18.1` - Internationalization (date, currency)
- `image_picker: ^1.0.5` - Image picker
- `cached_network_image: ^3.3.0` - Network image caching
- `http: ^1.1.0` - HTTP requests
- `cupertino_icons: ^1.0.8` - iOS-style icons

## 📊 Database Schema

### Table: users
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  phone TEXT,
  role TEXT NOT NULL,
  created_at TEXT NOT NULL
)
```

### Table: bakeries
```sql
CREATE TABLE bakeries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  address TEXT NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  phone TEXT,
  image_url TEXT,
  rating REAL DEFAULT 0.0,
  opening_time TEXT,
  closing_time TEXT,
  user_id INTEGER,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id)
)
```

### Table: products
```sql
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  bakery_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  original_price REAL NOT NULL,
  discount_price REAL NOT NULL,
  quantity INTEGER NOT NULL,
  image_url TEXT,
  available_from TEXT,
  available_until TEXT,
  is_available INTEGER DEFAULT 1,
  created_at TEXT NOT NULL,
  FOREIGN KEY (bakery_id) REFERENCES bakeries (id)
)
```

### Table: orders
```sql
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  bakery_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  total_price REAL NOT NULL,
  status TEXT NOT NULL,
  pickup_time TEXT,
  order_date TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (bakery_id) REFERENCES bakeries (id),
  FOREIGN KEY (product_id) REFERENCES products (id)
)
```

## 🧪 Testing

Untuk testing dengan data dummy yang sudah tersedia:

### Test User
Anda bisa register user baru, atau akan ada data dummy yang otomatis ter-generate.

### Test Bakeries
3 bakery dummy sudah tersedia:
1. Roti Bakar 88
2. Bread & Butter
3. The French Bakery

### Test Products
4 surprise package dummy tersedia dengan berbagai harga dan diskon.

## ⚠️ Troubleshooting

### Error: Google Maps not showing
**Solusi:**
1. Pastikan API Key sudah benar
2. Enable billing di Google Cloud Console
3. Restart aplikasi

### Error: Location permission denied
**Solusi:**
1. Buka Settings > Apps > SafeFood
2. Berikan permission untuk Location
3. Restart aplikasi

### Error: Build failed
**Solusi:**
1. Jalankan `flutter clean`
2. Jalankan `flutter pub get`
3. Rebuild aplikasi

### Error: Database not initialized
**Solusi:**
1. Uninstall aplikasi dari device
2. Rebuild dan install ulang

## 📱 Build for Release

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (Mac only)
```bash
flutter build ios --release
```

## 🎨 Customization

### Mengubah Warna Theme
Edit file: `lib/core/theme.dart`
```dart
class AppColors {
  static const Color primary = Color(0xFFFF6B35); // Ubah sesuai keinginan
  static const Color secondary = Color(0xFFF7931E);
  // ...
}
```

### Mengubah Nama Aplikasi
1. **Android:** `android/app/src/main/AndroidManifest.xml`
   ```xml
   android:label="SafeFood"
   ```

2. **iOS:** `ios/Runner/Info.plist`
   ```xml
   <key>CFBundleName</key>
   <string>SafeFood</string>
   ```

### Menambah Data Dummy
Edit file: `lib/database/database_helper.dart`
Fungsi: `_insertDummyData()`

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- [SQLite Flutter](https://pub.dev/packages/sqflite)

## 🤝 Contributing

Jika ingin berkontribusi:
1. Fork repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 📄 License

MIT License - Feel free to use and modify.

---

**Happy Coding! 🚀**
