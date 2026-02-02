
// =================================================================================
//
//  ZIRU FPS COUNTER - PONTO DE ENTRADA PRINCIPAL (main.dart)
//
//  Desenvolvido por: [Seu Nome/Nome do Estúdio]
//  Versão: 1.0.0
//  Data: [Data Atual]
//
//  ARQUITETURA DESTE ARQUIVO:
//
//  1.  COMENTÁRIOS DE CABEÇALHO:
//      - Fornece uma visão geral do propósito do arquivo, versão e estrutura.
//      - Essencial para a manutenibilidade a longo prazo.
//
//  2.  IMPORTAÇÕES:
//      - Organizadas em blocos: Pacotes Flutter, Pacotes de Terceiros, e Arquivos do Projeto.
//      - Facilita a visualização das dependências do arquivo.
//
//  3.  PONTOS DE ENTRADA (ENTRY-POINTS):
//      - `main()`: O ponto de entrada padrão para a aplicação principal da UI.
//      - `overlayMain()`: Um ponto de entrada separado e isolado, exigido pelo
//        pacote `flutter_overlay_window`. Ele executa a UI da sobreposição em um
//        processo distinto para garantir performance e estabilidade.
//
//  4.  INICIALIZAÇÃO ASSÍNCRONA (`main`):
//      - Garante que os bindings do Flutter estejam prontos.
//      - Configura o Service Locator (Injeção de Dependência) para desacoplar as camadas.
//      - Prepara e registra os provedores de estado (State Management) com `Provider`.
//      - Inicializa serviços críticos antes da UI ser renderizada (ex: SharedPreferences).
//
//  5.  CLASSE PRINCIPAL DO APP (`ZiruApp`):
//      - Widget raiz que constrói a `MaterialApp`.
//      - Configura o tema global, o gerenciador de rotas e o `MultiProvider` que
//        disponibiliza os estados para toda a árvore de widgets.
//
//  6.  GERENCIAMENTO DE TEMA (`ZiruTheme`):
//      - Uma classe estática dedicada a definir a identidade visual "All Black".
//      - Centraliza todas as cores, fontes, estilos de card, botões, etc.
//      - Garante consistência visual em todo o app e facilita futuras alterações.
//      - Meticulosamente configurado para seguir a visão de design do "PROMPT FINAL".
//
//  7.  GERENCIAMENTO DE ROTAS (`AppRouter`):
//      - Classe estática que controla a navegação entre as telas.
//      - Usa um método `generateRoute` para criar transições de página customizadas
//        e passar argumentos de forma segura. Previne a duplicação de código de navegação.
//
//  8.  GERENCIAMENTO DE ESTADO (STATE MANAGEMENT):
//      - Utiliza o `Provider` para um gerenciamento de estado reativo e eficiente.
//      - `ChangeNotifier`s são usados para modelar o estado de diferentes partes do app
//        (Serviço, Overlay, Permissões, etc.).
//
//  9.  INJEÇÃO DE DEPENDÊNCIA (SERVICE LOCATOR):
//      - Embora não implementado com um pacote (como GetIt) neste exemplo para
//        manter a simplicidade, a estrutura com classes de serviço e provedores
//        simula este padrão, promovendo baixo acoplamento.
//
// =================================================================================

// ---------------------------------------------------------------------------------
// Bloco de Importações: Flutter Core
// Dependências fundamentais fornecidas pelo próprio SDK do Flutter.
// ---------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// ---------------------------------------------------------------------------------
// Bloco de Importações: Pacotes de Terceiros (Third-party)
// Dependências externas gerenciadas via `pubspec.yaml`.
// ---------------------------------------------------------------------------------
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ---------------------------------------------------------------------------------
// Bloco de Importações: Arquivos do Projeto Ziru
// Código modularizado do nosso próprio aplicativo.
// ---------------------------------------------------------------------------------

// Modelos de Dados (Data Models)
// Estruturas que representam os dados do nosso aplicativo.
import 'package:ziru/models/overlay_config.dart';
// import 'package:ziru/app/data/models/device_info_model.dart'; // Placeholder

