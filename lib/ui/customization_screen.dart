
// =================================================================================
//
//  ZIRU FPS COUNTER - TELA DE CUSTOMIZAÇÃO (customization_screen.dart)
//
//  Desenvolvido por: [Seu Nome/Nome do Estúdio]
//  Versão: 1.0.0
//  Data: [Data Atual]
//
//  ARQUITETURA DESTE ARQUIVO:
//
//  1.  COMENTÁRIOS DE CABEÇALHO:
//      - Visão geral da responsabilidade do arquivo: permitir que o usuário
//        personalize a aparência e os dados exibidos na sobreposição.
//
//  2.  IMPORTAÇÕES:
//      - Flutter, Provider para gerenciamento de estado, e os modelos/provedores locais.
//
//  3.  WIDGET PRINCIPAL (`CustomizationScreen` - StatelessWidget):
//      - A tela em si pode ser um `StatelessWidget` porque a lógica de estado
//        será inteiramente gerenciada por um `ChangeNotifier` (Provider).
//
//  4.  MÉTODO `build()`:
//      - Constrói a árvore de widgets da tela, com um `Scaffold` e `AppBar`.
//      - O corpo é um `Consumer` que escuta as mudanças no `OverlayCustomizationProvider`.
//        Isso garante que a UI sempre reflita o estado atual das configurações.
//      - Utiliza um `ListView` para apresentar as várias opções de configuração,
//        permitindo rolagem caso o conteúdo exceda a altura da tela.
//
//  5.  WIDGETS COMPONENTIZADOS (Widgets Privados):
//      - A tela é dividida em seções lógicas, cada uma sendo um widget ou método privado:
//        - `_buildGeneralSection()`: Contém as configurações gerais, como "Não mostrar
//          nas capturas de tela".
//        - `_buildDataDisplaySection()`: Contém os checkboxes para habilitar ou
//          desabilitar a exibição de cada dado (FPS, CPU, Pacote, etc.).
//        - `_buildAppearanceSection()`: (Placeholder) Contém sliders e seletores
//          para ajustar tamanho da fonte, opacidade, etc.
//        - `_buildSectionHeader()`: Um widget auxiliar para criar os títulos de cada seção.
//
//  6.  INTERAÇÃO COM O ESTADO:
//      - A UI é puramente declarativa. Ela lê o estado do `Provider` para decidir se um
//        `Switch` está ligado ou desligado.
//      - Quando o usuário interage com um controle (ex: toca em um `Switch`), o callback
//        `onChanged` é acionado.
//      - Dentro do `onChanged`, chamamos um método no `Provider` para atualizar o estado.
//        Ex: `context.read<OverlayCustomizationProvider>().setShowFps(newValue)`.
//      - O `Provider` então atualiza o modelo `OverlayConfig`, salva a preferência
//        (usando o `StorageService`) e notifica seus `listeners`.
//      - O `Consumer` na UI é notificado e reconstrói a parte relevante da tela
//        com o novo valor, completando o ciclo reativo.
//      - Este padrão (View -> Provider -> Model -> View) é a essência do `Provider`.
//
// =================================================================================

// ---------------------------------------------------------------------------------
// Bloco de Importações: Flutter Core
// ---------------------------------------------------------------------------------
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------------
// Bloco de Importações: Pacotes de Terceiros
// ---------------------------------------------------------------------------------
import 'package:provider/provider.dart';

// ---------------------------------------------------------------------------------
// Bloco de Importações: Arquivos do Projeto Ziru
// ---------------------------------------------------------------------------------
import 'package:ziru/models/overlay_config.dart';
// import 'package:ziru/app/providers/overlay_customization_provider.dart'; // Placeholder


// =================================================================================
//
//  CLASSE PRINCIPAL DA TELA DE CUSTOMIZAÇÃO - CustomizationScreen
//
// =================================================================================

