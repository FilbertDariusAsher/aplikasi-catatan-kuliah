import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Kuliah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 3,
          color: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white54),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(onThemeToggle: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}
