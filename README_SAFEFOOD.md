# SafeFood - Aplikasi Penyelamat Food Waste

Aplikasi SafeFood adalah solusi untuk menghubungkan bakery modern dengan konsumen, dimana produk sisa harian dijual dalam bentuk surprise package (isi acak) dengan harga lebih murah.

## Konsep Aplikasi

**Masalah yang Diselesaikan:**
- Bakery: Mengurangi kerugian akibat food waste dan biaya produksi
- Konsumen: Mendapatkan produk premium dengan harga terjangkau
- Lingkungan: Mengurangi limbah makanan dan mendukung sustainability

**Fitur Utama:**
- 🔐 Sistem autentikasi (Register & Login) dengan database lokal
- 🏠 Home screen dengan daftar bakery terdekat
- 🔍 Pencarian bakery berdasarkan nama atau lokasi
- 🗺️ Peta interaktif menampilkan lokasi semua bakery
- 📦 Surprise packages dengan diskon hingga 70%
- 🛒 Sistem pemesanan dan konfirmasi order
- 📱 Tracking pesanan

## Struktur Folder

```
lib/
├── controllers/       # Business logic controllers
├── core/             # Core configurations (theme, constants)
├── database/         # Database helper & local storage
├── models/           # Data models (User, Bakery, Product, Order)
├── routes/           # App routing configuration
├── screens/          # UI screens
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── bakery_detail_screen.dart
│   ├── map_screen.dart
│   ├── order_confirm_screen.dart
│   └── my_orders_screen.dart
├── services/         # Services (Auth, Bakery, Order)
├── utils/            # Utility functions & helpers
├── widgets/          # Reusable widgets
└── main.dart         # Entry point
```

## Database Schema

Aplikasi menggunakan SQLite dengan 4 tabel utama:

1. **users** - Data pengguna (customer & bakery owner)
2. **bakeries** - Data toko bakery
3. **products** - Surprise packages yang tersedia
4. **orders** - Pesanan pengguna

## Setup & Instalasi

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Konfigurasi Google Maps API

Untuk menggunakan fitur peta, Anda perlu mendapatkan Google Maps API Key:

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Buat project baru atau pilih yang sudah ada
3. Enable Maps SDK for Android/iOS
4. Buat API Key
5. Ganti `YOUR_GOOGLE_MAPS_API_KEY` di file berikut:
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/AppDelegate.swift` (untuk iOS)

### 3. Jalankan Aplikasi

```bash
flutter run
```

## Cara Menggunakan Aplikasi

### Pertama Kali Membuka Aplikasi

1. **Register Akun**
   - Tap "Daftar" di halaman login
   - Isi form registrasi (nama, email, phone, password)
   - Klik "Daftar" untuk membuat akun

2. **Login**
   - Masukkan email dan password
   - Klik "Login"
   - Aplikasi akan langsung masuk ke Home Screen

### Fitur-Fitur Aplikasi

**Home Screen:**
- Melihat daftar bakery terdekat (otomatis diurutkan berdasarkan jarak)
- Mencari bakery dengan search bar
- Rating dan jarak ditampilkan untuk setiap bakery

**Map Screen:**
- Melihat semua lokasi bakery di peta
- Klik marker untuk melihat info bakery
- Navigasi ke detail bakery

**Detail Bakery:**
- Informasi lengkap bakery (alamat, jam buka, telepon)
- Daftar surprise packages yang tersedia
- Diskon dan harga asli ditampilkan
- Stok tersisa

**Order Confirm:**
- Pilih jumlah package yang dipesan
- Pilih waktu pengambilan
- Lihat total harga
- Konfirmasi pesanan

**My Orders:**
- Lihat semua pesanan yang sudah dibuat
- Status pesanan (Pending, Confirmed, Ready, Completed, Cancelled)
- Detail waktu pengambilan dan total harga

## Data Dummy

Aplikasi sudah dilengkapi dengan data dummy untuk testing:

**3 Bakery:**
1. Roti Bakar 88 - Jakarta (Rating 4.5)
2. Bread & Butter - Jakarta (Rating 4.8)
3. The French Bakery - Jakarta (Rating 4.7)

**4 Surprise Packages:**
- Package Pagi (diskon 56%)
- Package Sore (diskon 69%)
- Mystery Box Organic (diskon 58%)
- French Pastry Box (diskon 60%)

## Teknologi yang Digunakan

- **Flutter** - Framework UI
- **Provider** - State Management
- **SQLite** - Local Database
- **Google Maps** - Maps Integration
- **Geolocator** - Location Services

## Fitur Mendatang

- [ ] Push notifications untuk reminder pengambilan
- [ ] Rating dan review bakery
- [ ] Payment gateway integration
- [ ] Chat dengan bakery
- [ ] Wishlist/favorite bakery
- [ ] Loyalty points system
- [ ] Social sharing

## Catatan Penting

⚠️ **Untuk Production:**
- Implementasikan password hashing (bcrypt/argon2)
- Gunakan API backend yang proper
- Implementasi proper authentication (JWT/OAuth)
- Tambahkan error handling yang lebih baik
- Implementasikan unit & integration tests
- Setup CI/CD pipeline

## Kontributor

Aplikasi ini dibuat untuk mata kuliah Inovasi Design dengan konsep mengurangi food waste dari bakery modern.

## License

MIT License
