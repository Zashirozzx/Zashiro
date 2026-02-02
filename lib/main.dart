
import 'package:flutter/material.dart';
import 'package:ziru/services/overlay_service.dart'; // Corrigindo o caminho do import
import 'package:ziru/ui/home_screen.dart';

// Ponto de entrada para o serviço de sobreposição.
@pragma("vm:entry-point")
void overlayMain() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayWidget(), // O widget do overlay que criamos
    ),
  );
}

void main() {
  runApp(const ZiruApp());
}

class ZiruApp extends StatelessWidget {
  const ZiruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ziru FPS Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blueAccent,
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        // Definindo cores de destaque para consistência
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, // Cor do texto do botão
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueAccent,
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark)
            .copyWith(secondary: Colors.blueAccent),
      ),
      home: const HomeScreen(),
    );
  }
}
