import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'widgets/network_overlay.dart';

// Import your navigation shell file and auth screen
import 'navigation_shell.dart';
import 'screens/auth_screen.dart';

// --- GLOBAL THEME STATE ---
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  // Required for async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load the environment variables from the .env file
  await dotenv.load(fileName: ".env");

  // 2. Initialize Supabase using the loaded variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    // Even if you named your variable SUPABASE_SECRET_KEY in your .env,
    // it maps to the anonKey parameter here. (Please swap the string for your anon key!)
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(const RakshaApp());
}

class RakshaApp extends StatelessWidget {
  const RakshaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Raksha Security',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
              brightness: Brightness.light,
              background: const Color(0xFFF8FAFC),
              surface: Colors.white,
            ),
            fontFamily: 'Roboto',
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00F0FF),
              brightness: Brightness.dark,
              background: const Color(0xFF0F172A),
              surface: const Color(0xFF1E293B),
            ),
            fontFamily: 'Roboto',
          ),

          builder: (context, child) {
            return NetworkOverlay(child: child!);
          },

          // THE FIX: Check for an active session.
          // If logged in -> go to your Navigation Shell.
          // If not -> go to the Auth Screen.
          home: Supabase.instance.client.auth.currentSession != null
              ? MainNavigationShell(themeNotifier: themeNotifier)
              : const AuthScreen(),
        );
      },
    );
  }
}
