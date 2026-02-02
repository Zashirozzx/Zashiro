
// =================================================================================
//
//  ZIRU FPS COUNTER - TELA INICIAL (home_screen.dart) - VERSÃO FUNCIONAL
//
//  Desenvolvido por: [Seu Nome/Nome do Estúdio]
//  Versão: 1.1.0 (Funcional)
//  Data: [Data Atual]
//
//  ARQUITETURA DESTE ARQUIVO (ATUALIZADA):
//
//  1.  WIDGET PRINCIPAL (`HomeScreen` - StatefulWidget):
//      - Permanece como StatefulWidget para lógica de inicialização (`initState`).
//
//  2.  MÉTODO `build()`:
//      - O corpo agora é totalmente reativo, usando `Consumer` para reconstruir
//        partes da UI quando o estado no `ServiceStatusProvider` muda.
//
//  3.  WIDGETS COMPONENTIZADOS (CONECTADOS):
//      - `_ServiceStatusCard`: Agora é um `Consumer<ServiceStatusProvider>` que
//        observa `isRunning` e `appVersion`. Ele se reconstrói automaticamente,
//        mostrando o status correto do serviço e o botão de ação apropriado.
//      - `_DeviceInfoCard`: Permanece com dados mocados por enquanto, pois o provider
//        de informações do dispositivo ainda não foi criado.
//
//  4.  LÓGICA DE ESTADO E EVENTOS (FUNCIONAL):
//      - O `_HomeScreenState` contém o método `_handleToggleService`.
//      - Este método agora está conectado ao `ServiceStatusProvider`.
//      - Ele mostra um indicador de progresso (`CircularProgressIndicator`) enquanto
//        o serviço está iniciando e exibe `SnackBar`s para dar feedback de sucesso
//        ou falha ao usuário, criando uma experiência de usuário muito melhor.
//      - A complexidade da inicialização (permissões, Shizuku, etc.) está totalmente
//        abstraída no `ServiceStatusProvider`, mantendo a UI limpa.
//
// =================================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importações do Projeto Ziru
import 'package:ziru/main.dart'; // Acessa AppRouter
import 'package:ziru/providers/service_status_provider.dart'; // O coração do estado da UI

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Flag para controlar a exibição do indicador de progresso durante a inicialização do serviço.
  bool _isInitializingService = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Ziru', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuSelection(context, value),
          itemBuilder: (context) => [
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

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CARD 1: Status do Serviço - Agora um Consumer, totalmente reativo.
            _ServiceStatusCard(isLoading: _isInitializingService),
            const SizedBox(height: 8),
            // CARD 2: Informações do Dispositivo (ainda com dados mocados)
            _DeviceInfoCard(),
            const SizedBox(height: 16),
            // CARD 3: Navegação para a tela de Customização
            _CustomizationNavigationCard(),
          ],
        ),
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'compat_overlay':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lógica de compatibilidade a ser implementada.')),
        );
        break;
      case 'about':
        Navigator.pushNamed(context, AppRouter.about);
        break;
    }
  }

  /// Lida com o clique no botão principal de Iniciar/Parar serviço.
  /// Agora implementa a lógica real usando o ServiceStatusProvider.
  Future<void> _handleToggleService() async {
    // Lê o provider de serviço. Usamos `read` aqui porque estamos em um callback,
    // não precisamos escutar por mudanças neste ponto.
    final serviceProvider = context.read<ServiceStatusProvider>();

    // Se o serviço já estiver rodando, simplesmente o paramos.
    if (serviceProvider.isRunning) {
      await serviceProvider.stopService();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Serviço Ziru parado.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    // Se o serviço estiver parado, iniciamos a sequência de inicialização.
    setState(() {
      _isInitializingService = true;
    });

    // Tentamos iniciar o serviço. O `startService` no provider lida com toda a complexidade.
    final bool success = await serviceProvider.startService();

    // Após a tentativa, paramos de mostrar o indicador de progresso.
    if (mounted) {
      setState(() {
        _isInitializingService = false;
      });

      // Mostra um feedback visual para o usuário sobre o resultado.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Serviço Ziru iniciado com sucesso!'
              : 'Falha ao iniciar o serviço. Verifique as permissões.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}

// =================================================================================
//
//  WIDGET PRIVADO: _ServiceStatusCard (Agora um Consumer)
//
//  Este widget agora escuta o ServiceStatusProvider e se reconstrói automaticamente.
//
// =================================================================================

class _ServiceStatusCard extends StatelessWidget {
  final bool isLoading; // Flag para mostrar o indicador de progresso.

  const _ServiceStatusCard({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    // `Consumer` é o widget do Provider que escuta por mudanças e reconstrói a UI.
    return Consumer<ServiceStatusProvider>(
      // O `builder` é chamado sempre que `notifyListeners()` é acionado no provider.
      builder: (context, provider, child) {
        // O `child` é um widget opcional que pode ser passado para o Consumer para
        // otimização, caso parte da sub-árvore não dependa do estado.
        
        final bool isRunning = provider.isRunning;
        final String appVersion = provider.appVersion;
        final textTheme = Theme.of(context).textTheme;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Se estiver carregando, mostramos um indicador de progresso.
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: CircularProgressIndicator(),
                  )
                else
                  // Caso contrário, mostramos o status normal.
                  Column(
                    children: [
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
                      Text(
                        'Versão $appVersion', // Dado vindo diretamente do provider.
                        style: textTheme.bodyMedium?.copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 24),

                // O botão de ação agora é controlado pelo estado `isLoading` e `isRunning`.
                ElevatedButton.icon(
                  onPressed: isLoading
                      ? null // Desabilita o botão enquanto o serviço está inicializando.
                      : () => context.findAncestorStateOfType<_HomeScreenState>()?._handleToggleService(),
                  icon: Icon(isRunning ? Icons.stop_circle_outlined : Icons.play_circle_outline),
                  label: Text(isRunning ? 'Parar Serviço' : 'Iniciar Serviço'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRunning ? Colors.red : Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(double.infinity, 50),
                    // Estilo para o estado desabilitado.
                    disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =================================================================================
// O resto dos widgets permanece o mesmo, pois não dependem do estado do serviço.
// =================================================================================

class _DeviceInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            ...mockInfo.entries.map((entry) => _buildInfoRow(entry.key, entry.value)).toList(),
          ],
        ),
      ),
    );
  }

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

class _CustomizationNavigationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRouter.customization);
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              const Icon(Icons.arrow_forward_ios, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