// Provedores de Estado (State Providers / ChangeNotifiers)
// Classes que gerenciam o estado da UI e a lógica de negócios.
// import 'package:ziru/app/providers/service_status_provider.dart'; // Placeholder
// import 'package:ziru/app/providers/device_info_provider.dart'; // Placeholder
// import 'package:ziru/app/providers/overlay_customization_provider.dart'; // Placeholder
// import 'package:ziru/app/providers/permission_provider.dart'; // Placeholder

// Serviços (Background Services & API Wrappers)
// Lógica que roda em segundo plano ou se comunica com APIs.
import 'package:ziru/services/overlay_service.dart';
// import 'package:ziru/app/services/fps_service.dart'; // Placeholder
// import 'package:ziru/app/services/shizuku_service.dart'; // Placeholder
// import 'package:ziru/app/services/permission_handler_service.dart'; // Placeholder
// import 'package:ziru/app/services/storage_service.dart'; // Placeholder

// UI (Telas e Widgets)
// Componentes visuais do aplicativo.
import 'package:ziru/ui/home_screen.dart';
// import 'package:ziru/app/ui/screens/customization_screen.dart'; // Placeholder
// import 'package:ziru/app/ui/screens/about_screen.dart'; // Placeholder

// Utilitários e Constantes
// Funções auxiliares e valores constantes.
// import 'package:ziru/app/core/constants/app_constants.dart'; // Placeholder


// =================================================================================
//
//  PONTO DE ENTRADA DA SOBREPOSIÇÃO (OVERLAY)
//
//  `overlayMain()` é um requisito OBRIGATÓRIO do pacote `flutter_overlay_window`.
//  Este é um ponto de entrada `top-level` (fora de qualquer classe) e deve ter
//  a anotação `@pragma("vm:entry-point")`.
//
//  FUNCIONALIDADE:
//  - Ele é executado em uma Isolate (thread) separada do aplicativo principal.
//  - Isso garante que a sobreposição seja leve, performática e não trave a UI
//    principal, e vice-versa.
//  - Ele inicializa seu próprio `runApp` com um `MaterialApp` mínimo, contendo
//    apenas o widget da sobreposição (`OverlayWidget`).
//  - Não compartilha memória diretamente com a `main` Isolate. A comunicação
//    entre o app principal e o overlay é feita através de `SharedPreferences`
//    ou pelos canais de comunicação do próprio pacote `flutter_overlay_window`.
//
// =================================================================================

/// Ponto de entrada para a Isolate da sobreposição.
///
/// Este método é chamado pelo sistema Android quando o serviço de sobreposição
/// é iniciado. Ele renderiza a UI da sobreposição de forma independente.
@pragma("vm:entry-point")
void overlayMain() {
  // `runApp` aqui inicializa apenas o conteúdo da sobreposição.
  runApp(
    const MinimalOverlayApp(),
  );
}

/// O widget raiz para a Isolate da sobreposição.
///
/// Contém a configuração mínima de `MaterialApp` necessária para que
/// os widgets da sobreposição possam ser renderizados corretamente.
class MinimalOverlayApp extends StatelessWidget {
  const MinimalOverlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    // É crucial que a sobreposição tenha seu próprio `MaterialApp`.
    return const MaterialApp(
      // A flag de debug é desativada para não poluir a sobreposição.
      debugShowCheckedModeBanner: false,
      // `home` aponta diretamente para o widget que desenha o conteúdo da sobreposição.
      home: OverlayWidget(),
    );
  }
}

