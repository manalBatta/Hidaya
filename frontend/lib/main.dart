import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/widgets/Navigator.dart';
import 'package:frontend/widgets/ProfilePage.dart';
import 'package:frontend/widgets/SignInPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://mdkcqahrvtfgdhpvblfk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ka2NxYWhydnRmZ2RocHZibGZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4MTM4NTEsImV4cCI6MjA2NzM4OTg1MX0.RzBLUsggKGS4tx1YRivZoQkGswuZI41hkJqrr2TLNMc', // <-- your Supabase anon key
  );
  runApp(const HidayaApp());
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

    return MaterialApp(
      home: MainLayout(userRole: 'user'), // Change role as needed
      debugShowCheckedModeBanner: false,
    );
  }
}
