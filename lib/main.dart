import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const ProviderScope(child: ClarityApp()));
}

class ClarityApp extends StatelessWidget {
  const ClarityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clarity.AI',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      // AMOLED Dark Theme
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // True Black
        primaryColor: const Color(0xFF10A37F), // ChatGPT Greenish
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10A37F),
          surface: Color(0xFF121212), // Slightly lighter for cards
          background: Colors.black,
          onSurface: Color(0xFFECECF1), // Off-white text for less eye strain
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const ChatScreen(),
    );
  }
}