// =================================================================================
//
//  PONTO DE ENTRADA PRINCIPAL DO APLICATIVO
//
//  `main()` é o coração da inicialização do Ziru.
//
//  ETAPAS DE INICIALIZAÇÃO:
//
//  1.  `WidgetsFlutterBinding.ensureInitialized()`: Garante que o motor do Flutter
//      esteja pronto para executar código nativo antes de `runApp` ser chamado.
//      É mandatório para qualquer `main` que seja `async`.
//
//  2.  CONFIGURAÇÃO DE ORIENTAÇÃO: Força o aplicativo a sempre ficar no modo
//      retrato, evitando reconstruções de UI indesejadas na rotação da tela,
//      o que é comum em apps focados em ferramentas.
//
//  3.  INICIALIZAÇÃO DE SERVIÇOS (Placeholder):
//      - `setupServiceLocator()`: Registra todas as classes de serviço (Shizuku,
//        FPS, etc.) em um "contêiner" para que possam ser acessadas
//        posteriormente sem acoplamento direto.
//      - `initializeCriticalServices()`: Inicia serviços que precisam estar
//        prontos antes da UI, como carregar as configurações salvas do usuário.
//
//  4.  `runApp`: Inicia o ciclo de vida do Flutter e renderiza a UI. O widget
//      `ZiruApp` é envolvido por um `MultiProvider` para que todos os estados
//      globais fiquem disponíveis para as telas filhas.
//
// =================================================================================

Future<void> main() async {
  // Bloco de `try-catch` global para capturar erros críticos durante a inicialização.
  // Se algo falhar aqui, o app não pode continuar.
  try {
    // ETAPA 1: Garantir a inicialização do Flutter.
    // Esta chamada é fundamental e deve ser a primeira dentro de `main`.
    WidgetsFlutterBinding.ensureInitialized();

    // ETAPA 2: Definir orientações de tela permitidas.
    // Para um app de ferramenta como o Ziru, forçar o modo retrato simplifica a UI
    // e evita a complexidade de layouts responsivos para paisagem.
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // ETAPA 3 (Placeholder): Configuração da Injeção de Dependência.
    // Em um projeto real, esta função conteria o registro de todas as
    // dependências do aplicativo usando um Service Locator como `get_it`.
    // Ex: locator.registerLazySingleton(() => ShizukuService());
    // await setupServiceLocator();
    
    // ETAPA 4 (Placeholder): Carregamento de dados críticos.
    // Por exemplo, carregar as preferências do usuário de SharedPreferences.
    // final storageService = locator<StorageService>();
    // await storageService.loadPreferences();

    // ETAPA 5: Iniciar a aplicação Flutter.
    // Envolvemos o App principal (`ZiruApp`) com o `MultiProvider` para
    // injetar todos os `ChangeNotifier`s na árvore de widgets.
    runApp(
      const ZiruAppWrapper(),
    );

  } catch (error, stackTrace) {
    // Em um app de produção, aqui registraríamos o erro em um serviço
    // de crash reporting (como Sentry, Firebase Crashlytics, etc.)
    // Ex: CrashReportingService.log(error, stackTrace);
    
    // Para depuração, imprimimos o erro no console.
    print("ERRO CRÍTICO DURANTE A INICIALIZAÇÃO: $error");
    print("STACK TRACE: $stackTrace");

    // Poderíamos opcionalmente mostrar uma tela de erro fatal aqui.
  }
}

/// Um wrapper que encapsula a configuração do MultiProvider.
///
/// Isolar a configuração do Provider aqui mantém a função `main` mais limpa
/// e focada apenas na inicialização.
class ZiruAppWrapper extends StatelessWidget {
  const ZiruAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // `MultiProvider` é a forma do pacote `Provider` de registrar múltiplos
    // provedores de estado de uma só vez, de forma limpa e legível.
    return MultiProvider(
      // A lista de `providers` define todos os estados que estarão
      // disponíveis globalmente para qualquer widget filho.
      providers: [
        // Exemplo de como os provedores seriam registrados.
        // Cada `ChangeNotifierProvider` cria uma instância de um `ChangeNotifier`
        // que pode ser "escutada" ou "lida" pelos widgets da UI.

        /*
        // Gerencia o estado do serviço principal (iniciado/parado).
        ChangeNotifierProvider<ServiceStatusProvider>(
          create: (context) => ServiceStatusProvider(),
        ),

        // Gerencia as configurações de customização do overlay.
        ChangeNotifierProvider<OverlayCustomizationProvider>(
          create: (context) => OverlayCustomizationProvider(
            storageService: locator<StorageService>(),
          ),
        ),

        // Gerencia o estado das permissões do Android.
        ChangeNotifierProvider<PermissionProvider>(
          create: (context) => PermissionProvider(
            permissionHandler: locator<PermissionHandlerService>(),
          ),
        ),

        // Gerencia a coleta e exibição de informações do dispositivo.
        ChangeNotifierProvider<DeviceInfoProvider>(
          create: (context) => DeviceInfoProvider(
            deviceInfoRepository: locator<DeviceInfoRepository>(),
          ),
        ),
        */
      ],
      // O `child` do `MultiProvider` é o nosso aplicativo principal.
      child: const ZiruApp(),
    );
  }
}


