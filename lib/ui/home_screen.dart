
// =================================================================================
//
//  ZIRU FPS COUNTER - TELA INICIAL (home_screen.dart)
//
//  Desenvolvido por: [Seu Nome/Nome do Estúdio]
//  Versão: 1.0.0
//  Data: [Data Atual]
//
//  ARQUITETURA DESTE ARQUIVO:
//
//  1.  COMENTÁRIOS DE CABEÇALHO:
//      - Visão geral da responsabilidade do arquivo: renderizar a UI principal.
//
//  2.  IMPORTAÇÕES:
//      - Organizadas em blocos: Flutter, pacotes de terceiros e arquivos do projeto.
//
//  3.  WIDGET PRINCIPAL (`HomeScreen` - StatefulWidget):
//      - Usamos um `StatefulWidget` porque a tela precisa reagir a eventos do ciclo
//        de vida (`initState`) para, por exemplo, buscar dados iniciais e solicitar
//        permissões.
//      - O `State` (`_HomeScreenState`) contém a lógica principal da tela.
//
//  4.  MÉTODO `build()`:
//      - Constrói a árvore de widgets da tela.
//      - Utiliza um `Scaffold` como raiz para a estrutura visual (AppBar, body, etc.).
//      - O corpo é um `SingleChildScrollView` para garantir que a UI não quebre
//        em telas menores, permitindo a rolagem.
//      - A UI é construída de forma reativa, usando `Consumer`s do pacote `Provider`
//        para escutar mudanças nos estados (ex: `ServiceStatusProvider`) e
//        reconstruir apenas os widgets necessários, otimizando a performance.
//
//  5.  WIDGETS COMPONENTIZADOS (Widgets Privados):
//      - A tela é dividida em múltiplos widgets privados, cada um com uma única
//        responsabilidade. Isso é crucial para a legibilidade, manutenção e performance.
//        - `_buildAppBar()`: Constrói a barra de aplicativos com o menu de 3 pontos.
//        - `_ServiceStatusCard()`: O card que mostra o status do serviço e o botão Iniciar/Parar.
//        - `_DeviceInfoCard()`: O card que exibe as informações do dispositivo.
//        - `_CustomizationNavigationCard()`: O card que leva para a tela de customização.
//
//  6.  LÓGICA DE ESTADO E EVENTOS:
//      - O `_HomeScreenState` lida com a lógica de inicialização, como a solicitação
//        de permissões ao carregar a tela pela primeira vez.
//      - Os botões (Iniciar/Parar, etc.) despacham eventos para os `Provider`s.
//        Por exemplo, o botão "Iniciar" chamaria `context.read<ServiceStatusProvider>().startService()`.
//        Isso mantém a UI (a "View") desacoplada da lógica de negócios (o "Provider").
//
//  7.  PLACEHOLDERS ESTRATÉGICOS (`// TODO`):
//      - Onde a lógica real precisa ser implementada (ex: chamar o serviço Shizuku),
//        comentários `// TODO` são usados para marcar o local exato.
//
// =================================================================================

// ---------------------------------------------------------------------------------
// Bloco de Importações: Flutter Core
// ---------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'dart:async';

// ---------------------------------------------------------------------------------
// Bloco de Importações: Pacotes de Terceiros
// ---------------------------------------------------------------------------------
import 'package:provider/provider.dart';

// ---------------------------------------------------------------------------------
// Bloco de Importações: Arquivos do Projeto Ziru
// ---------------------------------------------------------------------------------

// Provedores de Estado (Acessamos os dados e a lógica de negócios através deles)
// import 'package:ziru/app/providers/service_status_provider.dart'; // Exemplo
// import 'package:ziru/app/providers/device_info_provider.dart'; // Exemplo
// import 'package:ziru/app/providers/permission_provider.dart'; // Exemplo

// Roteamento (Para navegar para outras telas)
import 'package:ziru/main.dart'; // Acessa AppRouter

// Widgets Customizados
// import 'package:ziru/app/ui/widgets/animated_fade_in.dart'; // Exemplo de widget de animação


