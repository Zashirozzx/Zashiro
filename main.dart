
// =================================================================================
//
//  ZIRU FPS COUNTER - PONTO DE ENTRADA PRINCIPAL (main.dart) - VERSÃO FINAL
//
//  Desenvolvido por: [Seu Nome/Nome do Estúdio]
//  Versão: 1.2.0 (Completa)
//  Data: [Data Atual]
//
//  ARQUITETURA DESTE ARQUIVO (FINAL):
//
//  1.  PONTO DE ENTRADA DO OVERLAY (`@overlayMain`):
//      - Esta é uma função `top-level` especial, marcada com `@pragma('vm:entry-point')`.
//      - O pacote `flutter_overlay_window` a executará em uma Isolate separada.
//      - Sua única responsabilidade é executar a `OverlayWidget` em um `runApp` mínimo.
//      - É crucial que esta função seja leve e não inicialize serviços ou provedores
//        desnecessários, pois ela roda em um processo separado.
//
//  2.  PONTO DE ENTRADA PRINCIPAL (`main()`):
//      - Esta é a função `main` padrão da aplicação Flutter.
//      - RESPONSABILIDADE PRINCIPAL: Configurar a Injeção de Dependência (ID).
//      - Ela inicializa as instâncias singleton de todos os nossos serviços
//        (`FpsService`, `OverlayService`, `StorageService`, `PermissionService`).
//      - Ela então usa um `MultiProvider` para injetar nossos `ChangeNotifier`s
//        (`ServiceStatusProvider`, `OverlayCustomizationProvider`) na árvore de widgets.
//      - INJEÇÃO DE DEPENDÊNCIA: Os serviços são passados para os construtores dos
//        provedores. É assim que os provedores ganham acesso aos serviços para
//        orquestrar a lógica de negócios.
//      - Finalmente, ela executa o widget `ZiruApp`, que é a raiz da UI.
//
//  3.  WIDGET RAIZ (`ZiruApp`):
//      - Este widget constrói o `MaterialApp`.
//      - Define o tema global do aplicativo (escuro, com cores personalizadas).
//      - Define a estrutura de roteamento usando a classe `AppRouter`.
//      - A tela inicial é a `HomeScreen`.
//
//  4.  ROTEADOR (`AppRouter`):
//      - Uma classe estática que centraliza todas as definições de rotas.
//      - Isso evita o uso de strings "mágicas" para nomes de rotas e mantém o código
//        limpo e fácil de manter.
//
// =================================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importações de Pacotes
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

// Importações de UI
import 'package:ziru/ui/home_screen.dart';
import 'package:ziru/ui/customization_screen.dart';
import 'package:ziru/ui/about_screen.dart';

// Importações de Serviços (Singletons)
import 'package:ziru/services/fps_service.dart';
import 'package:ziru/services/overlay_service.dart';
import 'package:ziru/services/permission_service.dart';
import 'package:ziru/services/storage_service.dart';

// Importações de Provedores (ChangeNotifiers)
import 'package:ziru/providers/service_status_provider.dart';
import 'package:ziru/providers/overlay_customization_provider.dart';

// =================================================================================
// PONTO DE ENTRADA DA SOBREPOSIÇÃO (OVERLAY ENTRY-POINT)
// =================================================================================

/// Esta função é o ponto de entrada para a Isolate da sobreposição.
/// Ela é marcada com `@pragma('vm:entry-point')` para garantir que o compilador AOT
/// do Flutter não a remova durante o processo de tree-shaking.
@pragma("vm:entry-point")
void overlayMain() {
  // A sobreposição precisa executar seu próprio `runApp`.
  // O widget que ela executa deve ser o mais leve possível.
  runApp(const ZiruOverlay());
}

/// O widget raiz para a Isolate da sobreposição.
class ZiruOverlay extends StatelessWidget {
  const ZiruOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // A sobreposição não precisa de um `MaterialApp` completo, mas precisa de um
    // widget `Material` como ancestral para que os widgets de texto e outros
    // componentes do Material Design sejam renderizados corretamente.
    return const MaterialApp(
      // `debugShowCheckedModeBanner: false` remove a faixa de "Debug" no canto.
      debugShowCheckedModeBanner: false,
      // A `OverlayWidget` é a UI real que será exibida.
      home: OverlayWidget(),
    );
  }
}

// =================================================================================
// PONTO DE ENTRADA PRINCIPAL DA APLICAÇÃO (MAIN ENTRY-POINT)
// =================================================================================

void main() {
  // Garante que os bindings do Flutter sejam inicializados antes de qualquer outra coisa.
  WidgetsFlutterBinding.ensureInitialized();

  // --- Injeção de Dependência (Dependency Injection) ---
  // 1. Instanciamos nossos serviços (Singletons).
  final fpsService = FpsService();
  final overlayService = OverlayService();
  final storageService = StorageService();
  final permissionService = PermissionService();

  // 2. Executamos o app, envolvendo-o com `MultiProvider`.
  runApp(
    MultiProvider(
      // A lista de `providers` define quais `ChangeNotifier`s estarão disponíveis
      // para toda a árvore de widgets abaixo deles.
      providers: [
        // O `ChangeNotifierProvider` cria e fornece uma instância de um `ChangeNotifier`.
        ChangeNotifierProvider(
          create: (context) => ServiceStatusProvider(
            // 3. Injetamos as dependências de serviço no construtor do provider.
            fpsService: fpsService,
            overlayService: overlayService,
            permissionService: permissionService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => OverlayCustomizationProvider(
            // Injetamos os serviços que este provider precisa.
            storageService: storageService,
            overlayService: overlayService,
          ),
        ),
      ],
      // O `child` do `MultiProvider` é o nosso aplicativo principal.
      child: const ZiruApp(),
    ),
  );
}

// =================================================================================
// WIDGET RAIZ DA APLICAÇÃO
// =================================================================================

class ZiruApp extends StatelessWidget {
  const ZiruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ziru FPS Counter',
      debugShowCheckedModeBanner: false,

      // --- Tema Global da Aplicação ---
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00BFFF), // DeepSkyBlue
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        dividerColor: Colors.white24,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00BFFF),
          secondary: Color(0xFF03DAC6), // Teal
          background: Color(0xFF121212),
          surface: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),

      // --- Roteamento ---
      // Define a rota inicial e como gerar as rotas.
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

// =================================================================================
// CLASSE DE ROTEAMENTO
// =================================================================================

class AppRouter {
  // Constantes para os nomes das rotas. Evita erros de digitação.
  static const String home = '/';
  static const String customization = '/customization';
  static const String about = '/about';

  /// Gera as rotas com base no nome da rota fornecido.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case customization:
        return MaterialPageRoute(builder: (_) => const CustomizationScreen());
      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      default:
        // Se a rota não for encontrada, mostra uma tela de erro.
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Nenhuma rota definida para ${settings.name}'),
            ),
          ),
        );
    }
  }
}
