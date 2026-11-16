import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/main_menu_screen.dart';
import 'services/auth_service.dart';
import 'services/favorite_service.dart';

void main() async {
  // Memastikan binding Flutter diinisialisasi sebelum async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive untuk penyimpanan lokal (Favorite)
  await Hive.initFlutter();
  await Hive.openBox(FavoriteService.boxName);

  // Cek apakah user sudah login sebelumnya melalui SharedPreferences
  final isLoggedIn = await AuthService.isLoggedIn();
  final currentUser = await AuthService.getCurrentUser();

  runApp(MyApp(
    initialScreen: (isLoggedIn && currentUser != null)
        ? MainMenuScreen(username: currentUser)
        : const LoginScreen(),
  ));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spaceflight News Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade700),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 2,
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
      ),
      home: initialScreen,
    );
  }
}
