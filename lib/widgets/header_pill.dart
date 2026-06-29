import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class HeaderPillWidget extends StatefulWidget {
  final bool terhubung;
  final Map<String, dynamic> statusData;

  const HeaderPillWidget({
    super.key,
    required this.terhubung,
    required this.statusData,
  });

  @override
  State<HeaderPillWidget> createState() => _HeaderPillWidgetState();
}

class _HeaderPillWidgetState extends State<HeaderPillWidget> {
  String _waktuLokal = '-- : -- : --';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (widget.terhubung && widget.statusData['jam'] != null) {
            _waktuLokal = widget.statusData['jam'];
          } else {
            final sekarang = DateTime.now();
            _waktuLokal =
                '${sekarang.hour.toString().padLeft(2, '0')} : '
                '${sekarang.minute.toString().padLeft(2, '0')} : '
                '${sekarang.second.toString().padLeft(2, '0')}';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String suhuStr = '--.-';
    if (widget.statusData['suhu'] != null) {
      suhuStr = widget.statusData['suhu'].toString();
    } else if (widget.statusData['rtc_temp'] != null) {
      suhuStr = widget.statusData['rtc_temp'].toString();
    }

    final String namaWifi = widget.statusData['ssid'] ?? 'Namun...';
    final bool terhubung = widget.terhubung;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          height: 48.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B2FCC).withOpacity(0.35),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.white.withOpacity(0.06),
                  border: Border.all(
                    color: const Color(0xFF7B6FDD).withOpacity(0.25),
                    width: 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'IDS TECH',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'PREMIUM PRO',
                                style: TextStyle(
                                  fontSize: 6.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFAA95FF),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Container(
                            height: 20,
                            width: 1,
                            color: const Color(0xFF4B40A0).withOpacity(0.7),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _waktuLokal,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 20,
                            width: 1,
                            color: const Color(0xFF4B40A0).withOpacity(0.7),
                          ),
                          const SizedBox(width: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 68),
                            child: Text(
                              terhubung ? namaWifi : '...',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: terhubung
                                      ? const Color(0xFFAA95FF)
                                      : Colors.white54,
                                  letterSpacing: 0.4),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Icon(
                            terhubung ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                            size: 17,
                            color: terhubung ? const Color(0xFF00E5FF) : Colors.white30,
                          ),
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF00E5FF).withOpacity(0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.thermostat,
                                  size: 9,
                                  color: Color(0xFF00E5FF),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '$suhuStr°',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00E5FF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
