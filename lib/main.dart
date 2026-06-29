import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/websocket_service.dart';
import 'widgets/cyber_navigation_bar.dart';
import 'widgets/header_pill.dart';
import 'screens/home_screen.dart';
import 'screens/setting_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RGB IDS Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF), // Cyan Neon
          onPrimary: Colors.black,
          secondary: Color(0xFF9035FF), // Purple Cyber
          onSecondary: Colors.white,
          surface: Color(0xFF151233), // Glass dark card base
          onSurface: Colors.white,
          background: Color(0xFF080616), // Deep Dark Space Blue
          onBackground: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF080616),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0A091A),
          labelStyle: const TextStyle(color: Color(0xFF8E9BB4)),
          hintStyle: const TextStyle(color: Color(0xFF8E9BB4)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2850)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2850)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _espIP = "192.168.4.1";
  bool _isConnected = false;
  late EspWebsocketService _websocketService;
  StreamSubscription? _statusSubscription;
  Map<String, dynamic> _statusData = {};

  @override
  void initState() {
    super.initState();
    _websocketService = EspWebsocketService(ipAddress: _espIP);

    _websocketService.padaPerubahanKoneksi = (status) {
      if (mounted) {
        setState(() {
          _isConnected = status;
        });
      }
    };

    _statusSubscription = _websocketService.statusStream.listen((data) {
      if (mounted) {
        setState(() {
          _statusData = data;
        });
      }
    });

    _loadSettings();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _websocketService.putuskan();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('esp_ip') ?? "192.168.4.1";
    setState(() {
      _espIP = savedIp;
      _websocketService.perbaruiIp(savedIp);
    });
    _websocketService.hubungkan();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = statusBarHeight + 68.0;

    final List<Widget> halaman = [
      HomeScreen(
        websocketService: _websocketService,
        statusData: _statusData,
        terhubung: _isConnected,
      ),
      SettingScreen(
        websocketService: _websocketService,
        statusData: _statusData,
        terhubung: _isConnected,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF080616),
      body: Stack(
        children: [
          // Content screen (bergeser dinamis mengikuti indeks tab)
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, headerHeight + 12, 16, 20),
            child: halaman[_currentIndex],
          ),
          // Header Pill melayang di paling atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: HeaderPillWidget(
                terhubung: _isConnected,
                statusData: _statusData,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: CyberNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
