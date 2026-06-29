# 💡 LedSmart — Kontroler LED RGB via Flutter

<p align="center">
  <img src="https://img.shields.io/github/v/release/nh-hadi/ledsmart?color=00E5FF&label=Release&style=for-the-badge" />
  <img src="https://img.shields.io/github/actions/workflow/status/nh-hadi/ledsmart/build_apk.yml?style=for-the-badge&label=Build%20APK" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android" />
  <img src="https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter" />
</p>

Aplikasi mobile Flutter untuk mengontrol LED strip WS2812B melalui WebSocket secara **real-time** ke mikrokontroler **ESP8266** (controlRGB firmware).

---

## ✨ Fitur Utama

- 🎨 **Color Picker** — Roda warna presisi untuk kontrol RGB real-time
- 🌈 **Pilihan Animasi** — Static, Blink, Breath, Rainbow, Chase & lebih banyak lagi
- 📋 **Playlist Animasi** — Atur urutan efek dengan durasi kustom
- 📶 **Koneksi WebSocket** — Komunikasi cepat & non-blocking ke ESP8266
- ⚙️ **Pengaturan WiFi** — Konfigurasi AP/STA langsung dari aplikasi
- 🔒 **Simpan Konfigurasi** — Pengaturan tersimpan permanen di flash ESP8266

---

## 📱 Download APK

> Unduh APK terbaru dari halaman [**Releases**](https://github.com/nh-hadi/ledsmart/releases/latest)

---

## 🛠️ Hardware yang Dibutuhkan

| Komponen | Detail |
|---|---|
| Mikrokontroler | ESP8266 (NodeMCU / ESP-12F) |
| LED Strip | WS2812B (jumlah LED disesuaikan) |
| Pin Data LED | GPIO 14 (D5 NodeMCU) |
| Power | 5V via USB / adaptor |

---

## 🔌 Cara Menghubungkan

1. Upload firmware `controlRGB.ino` ke ESP8266 via Arduino IDE
2. Sambungkan HP ke WiFi AP: **`controlRGB_AP`** (password: `12345678`)
3. Buka app ledsmart → tab **Setting** → masukkan IP: **`192.168.4.1`** → Simpan
4. Kontrol LED strip secara real-time dari aplikasi!

---

## 📡 Protokol Komunikasi (WebSocket JSON)

```json
// Mengubah warna LED
{ "cmd": "set_clock_color", "val": "#FF5500" }

// Mengubah animasi efek
{ "cmd": "set_segment_effect_id", "val": 3 }

// Upload playlist animasi
{
  "brightness": 128, "loop": true,
  "steps": [
    { "duration": 10, "segments": [{ "start": 0, "stop": 29, "mode": 0, "speed": 1000, "color": "00E5FF" }] }
  ]
}
```

---

## 🏗️ Build dari Source

```bash
# Clone repo
git clone https://github.com/nh-hadi/ledsmart.git
cd ledsmart

# Install dependensi
flutter pub get

# Jalankan di emulator/perangkat
flutter run

# Build APK
flutter build apk --release
```

---

## 📂 Struktur Proyek

```
ledsmart/
├── lib/
│   ├── main.dart                 # Entry point & state management
│   ├── screens/
│   │   ├── home_screen.dart      # Halaman kontrol warna & efek
│   │   └── setting_screen.dart   # Halaman pengaturan & status
│   ├── services/
│   │   └── websocket_service.dart # Service koneksi WebSocket ke ESP8266
│   └── widgets/
│       ├── color_wheel.dart       # Widget roda warna kustom
│       ├── header_pill.dart       # Widget header glassmorphism
│       └── cyber_navigation_bar.dart # Widget navigasi bawah
```

---

## 📄 Lisensi

MIT License — bebas digunakan dan dikembangkan.

---

<p align="center">Dibuat dengan ❤️ menggunakan Flutter & ESP8266</p>