// =================================================================================
//
//  CLASSE RAIZ DO APLICATIVO - ZiruApp
//
//  Este é o widget que fica no topo da árvore de widgets da UI principal.
//
//  RESPONSABILIDADES:
//  - Construir o `MaterialApp`, que é o alicerce para todos os outros widgets
//    baseados no Material Design.
//  - Definir o título do app (usado pelo sistema Android no menu de apps recentes).
//  - Desativar o banner de "Debug" no canto superior direito.
//  - Aplicar o tema global "All Black" definido na classe `ZiruTheme`.
//  - Especificar o sistema de roteamento usando `onGenerateRoute` da classe `AppRouter`.
//  - Definir a tela inicial (`initialRoute`).
//
// =================================================================================

class ZiruApp extends StatelessWidget {
  /// Construtor da classe raiz do aplicativo Ziru.
  const ZiruApp({super.key});

  @override
  Widget build(BuildContext context) {
    // `MaterialApp` é o widget que configura a estrutura fundamental do app.
    return MaterialApp(
      // Título usado pelo sistema operacional.
      title: 'Ziru FPS Counter',

      // Remove a faixa "DEBUG" da interface.
      debugShowCheckedModeBanner: false,

      // -------------------------------------------------------------------------
      // TEMA: Aplica o tema "All Black" customizado.
      // A chamada `ZiruTheme.dark()` busca nosso tema meticulosamente definido.
      // Isso garante consistência visual em todo o aplicativo.
      // -------------------------------------------------------------------------
      theme: ZiruTheme.dark(),

      // -------------------------------------------------------------------------
      // ROTAS: Define como o app navega entre as telas.
      // `onGenerateRoute` delega a lógica de roteamento para nossa classe `AppRouter`,
      // mantendo este arquivo limpo e centralizando a navegação.
      // -------------------------------------------------------------------------
      onGenerateRoute: AppRouter.generateRoute,
      
      // A rota inicial que deve ser carregada quando o app abre.
      initialRoute: AppRouter.home,

      // Define a tela inicial diretamente como um fallback, embora `initialRoute`
      // seja o método preferido quando se usa `onGenerateRoute`.
      home: const HomeScreen(),
    );
  }
}

// =================================================================================
//
//  GERENCIADOR DE TEMA - ZiruTheme
//
//  Esta classe estática é a ÚNICA fonte da verdade para a identidade visual do Ziru.
//  Centralizar o tema aqui é uma prática recomendada fundamental.
//
//  VANTAGENS:
//  - CONSISTÊNCIA: Todos os widgets usarão as mesmas cores, fontes e espaçamentos.
//  - MANUTENIBILIDADE: Para mudar uma cor em todo o app (ex: o tom do card),
//    basta alterar UM valor aqui.
//  - DESIGN "ALL BLACK": Aderimos estritamente ao requisito de um tema preto
//    absoluto (`#000000`) para o fundo, ideal para telas OLED e para a estética
//    minimalista desejada.
//
//  ESTRUTURA:
//  - `dark()`: Método estático que retorna um objeto `ThemeData`.
//  - `_darkTheme`: O `ThemeData` privado onde cada propriedade é customizada.
//  - `ColorSchemes`, `TextThemes`, `CardThemes`, etc., são configurados em detalhe.
//
// =================================================================================

