import 'dart:ui';
import 'package:flutter/material.dart';

class CyberNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CyberNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'label': 'Color',
        'icon': Icons.palette_outlined,
        'activeIcon': Icons.palette,
      },
      {
        'label': 'Setting',
        'icon': Icons.settings_outlined,
        'activeIcon': Icons.settings,
      },
    ];

    return Container(
      margin: const EdgeInsets.only(left: 36.0, right: 36.0, bottom: 20.0),
      height: 68.0,
      decoration: BoxDecoration(
        color: const Color(0xFF151233).withOpacity(0.75), // Kaca semi transparan
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: const Color(0xFF00E5FF).withOpacity(0.18), // Pendar cyan halus di tepi border
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.04), // Pendar neon dasar
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = index == currentIndex;

                return InkWell(
                  onTap: () => onTap(index),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: SizedBox(
                    width: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // EFEK PENDARAN PADA IKON YANG AKTIF
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF00E5FF).withOpacity(0.12) // Pilar neon cyan di belakang ikon aktif
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withOpacity(0.08),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : [],
                          ),
                          child: Icon(
                            isSelected ? item['activeIcon'] : item['icon'],
                            color: isSelected
                                ? const Color(0xFF00E5FF)
                                : const Color(0xFF6E6D8A),
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // LABEL TEKS DENGAN ANIMASI WARNA
                        Text(
                          item['label'],
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF00E5FF)
                                : const Color(0xFF8E9BB4),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        // BULLET NEON DI BAGIAN BAWAH SEBAGAI PENANDA AKTIF
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isSelected ? 4.0 : 0.0,
                          height: isSelected ? 4.0 : 0.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withOpacity(0.8),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
