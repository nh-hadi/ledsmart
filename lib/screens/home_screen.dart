import 'dart:async';
import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import '../widgets/color_wheel.dart';

class HomeScreen extends StatefulWidget {
  final EspWebsocketService websocketService;
  final Map<String, dynamic> statusData;
  final bool terhubung;

  const HomeScreen({
    super.key,
    required this.websocketService,
    required this.statusData,
    required this.terhubung,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _livePreview = false;

  // State parameter warna & efek
  int _r = 255, _g = 255, _b = 255;
  int _efekTerpilih = 0;
  int _targetTerpilih = 0;
  int _durasi = 10;

  // Antrean Playlist
  final List<Map<String, dynamic>> _playlistSteps = [];
  int _activeDuration = 10;

  final List<String> _daftarEfek = [
    'Static (Solid Color)',
    'Blink',
    'Breath',
    'Rainbow',
    'Chase',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _padaWarnaBerubah(int r, int g, int b) {
    setState(() {
      _r = r;
      _g = g;
      _b = b;
    });
    if (_livePreview) {
      final hex =
          '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
      if (_targetTerpilih == 0 || _targetTerpilih == 1) {
        widget.websocketService.kirimWarnaJamRealtime(hex);
      }
      if (_targetTerpilih == 0 || _targetTerpilih == 2) {
        widget.websocketService.kirimWarnaFrameRealtime(hex);
      }
    }
  }

  void _kirimEfekRealtime(int modeIdx) {
    if (_targetTerpilih == 0 || _targetTerpilih == 1) {
      widget.websocketService.kirimPayloadMap({
        'cmd': 'set_segment_effect_id',
        'val': modeIdx,
      });
    }
    if (_targetTerpilih == 0 || _targetTerpilih == 2) {
      widget.websocketService.kirimPayloadMap({
        'cmd': 'set_effect_id',
        'val': modeIdx,
      });
    }
  }

  void _kirimDurasiRealtime(int durSec) {
    if (_targetTerpilih == 0 || _targetTerpilih == 1) {
      widget.websocketService.kirimPayloadMap({
        'cmd': 'set_segment_speed',
        'val': durSec * 100,
      });
    }
    if (_targetTerpilih == 0 || _targetTerpilih == 2) {
      widget.websocketService.kirimPayloadMap({
        'cmd': 'set_text_speed',
        'val': durSec * 100,
      });
    }
  }

  String get _hexStr =>
      '#${_r.toRadixString(16).padLeft(2, '0')}${_g.toRadixString(16).padLeft(2, '0')}${_b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

  Color get _warnaAktif => Color.fromARGB(255, _r, _g, _b);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. COLOR PICKER WHEEL ──
        _buildKartu(
          child: Column(
            children: [
              const SizedBox(height: 8),
              NixieColorWheel(
                r: _r,
                g: _g,
                b: _b,
                padaWarnaBerubah: _padaWarnaBerubah,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _warnaAktif,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _warnaAktif.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hexStr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00E5FF),
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Text(
                        'RGB Active Color',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8E9BB4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── 2. MODE & EFEK ──
        _buildKartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.tune_rounded, color: Color(0xFF00E5FF), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Mode & Efek',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _livePreview = !_livePreview),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _livePreview
                            ? const Color(0xFF00E5FF).withOpacity(0.2)
                            : const Color(0xFF0A091A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _livePreview
                              ? const Color(0xFF00E5FF)
                              : const Color(0xFF2A2850),
                        ),
                      ),
                      child: Text(
                        _livePreview ? 'LIVE: ON' : 'LIVE: OFF',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: _livePreview
                              ? const Color(0xFF00E5FF)
                              : const Color(0xFF8E9BB4),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _buildLabel('PILIH ANIMASI'),
              const SizedBox(height: 6),
              _buildDropdown(
                prefixIcon: Icons.animation,
                value: _efekTerpilih,
                items: List.generate(
                  _daftarEfek.length,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Text(_daftarEfek[i]),
                  ),
                ),
                onChanged: (v) {
                  setState(() => _efekTerpilih = v ?? 0);
                  if (_livePreview) {
                    _kirimEfekRealtime(v ?? 0);
                  }
                },
              ),
              const SizedBox(height: 14),

              _buildLabel('TARGET TAMPILAN'),
              const SizedBox(height: 6),
              _buildDropdown(
                value: _targetTerpilih,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Satu Warna (Semua)')),
                  DropdownMenuItem(value: 1, child: Text('Segmen Jam')),
                  DropdownMenuItem(value: 2, child: Text('Frame Background')),
                ],
                onChanged: (v) => setState(() => _targetTerpilih = v ?? 0),
              ),
              const SizedBox(height: 14),

              _buildLabel('DURASI (S)'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A091A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2850)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _durasi.toDouble(),
                        min: 1,
                        max: 60,
                        activeColor: const Color(0xFF00E5FF),
                        inactiveColor: const Color(0xFF2A2850),
                        onChanged: (v) {
                          setState(() => _durasi = v.toInt());
                          if (_livePreview) {
                            _kirimDurasiRealtime(v.toInt());
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 38,
                      child: Text(
                        '${_durasi}s',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Tombol Terapkan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9035FF), Color(0xFF00E5FF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final hex =
                          '#${_r.toRadixString(16).padLeft(2, '0')}${_g.toRadixString(16).padLeft(2, '0')}${_b.toRadixString(16).padLeft(2, '0')}';
                      if (_targetTerpilih == 0 || _targetTerpilih == 1) {
                        widget.websocketService.kirimPayloadMap({
                          'cmd': 'set_clock_color',
                          'val': hex,
                        });
                      }
                      if (_targetTerpilih == 0 || _targetTerpilih == 2) {
                        widget.websocketService.kirimPayloadMap({
                          'cmd': 'set_text_color',
                          'val': hex,
                        });
                      }
                      widget.websocketService.kirimPayloadMap({
                        'cmd': 'set_segment_effect_id',
                        'val': _efekTerpilih,
                      });
                      widget.websocketService.kirimPayloadMap({
                        'cmd': 'save_config',
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Konfigurasi diterapkan ke perangkat!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                    label: const Text(
                      'TERAPKAN KE JAM',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              _buildLabel('DURASI LANGKAH PLAYLIST (S)'),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Durasi Langkah:", style: TextStyle(fontSize: 13, color: Colors.white)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF00E5FF)),
                        onPressed: () {
                          if (_activeDuration > 1) {
                            setState(() => _activeDuration--);
                          }
                        },
                      ),
                      Text("$_activeDuration detik", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00E5FF)),
                        onPressed: () {
                          setState(() => _activeDuration++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _playlistSteps.add({
                            "mode": _efekTerpilih,
                            "name": _daftarEfek[_efekTerpilih],
                            "duration": _activeDuration,
                            "color": _hexStr,
                          });
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Langkah ditambahkan ke antrean!'),
                            backgroundColor: Color(0xFF9035FF),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9035FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('TAMBAH KE ANTREAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _playlistSteps.isEmpty
                          ? null
                          : () {
                              final payload = {
                                "brightness": 128,
                                "loop": true,
                                "steps": _playlistSteps.map((e) => {
                                  "duration": e['duration'],
                                  "segments": [
                                    {
                                      "start": 0,
                                      "stop": 29,
                                      "mode": e['mode'],
                                      "speed": 1000,
                                      "color": e['color'].replaceAll('#', ''),
                                    }
                                  ]
                                }).toList()
                              };
                              widget.websocketService.kirimPayloadMap(payload);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Antrean playlist disimpan ke perangkat!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
                      label: const Text('SIMPAN PLAYLIST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── 3. ANTRIAN ANIMASI (Sequence Playlist) ──
        _buildKartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ANTRIAN ANIMASI (Sequence Playlist)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00E5FF),
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (_playlistSteps.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _playlistSteps.clear();
                        });
                      },
                      child: const Text('BERSIHKAN', style: TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _playlistSteps.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Belum ada langkah playlist. Tambahkan beberapa di atas!',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _playlistSteps.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = _playlistSteps.removeAt(oldIndex);
                          _playlistSteps.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final step = _playlistSteps[index];
                        final stepColor = Color(int.parse("FF${step['color'].replaceAll('#', '')}", radix: 16));
                        return Card(
                          key: ValueKey('${step['name']}_${index}_${step['color']}'),
                          color: const Color(0xFF0A091A),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: const Color(0xFF2A2850)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: stepColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: stepColor.withOpacity(0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            title: Text(
                              "${index + 1}. ${step['name']}",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            subtitle: Text(
                              "Durasi: ${step['duration']}s | Warna: ${step['color']}",
                              style: const TextStyle(fontSize: 11, color: Color(0xFF8E9BB4)),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _efekTerpilih = step['mode'];
                                      _activeDuration = step['duration'];
                                      final colorHex = step['color'].replaceAll('#', '');
                                      final colorVal = int.parse("FF$colorHex", radix: 16);
                                      final parsedWarna = Color(colorVal);
                                      _r = parsedWarna.red;
                                      _g = parsedWarna.green;
                                      _b = parsedWarna.blue;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Detail langkah dimuat ke kontroler atas untuk diedit.'),
                                        backgroundColor: Colors.blue,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  tooltip: "Edit Langkah",
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _playlistSteps.removeAt(index);
                                    });
                                  },
                                  tooltip: "Hapus Langkah",
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Color(0xFF00E5FF),
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _buildDropdown({
    IconData? prefixIcon,
    required int value,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0A091A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2850)),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, color: const Color(0xFF00E5FF), size: 16),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF151233),
                borderRadius: BorderRadius.circular(12),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF00E5FF)),
                style: const TextStyle(fontSize: 13, color: Colors.white),
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
