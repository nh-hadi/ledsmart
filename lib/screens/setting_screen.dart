import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';
import '../services/websocket_service.dart';

class SettingScreen extends StatefulWidget {
  final EspWebsocketService websocketService;
  final Map<String, dynamic> statusData;
  final bool terhubung;

  const SettingScreen({
    super.key,
    required this.websocketService,
    required this.statusData,
    required this.terhubung,
  });

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _ipController = TextEditingController();
  
  // Controller WiFi SSID/PW
  final TextEditingController _staSsidController = TextEditingController();
  final TextEditingController _staPassController = TextEditingController();
  final TextEditingController _apSsidController = TextEditingController();
  final TextEditingController _apPassController = TextEditingController();

  bool _expandWifi = false;
  bool _expandSistem = false;

  @override
  void initState() {
    super.initState();
    _ipController.text = widget.websocketService.ipAddress;
    
    // Isi data default jika ada di statusData
    _staSsidController.text = widget.statusData['sta_ssid'] ?? '';
    _apSsidController.text = widget.statusData['ap_ssid'] ?? ''; // ssid target/AP
  }

  @override
  void dispose() {
    _ipController.dispose();
    _staSsidController.dispose();
    _staPassController.dispose();
    _apSsidController.dispose();
    _apPassController.dispose();
    super.dispose();
  }

  Future<void> _saveIP(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('esp_ip', ip);
    widget.websocketService.perbaruiIp(ip);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('IP target diperbarui ke: $ip'),
          backgroundColor: const Color(0xFF9035FF),
        ),
      );
    }
  }

  void _kirimKonfigurasiWifi() {
    if (!widget.terhubung) return;

    if (_staSsidController.text.isNotEmpty) {
      widget.websocketService.kirimPayloadMap({
        'cmd': 'set_sta_wifi',
        'ssid': _staSsidController.text,
        'pass': _staPassController.text,
      });
    }

    if (_apSsidController.text.isNotEmpty) {
      widget.websocketService.kirimPayloadMap({
        'cmd': 'set_ap_wifi',
        'ssid': _apSsidController.text,
        'pass': _apPassController.text,
      });
    }

    widget.websocketService.kirimPayloadMap({
      'cmd': 'save_config',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Setelan WiFi dikirim ke perangkat!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatUptime(dynamic detik) {
    if (detik == null) return '0j 0m';
    int sec = 0;
    if (detik is int) sec = detik;
    if (detik is double) sec = detik.toInt();

    final hari = sec ~/ 86400;
    final sisaHari = sec % 86400;
    final jam = sisaHari ~/ 3600;
    final sisaJam = sisaHari % 3600;
    final menit = sisaJam ~/ 60;

    if (hari > 0) {
      return '${hari}h ${jam}j ${menit}m';
    }
    return '${jam}j ${menit}m';
  }

  @override
  Widget build(BuildContext context) {
    final terhubung = widget.terhubung;
    final rssi = widget.statusData['rssi'] ?? 0;
    final ntpStatus = widget.statusData['ntp_status'] ?? 'WAITING';
    final heap = widget.statusData['heap'] != null ? '${(widget.statusData['heap'] / 1024).toStringAsFixed(0)} KB' : '0 KB';
    final uptimeDetik = widget.statusData['uptime'] ?? 0;
    final uptime = _formatUptime(uptimeDetik);
    final ipWifi = widget.statusData['ip'] ?? (terhubung ? widget.websocketService.ipAddress : '0.0.0.0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. KONEKSI IP ESP ──
        _buildKartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Dot Status
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: terhubung ? const Color(0xFF00E5FF) : Colors.redAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: terhubung
                              ? const Color(0xFF00E5FF).withOpacity(0.6)
                              : Colors.redAccent.withOpacity(0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Label Status Terhubung / Tidak Terhubung
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          terhubung ? 'TERHUBUNG KE JAM' : 'TIDAK TERHUBUNG',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: terhubung ? const Color(0xFF00E5FF) : Colors.redAccent,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          terhubung
                              ? 'Wi-Fi: ${widget.statusData['ssid'] ?? "Terhubung"}'
                              : 'Sambungkan HP ke Wi-Fi jam digital',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF8E9BB4),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tombol Hubungkan (Jika tidak terhubung)
                  if (!terhubung) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          AppSettings.openAppSettings(type: AppSettingsType.wifi);
                        } catch (e) {
                          debugPrint('Gagal membuka setelan Wi-Fi: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 4,
                        shadowColor: const Color(0xFF00E5FF).withOpacity(0.4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_rounded, size: 13, color: Colors.black),
                          SizedBox(width: 4),
                          Text('Hubungkan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ipController,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'IP ESP8266 (misal: 192.168.4.1)',
                        labelStyle: TextStyle(color: Colors.grey),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _saveIP(_ipController.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── 2. EXPANDABLE WIFI SETTING ──
        _buildKartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => setState(() => _expandWifi = !_expandWifi),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.wifi_lock_rounded, color: Color(0xFF00E5FF), size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Kredensial Jaringan WiFi',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    Icon(
                      _expandWifi ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF00E5FF),
                    ),
                  ],
                ),
              ),
              if (_expandWifi) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 12),
                _buildLabel('MODE AP (Access Point ESP)'),
                const SizedBox(height: 6),
                TextField(
                  controller: _apSsidController,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'SSID AP Mandiri',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _apPassController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password AP (Min 8 karakter)',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabel('MODE STA (Menghubungkan ke Router WiFi)'),
                const SizedBox(height: 6),
                TextField(
                  controller: _staSsidController,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'SSID WiFi Rumah/Router',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _staPassController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password WiFi Router',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: terhubung ? _kirimKonfigurasiWifi : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9035FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.settings, size: 16),
                        label: const Text('TERAPKAN WIFI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.wifi_find_rounded, color: Color(0xFF00E5FF)),
                      onPressed: () {
                        AppSettings.openAppSettings(type: AppSettingsType.wifi);
                      },
                      tooltip: "Buka Setelan WiFi",
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── 3. EXPANDABLE TELEMETRI SISTEM ──
        _buildKartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => setState(() => _expandSistem = !_expandSistem),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.developer_board_rounded, color: Color(0xFF00E5FF), size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Telemetri & Status Perangkat',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    Icon(
                      _expandSistem ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF00E5FF),
                    ),
                  ],
                ),
              ),
              if (_expandSistem) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 12),
                _buildBarisValue('IP Address Perangkat', ipWifi),
                _buildBarisValue('Kekuatan Sinyal (RSSI)', terhubung ? '$rssi dBm' : '- dBm'),
                _buildBarisValue('Status Server NTP', ntpStatus),
                _buildBarisValue('Sisa Memori (Free Heap)', heap),
                _buildBarisValue('Uptime Perangkat', uptime),
                const SizedBox(height: 12),
                if (terhubung) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            widget.websocketService.kirimPayloadMap({'cmd': 'reset_system'});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Perintah reset dikirim ke ESP8266...'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.12),
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.restart_alt_rounded, size: 16),
                          label: const Text('RESTART ESP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKartu({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151233),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: child,
    );
  }

  Widget _buildLabel(String teks) {
    return Text(
      teks,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: Color(0xFF00E5FF),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildBarisValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8E9BB4))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
