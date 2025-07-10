// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/UserProvider.dart';
import 'package:frontend/widgets/Navigator.dart';
import 'package:frontend/widgets/ProfilePage.dart';
import 'package:frontend/widgets/ResponsiveLayou.dart';
import 'package:frontend/widgets/SignInPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/widgets/ProfilePage.dart';
import 'package:frontend/widgets/Navigator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final userProvider = UserProvider();
  await userProvider.loadUserFromPrefs();

  runApp(
    ChangeNotifierProvider(create: (_) => userProvider, child: HidayaApp()),
  );
}

class HidayaApp extends StatelessWidget {
  const HidayaApp({super.key});

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
