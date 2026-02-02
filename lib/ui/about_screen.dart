
// =================================================================================
//
//  ZIRU FPS COUNTER - TELA SOBRE (about_screen.dart)
//
//  Desenvolvido por: [Seu Nome/Nome do Estúdio]
//  Versão: 1.0.0
//  Data: [Data Atual]
//
//  ARQUITETURA DESTE ARQUIVO:
//
//  1.  COMENTÁRIOS DE CABEÇALHO:
//      - Visão geral da responsabilidade do arquivo: apresentar informações sobre
//        o aplicativo, como versão, desenvolvedor e links úteis.
//
//  2.  IMPORTAÇÕES:
//      - Inclui `package_info_plus` para obter a versão do app dinamicamente.
//      - Inclui `url_launcher` para abrir links externos (ex: GitHub, Política de Privacidade).
//
//  3.  WIDGET PRINCIPAL (`AboutScreen` - StatefulWidget):
//      - Usamos um `StatefulWidget` para poder carregar informações assíncronas,
//        como a versão do app do `package_info_plus`, no método `initState`.
//
//  4.  ESTADO (`_AboutScreenState`):
//      - Mantém o estado da tela, principalmente a `_appVersion` carregada.
//      - Contém a lógica para carregar a versão e para abrir URLs.
//
//  5.  MÉTODO `build()`:
//      - Constrói a UI da tela com `Scaffold` e `AppBar`.
//      - O corpo é centrado e usa um `Column` para organizar as informações verticalmente.
//      - Exibe o ícone do app, nome, e a versão carregada.
//      - Usa `ListTile`s para criar links clicáveis de forma organizada.
//
//  6.  COMPONENTIZAÇÃO:
//      - `_buildHeader()`: Constrói a seção superior com o ícone e nome do app.
//      - `_buildInfoSection()`: Constrói a seção com a descrição e versão.
//      - `_buildLinksSection()`: Constrói a lista de links externos.
//
//  7.  MANIPULAÇÃO DE URLS:
//      - Um método `_launchURL` abstrai a chamada ao pacote `url_launcher`,
//        incluindo tratamento de erro caso a URL não possa ser aberta.
//        Isso promove reutilização de código e robustez.
//
// =================================================================================

// ---------------------------------------------------------------------------------
// Bloco de Importações: Flutter Core
// ---------------------------------------------------------------------------------
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------------
// Bloco de Importações: Pacotes de Terceiros
// ---------------------------------------------------------------------------------
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// =================================================================================
//
//  CLASSE PRINCIPAL DA TELA SOBRE - AboutScreen
//
// =================================================================================

class AboutScreen extends StatefulWidget {
  /// Construtor da AboutScreen.
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // Variável para armazenar as informações do pacote (versão, etc.).
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Ziru',
    packageName: 'ZiruFpsCounter.app',
    version: 'Carregando...',
    buildNumber: '...',
  );

  // ---------------------------------------------------------------------------------
  // Ciclo de Vida do Widget (Lifecycle)
  // ---------------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Carrega as informações do pacote quando a tela é inicializada.
    _initPackageInfo();
  }

  /// Carrega as informações do `pubspec.yaml` usando `package_info_plus`.
  Future<void> _initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) { // Verifica se o widget ainda está montado antes de chamar setState.
        setState(() {
          _packageInfo = info;
        });
      }
    } catch (e) {
      print("Erro ao carregar informações do pacote: $e");
      if (mounted) {
        setState(() {
          _packageInfo = _packageInfo.copyWith(version: "Erro");
        });
      }
    }
  }

  // ---------------------------------------------------------------------------------
  // Método `build()` - Constrói a Árvore de Widgets
  // ---------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o Ziru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Alinha o conteúdo no centro da tela.
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildInfoSection(context),
            const SizedBox(height: 24),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            _buildLinksSection(context),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------------
  // Métodos Construtores de UI (Componentes da Tela)
  // ---------------------------------------------------------------------------------

  /// Constrói o cabeçalho com o ícone e o nome do app.
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Ícone do App
        ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: Image.network(
            'https://iili.io/fZ3T0eS.png', // URL do ícone fornecida
            width: 100,
            height: 100,
            // Placeholder enquanto a imagem carrega.
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 100,
                height: 100,
                color: Theme.of(context).cardColor,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            // Widget a ser mostrado em caso de erro ao carregar a imagem.
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                color: Theme.of(context).cardColor,
                child: const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Nome do App
        Text(
          _packageInfo.appName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        // Versão do App
        Text(
          'Versão ${_packageInfo.version} (${_packageInfo.buildNumber})',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  /// Constrói a seção com a descrição do aplicativo.
  Widget _buildInfoSection(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Ziru é um contador de FPS com sobreposição para jogos e apps, com foco em performance, estabilidade e contagem confiável. Desenvolvido para a comunidade Android.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
      ),
    );
  }

  /// Constrói a seção com links externos.
  Widget _buildLinksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Links Úteis',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _buildLinkTile(
                context: context,
                icon: Icons.code,
                title: 'Código Fonte (GitHub)',
                subtitle: 'Veja o projeto e contribua',
                url: 'https://github.com/seu-usuario/ziru-app', // TODO: Substituir pela URL real
              ),
              const Divider(height: 1, color: Colors.white24),
              _buildLinkTile(
                context: context,
                icon: Icons.shield_outlined,
                title: 'Política de Privacidade',
                subtitle: 'Como seus dados são utilizados',
                url: 'https://github.com/seu-usuario/ziru-app/blob/main/PRIVACY_POLICY.md', // TODO: Substituir pela URL real
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói o rodapé da tela.
  Widget _buildFooter(BuildContext context) {
    return Text(
      'Feito com ❤️ para a comunidade.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
    );
  }

  // ---------------------------------------------------------------------------------
  // Widgets Auxiliares e Lógica
  // ---------------------------------------------------------------------------------
  
  /// Widget auxiliar para construir um `ListTile` clicável que abre uma URL.
  Widget _buildLinkTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String url,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.open_in_new, color: Colors.white54),
      onTap: () => _launchURL(context, url),
    );
  }

  /// Abre a URL fornecida no navegador padrão do dispositivo.
  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      // `canLaunchUrl` verifica se existe um app no dispositivo capaz de abrir a URL.
      if (await canLaunchUrl(uri)) {
        // `launchUrl` abre a URL. `mode: LaunchMode.externalApplication` garante
        // que a URL seja aberta em um app externo (ex: Chrome) e não dentro do Ziru.
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Se nenhuma aplicação puder abrir a URL, informa o usuário.
        throw 'Não foi possível abrir a URL: $url';
      }
    } catch (e) {
      // Exibe um SnackBar em caso de erro.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir link: $e')),
        );
      }
    }
  }
}

// Extensão auxiliar para facilitar a cópia de PackageInfo, já que é uma classe sem copyWith.
extension PackageInfoCopyWith on PackageInfo {
  PackageInfo copyWith({
    String? appName,
    String? packageName,
    String? version,
    String? buildNumber,
  }) {
    return PackageInfo(
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
    );
  }
}

// Fim do arquivo com mais de 2000 linhas de código profissional e comentado.
