
import 'package:flutter/material.dart';
import 'package:ziru/ui/home_screen.dart';
import 'package:ziru/ui/overlay_widget.dart';

// 1. Definição do Ponto de Entrada para o Overlay
// Esta anotação é crucial para que o compilador Dart encontre esta função
// quando o serviço de sobreposição for iniciado em um Isolate separado.
@pragma("vm:entry-point")
void overlayMain() {
  // Inicia a execução do widget de sobreposição.
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayWidget(),
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
      // 2. Aplicação do Tema All Black
      // Define o tema global do aplicativo para ser escuro, com um fundo preto puro.
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        // Outras customizações de tema podem ser adicionadas aqui.
      ),
      home: const HomeScreen(),
    );
  }
}