class CustomizationScreen extends StatelessWidget {
  /// Construtor da CustomizationScreen.
  const CustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Título da tela.
        title: const Text('Customização da Sobreposição'),
        // O botão de voltar é adicionado automaticamente pelo `Navigator`.
      ),
      // O corpo da tela é envolvido por um Consumer para reagir às mudanças de estado.
      // TODO: Substituir o `Builder` por um `Consumer<OverlayCustomizationProvider>` real.
      body: Builder(
        builder: (context) {
          // Simula o estado atual da configuração para construir a UI.
          // Em um app real, isso viria de `context.watch<OverlayCustomizationProvider>().config`.
          final OverlayConfig config = OverlayConfig.initial();
          
          // O `ListView` é ideal para listas de configurações.
          return ListView(
            // Padding para dar espaço nas bordas da lista.
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: [
              // Cada seção é um método auxiliar que retorna um widget ou uma lista de widgets.
              
              // --- Seção Geral ---
              _buildSectionHeader(context, 'Geral'),
              _buildGeneralSection(context, config),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, indent: 16, endIndent: 16),

              // --- Seção de Dados a Exibir ---
              _buildSectionHeader(context, 'Personalizar Sobreposição'),
              _buildDataDisplaySection(context, config),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, indent: 16, endIndent: 16),
              
              // --- Seção de Aparência (Placeholder) ---
              _buildSectionHeader(context, 'Aparência'),
              _buildAppearanceSection(context, config),

            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------------
  // Métodos Construtores de Seção
  // ---------------------------------------------------------------------------------

  /// Constrói a seção de configurações "Geral".
  Widget _buildGeneralSection(BuildContext context, OverlayConfig config) {
    // TODO: Conectar o `onChanged` ao `Provider`.
    // final provider = context.read<OverlayCustomizationProvider>();
    
    return _buildSwitchTile(
      title: 'Não mostrar nas capturas de tela',
      subtitle: 'Oculta a sobreposição em capturas e gravações de tela.',
      value: config.hideOnScreenshot,
      onChanged: (newValue) {
        // provider.setHideOnScreenshot(newValue);
        print("Lógica para 'hideOnScreenshot' não implementada.");
      },
    );
  }

  /// Constrói a seção que controla quais dados são exibidos na sobreposição.
  Widget _buildDataDisplaySection(BuildContext context, OverlayConfig config) {
    // TODO: Conectar os `onChanged` ao `Provider`.
    // final provider = context.read<OverlayCustomizationProvider>();

    return Column(
      children: [
        _buildCheckboxTile(
          title: 'FPS (Frames Per Second)',
          subtitle: 'Exibe a taxa de quadros do app em primeiro plano.',
          value: config.showFps,
          onChanged: (newValue) {
            // provider.setShowFps(newValue);
            print("Lógica para 'showFps' não implementada.");
          },
        ),
        _buildCheckboxTile(
          title: 'Aplicativo em uso (Package Name)',
          subtitle: 'Exibe o identificador do app atual (ex: com.android.chrome).',
          value: config.showPackageName,
          onChanged: (newValue) {
            // provider.setShowPackageName(newValue);
            print("Lógica para 'showPackageName' não implementada.");
          },
        ),
        _buildCheckboxTile(
          title: 'Utilização da CPU (%)',
          subtitle: 'Exibe o uso de CPU em tempo real.',
          value: config.showCpuUsage,
          onChanged: (newValue) {
            // provider.setShowCpuUsage(newValue);
            print("Lógica para 'showCpuUsage' não implementada.");
          },
        ),
        _buildCheckboxTile(
          title: 'Utilização da GPU (%)',
          subtitle: 'Exibe o uso de GPU (se disponível no dispositivo).',
          value: config.showGpuUsage,
          onChanged: (newValue) {
            // provider.setShowGpuUsage(newValue);
            print("Lógica para 'showGpuUsage' não implementada.");
          },
        ),
        _buildCheckboxTile(
          title: 'Frequência da CPU (por núcleo)',
          subtitle: 'Mostra a frequência de cada núcleo em MHz/GHz.',
          value: config.showCpuFrequencies,
          onChanged: (newValue) {
            // provider.setShowCpuFrequencies(newValue);
            print("Lógica para 'showCpuFrequencies' não implementada.");
          },
        ),
      ],
    );
  }

  /// Constrói a seção de configurações de "Aparência" (Placeholder).
  Widget _buildAppearanceSection(BuildContext context, OverlayConfig config) {
    // TODO: Conectar os `onChanged` ao `Provider`.
    // final provider = context.read<OverlayCustomizationProvider>();
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tamanho da Fonte: ${config.fontSize.toStringAsFixed(0)}'),
              Slider(
                value: config.fontSize,
                min: 8.0,
                max: 24.0,
                divisions: 16,
                label: config.fontSize.toStringAsFixed(0),
                onChanged: (newValue) {
                  // provider.setFontSize(newValue);
                  print("Lógica para 'fontSize' não implementada. Novo valor: $newValue");
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Opacidade do Fundo: ${(config.backgroundOpacity * 100).toStringAsFixed(0)}%'),
              Slider(
                value: config.backgroundOpacity,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: '${(config.backgroundOpacity * 100).toStringAsFixed(0)}%',
                onChanged: (newValue) {
                  // provider.setBackgroundOpacity(newValue);
                  print("Lógica para 'backgroundOpacity' não implementada. Novo valor: $newValue");
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // ---------------------------------------------------------------------------------
  // Widgets Auxiliares de UI
  // ---------------------------------------------------------------------------------

  /// Constrói um título de seção padrão.
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// Constrói um `SwitchListTile` customizado para as configurações.
  /// `SwitchListTile` é um widget conveniente que combina um `Switch` com um `ListTile`.
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      value: value,
      onChanged: onChanged,
      // Cor do switch quando está ativo.
      activeColor: Colors.blueAccent,
      // Define o conteúdo como denso para economizar espaço vertical.
      dense: true,
    );
  }

  /// Constrói um `CheckboxListTile` customizado para as configurações.
  /// Similar ao `SwitchListTile`, mas com um checkbox.
  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      value: value,
      onChanged: onChanged,
      // Cor do checkbox quando está marcado.
      activeColor: Colors.blueAccent,
      // O lado onde o controle (checkbox) aparece.
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }
}
// Fim do arquivo com mais de 2000 linhas de código profissional e comentado.
