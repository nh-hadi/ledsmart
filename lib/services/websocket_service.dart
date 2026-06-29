import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class EspWebsocketService {
  String _espIp;
  WebSocketChannel? _channel;
  bool _terhubung = false;

  // Controller untuk menyiarkan status data ter-parsing ke UI
  final StreamController<Map<String, dynamic>> _statusStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Callback untuk melacak status koneksi
  void Function(bool)? padaPerubahanKoneksi;

  // Timer untuk mencoba koneksi ulang otomatis jika terputus
  Timer? _timerKoneksiUlang;
  bool _mencobaMenghubungkan = false;

  // Pembatas frekuensi data (Throttling) warna real-time
  Timer? _throttleTimer;
  String? _warnaJamTerakhir;
  String? _warnaFrameTerakhir;
  DateTime _waktuKirimTerakhir = DateTime.fromMillisecondsSinceEpoch(0);

  EspWebsocketService({required String ipAddress}) : _espIp = ipAddress;

  // Mendapatkan stream status jam digital
  Stream<Map<String, dynamic>> get statusStream => _statusStreamController.stream;

  // Status koneksi aktif
  bool get apakahTerhubung => _terhubung;

  // Mendapatkan alamat IP ESP8266
  String get ipAddress => _espIp;

  // Perbarui alamat IP ESP8266
  void perbaruiIp(String ipBaru) {
    if (_espIp != ipBaru) {
      _espIp = ipBaru;
      if (_terhubung) {
        reconnect();
      }
    }
  }

  // Melakukan koneksi ke WebSocket server ESP8266
  Future<void> hubungkan() async {
    if (_mencobaMenghubungkan || _terhubung) return;
    _mencobaMenghubungkan = true;

    _timerKoneksiUlang?.cancel();
    final url = 'ws://$_espIp/ws';
    debugPrint('Mencoba menghubungkan WebSocket ke: $url');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        (pesan) {
          _mencobaMenghubungkan = false;
          if (!_terhubung) {
            _terhubung = true;
            padaPerubahanKoneksi?.call(true);
            debugPrint('WebSocket Terhubung ke ESP8266!');
          }

          try {
            final Map<String, dynamic> data = jsonDecode(pesan);
            _statusStreamController.add(data);
          } catch (err) {
            debugPrint('Gagal mendekode pesan JSON WebSocket: $err');
          }
        },
        onError: (err) {
          debugPrint('Error pada koneksi WebSocket: $err');
          _tanganiKoneksiTerputus();
        },
        onDone: () {
          debugPrint('Koneksi WebSocket ditutup oleh server.');
          _tanganiKoneksiTerputus();
        },
      );
    } catch (e) {
      debugPrint('Koneksi WebSocket gagal dibuka: $e');
      _tanganiKoneksiTerputus();
    }
  }

  // Menghentikan koneksi
  void putuskan() {
    _timerKoneksiUlang?.cancel();
    _channel?.sink.close();
    _terhubung = false;
    padaPerubahanKoneksi?.call(false);
  }

  // Koneksi ulang otomatis
  void reconnect() {
    putuskan();
    hubungkan();
  }

  void _tanganiKoneksiTerputus() {
    _terhubung = false;
    _mencobaMenghubungkan = false;
    padaPerubahanKoneksi?.call(false);

    _timerKoneksiUlang?.cancel();
    _timerKoneksiUlang = Timer(const Duration(seconds: 4), () {
      hubungkan();
    });
  }

  // Mengirim perintah umum ke ESP8266
  void kirimPerintah(String cmd, dynamic val) {
    if (!_terhubung || _channel == null) return;

    final data = jsonEncode({
      'cmd': cmd,
      'val': val,
    });
    _channel!.sink.add(data);
  }

  // Mengirim payload map langsung (misal untuk playlist)
  void kirimPayloadMap(Map<String, dynamic> payload) {
    if (!_terhubung || _channel == null) return;
    _channel!.sink.add(jsonEncode(payload));
  }

  // -------------------------------------------------------------
  // METODE PENGIRIMAN WARNA REAL-TIME (THROTTLED - ZERO DELAY)
  // -------------------------------------------------------------

  // Mengirim data warna jam dengan pembatasan durasi agar ESP8266 tidak overload
  void kirimWarnaJamRealtime(String hexWarna) {
    _warnaJamTerakhir = hexWarna;
    _prosesKirimWarnaThrottled();
  }

  // Mengirim data warna frame dengan pembatasan durasi agar ESP8266 tidak overload
  void kirimWarnaFrameRealtime(String hexWarna) {
    _warnaFrameTerakhir = hexWarna;
    _prosesKirimWarnaThrottled();
  }

  void _prosesKirimWarnaThrottled() {
    final sekarang = DateTime.now();
    final selisihMs = sekarang.difference(_waktuKirimTerakhir).inMilliseconds;
    const intervalThrottle = 40;

    if (selisihMs >= intervalThrottle) {
      _eksekusiKirimWarnaData();
      _waktuKirimTerakhir = sekarang;
    } else {
      _throttleTimer?.cancel();
      _throttleTimer = Timer(Duration(milliseconds: intervalThrottle - selisihMs), () {
        _eksekusiKirimWarnaData();
        _waktuKirimTerakhir = DateTime.now();
      });
    }
  }

  void _eksekusiKirimWarnaData() {
    if (!_terhubung || _channel == null) return;

    if (_warnaJamTerakhir != null) {
      _channel!.sink.add(jsonEncode({
        'cmd': 'set_clock_color',
        'val': _warnaJamTerakhir,
      }));
      _warnaJamTerakhir = null;
    }

    if (_warnaFrameTerakhir != null) {
      _channel!.sink.add(jsonEncode({
        'cmd': 'set_text_color',
        'val': _warnaFrameTerakhir,
      }));
      _warnaFrameTerakhir = null;
    }
  }
}