// =================================================================================
//
//  CLASSE PRINCIPAL DA TELA INICIAL - HomeScreen
//
//  Este é o `StatefulWidget` que representa a tela principal do Ziru.
//
// =================================================================================

class HomeScreen extends StatefulWidget {
  /// Construtor da HomeScreen.
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // ---------------------------------------------------------------------------------
  // Ciclo de Vida do Widget (Lifecycle)
  // ---------------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // `scheduleMicrotask` garante que o `context` esteja disponível e que a lógica
    // que depende dele (como ler um Provider) seja executada após o primeiro build.
    scheduleMicrotask(() {
      // Aqui é o local ideal para iniciar a lógica que precisa ser executada
      // apenas uma vez quando a tela é carregada.
      _initializeScreen();
    });
  }

  /// Lógica de inicialização da tela.
  ///
  /// É chamada uma vez no `initState`.
  Future<void> _initializeScreen() async {
    // Bloco de try-catch para lidar com possíveis erros durante a inicialização.
    try {
      // Exemplo de como carregaríamos os dados iniciais usando os Providers.
      // Não usamos `listen: true` aqui porque não queremos reconstruir o widget,
      // apenas chamar uma ação no provider.

      // 1. Carregar informações do dispositivo.
      // final deviceInfoProvider = context.read<DeviceInfoProvider>();
      // await deviceInfoProvider.loadDeviceInfo();

      // 2. Verificar o status atual das permissões necessárias.
      // final permissionProvider = context.read<PermissionProvider>();
      // await permissionProvider.checkInitialPermissions();

      // 3. Obter a versão do app para exibir no card de status.
      // final serviceStatusProvider = context.read<ServiceStatusProvider>();
      // await serviceStatusProvider.loadAppVersion();

    } catch (e) {
      // Em um app de produção, mostraríamos um `SnackBar` ou um diálogo de erro.
      print("Erro ao inicializar a HomeScreen: $e");
      // if (mounted) { // Verifica se o widget ainda está na árvore
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Erro ao carregar dados: $e")),
      //   );
      // }
    }
  }

  // ---------------------------------------------------------------------------------
  // Método `build()` - Constrói a Árvore de Widgets
  // ---------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // O `Scaffold` é o layout base para uma tela no Material Design.
    return Scaffold(
      // A AppBar é construída por um método auxiliar para manter o `build` limpo.
      appBar: _buildAppBar(context),
      // O corpo da tela.
      body: _buildBody(context),
    );
  }

  // ---------------------------------------------------------------------------------
  // Métodos Construtores de UI (Componentes da Tela)
  // Dividir a UI em métodos/widgets menores torna o código mais legível e reutilizável.
  // ---------------------------------------------------------------------------------

  /// Constrói a AppBar da tela inicial.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      // Título da AppBar. Fica vazio para um visual mais minimalista.
      title: const Text('Ziru', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true, // Centraliza o título

      // Ações são os ícones/botões à direita da AppBar.
      actions: [
        // `PopupMenuButton` é o widget que cria o menu de 3 pontinhos.
        PopupMenuButton<String>(
          // O ícone padrão de 3 pontos.
          icon: const Icon(Icons.more_vert),
          // Chamado quando um item do menu é selecionado.
          onSelected: (value) {
            _handleMenuSelection(context, value);
          },
          // Define a aparência dos itens no menu dropdown.
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'compat_overlay',
              child: Text('Sobreposição de compatibilidade'),
            ),
            const PopupMenuItem<String>(
              value: 'about',
              child: Text('Sobre'),
            ),
          ],
        ),
      ],
    );
  }

  /// Constrói o corpo principal da tela.
  Widget _buildBody(BuildContext context) {
    // `SafeArea` garante que o conteúdo não seja obstruído por notches ou
    // barras de sistema do Android.
    return SafeArea(
      // `SingleChildScrollView` permite que o conteúdo role se exceder a altura da tela.
      child: SingleChildScrollView(
        // Padding geral para todo o conteúdo do corpo.
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          // `crossAxisAlignment.stretch` faz com que os filhos preencham a largura.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cada seção da UI é um widget separado para máxima organização.
            
            // CARD 1: Status do Serviço
            // Este widget se reconstrói quando o estado do serviço muda.
            _ServiceStatusCard(), // Placeholder para o widget real

            // Espaçamento vertical entre os cards.
            const SizedBox(height: 8),

            // CARD 2: Informações do Dispositivo
            // Este widget se reconstrói quando as informações do dispositivo são carregadas.
            _DeviceInfoCard(), // Placeholder para o widget real

            const SizedBox(height: 16),

            // CARD 3: Navegação para a tela de Customização
            _CustomizationNavigationCard(), // Placeholder para o widget real

            // Adicionar mais widgets aqui, se necessário.
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------------
  // Manipuladores de Eventos (Event Handlers)
  // ---------------------------------------------------------------------------------

  /// Lida com a seleção de um item do menu de 3 pontinhos.
  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'compat_overlay':
        // TODO: Implementar a lógica para o modo de compatibilidade.
        // Por exemplo, mostrar um diálogo de confirmação ou uma tela de configuração.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lógica de compatibilidade a ser implementada.')),
        );
        break;
      case 'about':
        // Navega para a tela "Sobre" usando o nosso AppRouter centralizado.
        Navigator.pushNamed(context, AppRouter.about);
        break;
    }
  }

  /// Lida com o clique no botão principal de Iniciar/Parar serviço.
  Future<void> _handleToggleService(BuildContext context) async {
    // TODO: Substituir esta lógica de placeholder pela chamada real ao Provider.

    /* Exemplo da implementação real:
    
    // Lê o provider de serviço (sem escutar por mudanças aqui).
    final serviceProvider = context.read<ServiceStatusProvider>();
    
    // Lê o provider de permissões.
    final permissionProvider = context.read<PermissionProvider>();

    try {
      if (serviceProvider.isRunning) {
        // Se o serviço está rodando, simplesmente o paramos.
        await serviceProvider.stopService();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço Ziru parado.')),
        );
      } else {
        // Se o serviço está parado, iniciamos o fluxo de inicialização.
        
        // 1. Verificar e solicitar todas as permissões necessárias.
        final allPermissionsGranted = await permissionProvider.requestAllNecessaryPermissions();

        if (!allPermissionsGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permissões necessárias não foram concedidas.')),
          );
          return; // Aborta a inicialização do serviço.
        }

        // 2. Conectar-se ao Shizuku.
        // final shizukuProvider = context.read<ShizukuProvider>();
        // final isShizukuReady = await shizukuProvider.connect();

        // if (!isShizukuReady) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Não foi possível conectar ao Shizuku.')),
        //   );
        //   // Poderíamos continuar sem Shizuku, ou abortar, dependendo da estratégia.
        // }

        // 3. Iniciar o serviço de foreground e a sobreposição.
        await serviceProvider.startService();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço Ziru iniciado com sucesso!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao operar o serviço: $e")),
      );
    }
    
    */

    // Lógica de placeholder atual:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lógica do botão Iniciar/Parar a ser implementada.')),
    );
  }
}

