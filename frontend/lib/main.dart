import 'package:flutter/material.dart';
import 'package:frontend/widgets/RegisterPage.dart';
import 'package:frontend/widgets/SignInPage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const HidayaApp());
}

class HidayaApp extends StatelessWidget {
  const HidayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hidaya',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: SignInPage(),
    );
  }
}