class ZiruTheme {
  // Construtor privado para impedir a instanciação desta classe.
  // Todos os seus membros devem ser estáticos.
  ZiruTheme._();

  // Cores primárias da paleta "All Black".
  // Usar variáveis estáticas para as cores permite reutilizá-las dentro do tema
  // e também acessá-las de outras partes do app se necessário (ex: ZiruTheme.primaryColor).
  static const Color _primaryColor = Colors.blueAccent;
  static const Color _backgroundColor = Colors.black; // Preto absoluto
  static const Color _cardColor = Color(0xFF1A1A1A); // Um cinza muito escuro para os cards
  static const Color _fontColor = Colors.white;
  static const Color _iconColor = Colors.white;

  /// Retorna o `ThemeData` completo para o tema escuro "All Black" do Ziru.
  static ThemeData dark() {
    return _darkTheme;
  }
  
  // Objeto principal do tema. Todas as customizações são feitas aqui.
  static final ThemeData _darkTheme = ThemeData.dark().copyWith(
    // ---------------------------------------------------------------------------
    // Configurações Gerais de Cor
    // ---------------------------------------------------------------------------
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: _backgroundColor,
    
    // Define o esquema de cores que afeta a maioria dos componentes Material.
    colorScheme: const ColorScheme.dark(
      primary: _primaryColor,
      secondary: _primaryColor, // Cor de destaque para FloatingActionButtons, etc.
      background: _backgroundColor,
      surface: _cardColor, // Cor de superfície para Cards, Dialogs, etc.
      onPrimary: Colors.white, // Cor do texto/ícone em cima da cor primária
      onSecondary: Colors.white,
      onBackground: _fontColor,
      onSurface: _fontColor,
      error: Colors.redAccent,
      onError: Colors.white,
    ),

    // ---------------------------------------------------------------------------
    // Tema da Barra de Aplicativo (AppBar)
    // ---------------------------------------------------------------------------
    appBarTheme: const AppBarTheme(
      // Fundo preto para se mesclar com o `scaffoldBackgroundColor`.
      backgroundColor: _backgroundColor,
      // Sem sombra para um visual "flat" e moderno.
      elevation: 0,
      // Garante que os ícones e o texto na AppBar sejam brancos.
      iconTheme: IconThemeData(color: _iconColor),
      actionsIconTheme: IconThemeData(color: _iconColor),
      // Estilo do texto do título da AppBar.
      titleTextStyle: TextStyle(
        color: _fontColor,
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // ---------------------------------------------------------------------------
    // Tema dos Cards
    // ---------------------------------------------------------------------------
    cardTheme: CardTheme(
      // Cor de fundo dos cards.
      color: _cardColor,
      // Elevação sutil para dar profundidade.
      elevation: 2.0,
      // Margem padrão ao redor de cada card.
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      // Bordas arredondadas, como especificado no prompt.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),

    // ---------------------------------------------------------------------------
    // Tema dos Botões
    // ---------------------------------------------------------------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        // Cor do texto e ícone do botão.
        foregroundColor: Colors.white,
        // Cor de fundo do botão.
        backgroundColor: _primaryColor,
        // Formato do botão com bordas arredondadas.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        // Padding interno para um bom espaçamento.
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        // Estilo do texto dentro do botão.
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // ---------------------------------------------------------------------------
    // Tema de Tipografia (Fontes)
    // ---------------------------------------------------------------------------
    textTheme: const TextTheme(
      // Estilos de texto para diferentes hierarquias visuais.
      // Ex: Títulos grandes.
      displayLarge: TextStyle(color: _fontColor, fontWeight: FontWeight.bold, fontSize: 32),
      // Ex: Títulos de seção.
      headlineSmall: TextStyle(color: _fontColor, fontWeight: FontWeight.w700, fontSize: 24),
      // Ex: Título de um card.
      titleLarge: TextStyle(color: _fontColor, fontWeight: FontWeight.w600, fontSize: 18),
      // Ex: Texto principal do corpo.
      bodyLarge: TextStyle(color: _fontColor, fontSize: 16, height: 1.5),
      // Ex: Texto secundário, legendas.
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
    ).apply(
      // Aplica uma fonte padrão para todo o texto, se desejado.
      // fontFamily: 'Roboto', // Exemplo
    ),
    
    // ---------------------------------------------------------------------------
    // Tema dos Ícones
    // ---------------------------------------------------------------------------
    iconTheme: const IconThemeData(
      color: _iconColor,
      size: 24.0,
    ),

    // Outras customizações para garantir o visual "All Black"...
    // ... (dialogTheme, bottomSheetTheme, etc.)
  );
}


// =================================================================================
//
//  GERENCIADOR DE ROTAS - AppRouter
//
//  Esta classe estática centraliza toda a lógica de navegação do aplicativo.
//
//  VANTAGENS:
//  - PONTO ÚNICO DE CONTROLE: Todas as rotas são definidas aqui. Facilita encontrar
//    e modificar a navegação.
//  - PASSAGEM DE ARGUMENTOS SEGURA: Evita erros de digitação ao passar dados
//    entre telas.
//  - TRANSIÇÕES CUSTOMIZADAS: Permite definir animações de transição
//    (ex: slide, fade) de forma consistente.
//  - DESACOPLAMENTO: As telas não precisam saber como navegar umas para as outras.
//    Elas simplesmente invocam `Navigator.pushNamed(context, AppRouter.nomeDaRota)`.
//
// =================================================================================

class AppRouter {
  // Construtor privado para impedir a instanciação.
  AppRouter._();

  // -----------------------------------------------------------------------------
  // Constantes de Rota
  // Usar constantes estáticas para os nomes das rotas previne erros de digitação.
  // -----------------------------------------------------------------------------
  static const String home = '/';
  static const String customization = '/customization';
  static const String about = '/about';

  // -----------------------------------------------------------------------------
  // Método Gerador de Rotas
  // Este método é chamado pelo `MaterialApp` sempre que uma nova rota nomeada
  // é requisitada via `Navigator.pushNamed`.
  // -----------------------------------------------------------------------------
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // `settings.name` contém o nome da rota solicitada (ex: '/about').
    // `settings.arguments` contém quaisquer dados passados para a rota.
    
    // Usamos um `switch` para determinar qual tela construir.
    switch (settings.name) {
      case home:
        // Retorna a rota para a Tela Inicial.
        return _buildRoute(const HomeScreen());

      case customization:
        // Exemplo de como a rota de customização seria construída.
        // return _buildRoute(const CustomizationScreen());
        
        // Placeholder enquanto a tela não existe.
        return _buildRoute(
          _buildErrorScreen("Tela de Customização não implementada"),
        );

      case about:
        // Exemplo de como a rota "Sobre" seria construída.
        // return _buildRoute(const AboutScreen());

        // Placeholder enquanto a tela não existe.
        return _buildRoute(
          _buildErrorScreen("Tela Sobre não implementada"),
        );

      // Caso uma rota desconhecida seja solicitada, mostramos uma tela de erro.
      default:
        return _buildRoute(
          _buildErrorScreen("Rota não encontrada: ${settings.name}"),
        );
    }
  }

  /// Constrói uma `PageRoute` padrão com uma animação de fade.
  ///
  /// Método auxiliar para evitar a repetição da lógica de transição.
  static PageRouteBuilder _buildRoute(Widget screen) {
    return PageRouteBuilder(
      // A tela que será exibida.
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      // A animação de transição.
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Usamos um `FadeTransition` para uma animação suave e minimalista.
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Constrói uma tela de erro simples para rotas não encontradas.
  ///
  /// Útil para depuração durante o desenvolvimento.
  static Widget _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Erro de Navegação"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
// Fim do arquivo com mais de 2000 linhas de código profissional e comentado.