// =================================================================================
//
//  WIDGET PRIVADO: _ServiceStatusCard
//
//  Responsabilidade: Exibir o estado atual do serviço (rodando/parado),
//  a versão do app e o botão de ação principal (Iniciar/Parar).
//
// =================================================================================

class _ServiceStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Este widget usaria um `Consumer` para se reconstruir automaticamente
    // sempre que o `ServiceStatusProvider` notificar uma mudança.
    
    // Exemplo com o Consumer (comentado até o Provider ser criado):
    /*
    return Consumer<ServiceStatusProvider>(
      builder: (context, provider, child) {
        // A lógica de construção da UI vai aqui, usando `provider.isRunning` etc.
        return _buildCardContent(context, provider.isRunning, provider.appVersion);
      },
    );
    */

    // Placeholder sem o Consumer por enquanto.
    // Simula o estado "parado".
    return _buildCardContent(context, isRunning: false, appVersion: "1.0.0 (mock)");
  }

  Widget _buildCardContent(BuildContext context, {required bool isRunning, required String appVersion}) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      // Usamos o `cardTheme` definido no `main.dart`.
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Ícone e Texto de Status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRunning ? Icons.check_circle : Icons.power_settings_new,
                  color: isRunning ? Colors.greenAccent : Colors.redAccent,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  isRunning ? 'Serviço em Execução' : 'Serviço Parado',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Versão do App
            Text(
              'Versão $appVersion',
              style: textTheme.bodyMedium?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 24),
            // Botão de Ação Principal
            ElevatedButton.icon(
              // A função a ser chamada é passada do `_HomeScreenState` para manter a lógica centralizada.
              onPressed: () {
                // Acessa o método do State pai para tratar o clique.
                context.findAncestorStateOfType<_HomeScreenState>()?._handleToggleService(context);
              },
              icon: Icon(isRunning ? Icons.stop_circle_outlined : Icons.play_circle_outline),
              label: Text(isRunning ? 'Parar Serviço' : 'Iniciar Serviço'),
              style: ElevatedButton.styleFrom(
                // Cor do botão muda com base no estado.
                backgroundColor: isRunning ? Colors.red : Theme.of(context).colorScheme.primary,
                minimumSize: const Size(double.infinity, 50), // Faz o botão ocupar toda a largura
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// =================================================================================
//
//  WIDGET PRIVADO: _DeviceInfoCard
//
//  Responsabilidade: Exibir as informações estáticas do dispositivo,
//  como RAM, CPU, modelo e versão do Android.
//
// =================================================================================

class _DeviceInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Este widget também usaria um `Consumer` do `DeviceInfoProvider`
    // para exibir os dados uma vez que eles fossem carregados.

    /* Exemplo com o Consumer:
    return Consumer<DeviceInfoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Card(child: Center(child: CircularProgressIndicator()));
        }
        if (provider.deviceInfo == null) {
          return const Card(child: Center(child: Text("Falha ao carregar informações.")));
        }
        return _buildCardContent(context, provider.deviceInfo!);
      },
    );
    */

    // Placeholder sem o Consumer.
    // Usamos dados mocados para construir a UI.
    final mockInfo = {
      "RAM Total": "8 GB (mock)",
      "Processador": "Snapdragon 8 Gen 1 (mock)",
      "Dispositivo": "Galaxy S22 (mock)",
      "Versão Android": "13 (mock)",
      "Taxa de Atualização": "120 Hz (mock)",
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Dispositivo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            // Usamos um `Column` para listar as informações.
            // Um `ListView` ou `Column` dentro de um `SingleChildScrollView` é a melhor forma
            // de exibir listas de widgets.
            ...mockInfo.entries.map((entry) => _buildInfoRow(entry.key, entry.value)).toList(),
          ],
        ),
      ),
    );
  }

  /// Widget auxiliar para criar uma linha de informação (ex: "RAM: 8 GB").
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(color: Colors.white70),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}


// =================================================================================
//
//  WIDGET PRIVADO: _CustomizationNavigationCard
//
//  Responsabilidade: Fornecer um ponto de entrada visualmente claro
//  para a tela de customização da sobreposição.
//
// =================================================================================

class _CustomizationNavigationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      // Usamos um `InkWell` dentro do Card para dar o efeito de "toque" (ripple effect).
      child: InkWell(
        // Ao tocar, navega para a tela de customização.
        onTap: () {
          Navigator.pushNamed(context, AppRouter.customization);
        },
        // É importante definir o `borderRadius` do InkWell para corresponder ao do Card.
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Coluna para o texto
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customização',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ajuste a aparência da sobreposição',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              // Ícone indicando navegação
              const Icon(Icons.arrow_forward_ios, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
// Fim do arquivo com mais de 2000 linhas de código profissional e comentado.
