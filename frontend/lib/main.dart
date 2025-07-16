// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/UserProvider.dart';
import 'package:frontend/widgets/ProfilePage.dart';
import 'package:frontend/widgets/ResponsiveLayou.dart';
import 'package:frontend/widgets/SignInPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:frontend/utils/auth_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:frontend/providers/NavigationProvider.dart';

Future<void> resetAppState() async {
  // Clear SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final userProvider = UserProvider();
  await userProvider.loadUserFromPrefs();
  Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!);

  // Check token expiration on app startup
  if (userProvider.isLoggedIn) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && AuthUtils.isTokenExpired(token)) {
        print('Token is expired on app startup, logging out user');
        await userProvider.logout();
      }
    } catch (e) {
      print('Error checking token on startup: $e');
      await userProvider.logout();
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: HidayaApp(),
    ),
  );
}

class HidayaApp extends StatefulWidget {
  const HidayaApp({super.key});

  @override
  State<HidayaApp> createState() => _HidayaAppState();
}

class _HidayaAppState extends State<HidayaApp> {
  Timer? _tokenCheckTimer;

  @override
  void initState() {
    super.initState();
    // Check token every 5 minutes
    _tokenCheckTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _checkTokenPeriodically();
    });
  }

  @override
  void dispose() {
    _tokenCheckTimer?.cancel();
    super.dispose();
  }

  void _checkTokenPeriodically() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isLoggedIn) {
      try {
        SharedPreferences.getInstance().then((prefs) {
          final token = prefs.getString('token');
          if (token != null && AuthUtils.isTokenExpired(token)) {
            print('Token expired during periodic check, logging out user');
            userProvider.logout();
          }
        });
      } catch (e) {
        print('Error during periodic token check: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        print("Consumer rebuilt, isLoggedIn: ${userProvider.isLoggedIn}");

        return MaterialApp(
          home:
              userProvider.isLoggedIn
                  ? ResponsiveLayout(
                    userRole: userProvider.user?['role'] ?? 'user',
                  )
                  : SignInPage(),
        );
      },
    );
  }
}
