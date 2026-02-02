
// =================================================================================
//
//  ZIRU FPS COUNTER - TELA DE CUSTOMIZAÇÃO (customization_screen.dart) - VERSÃO FUNCIONAL
//
//  Desenvolvido por: [Seu Nome/Nome do Estúdio]
//  Versão: 1.1.0 (Funcional)
//  Data: [Data Atual]
//
//  ARQUITETURA DESTE ARQUIVO (ATUALIZADA):
//
//  1.  WIDGET PRINCIPAL (`CustomizationScreen` - StatelessWidget):
//      - Permanece `Stateless` pois todo o estado é gerenciado pelo Provider.
//
//  2.  MÉTODO `build()`:
//      - O corpo agora é um `Consumer<OverlayCustomizationProvider>`.
//      - Ele lida com o estado de `isLoading` do provedor, mostrando um
//        `CircularProgressIndicator` enquanto as configurações são carregadas.
//      - Uma vez carregado, ele constrói a lista de configurações usando os dados
//        reais do `provider.config`.
//
//  3.  WIDGETS DE CONTROLE (CONECTADOS):
//      - Todos os widgets de controle (`SwitchListTile`, `CheckboxListTile`, `Slider`)
//        estão agora totalmente funcionais.
//      - A propriedade `value` de cada controle lê o estado do `provider.config`.
//      - O callback `onChanged` de cada controle chama o método de atualização
//        correspondente no `provider` (ex: `context.read<...>().updateShowFps(newValue)`).
//      - Usamos `context.read` dentro dos callbacks para despachar a ação sem
//        causar uma reconstrução desnecessária nesse ponto.
//
//  4.  FLUXO DE DADOS COMPLETO:
//      - Usuário toca em um switch.
//      - O callback `onChanged` chama o método no `OverlayCustomizationProvider`.
//      - O Provider cria um novo `OverlayConfig` com a mudança.
//      - O Provider salva a nova configuração no `StorageService`.
//      - O Provider envia a nova configuração para o `OverlayService` (atualização em tempo real).
//      - O Provider chama `notifyListeners()`.
//      - O `Consumer` na `CustomizationScreen` reconstrói a UI com os novos dados.
//      - O ciclo está completo.
//
// =================================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ziru/models/overlay_config.dart';
import 'package:ziru/providers/overlay_customization_provider.dart';

class CustomizationScreen extends StatelessWidget {
  const CustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customização da Sobreposição'),
      ),
      // O corpo da tela é envolvido por um Consumer para reagir às mudanças de estado.
      body: Consumer<OverlayCustomizationProvider>(
        builder: (context, provider, child) {
          // Enquanto as configurações estão sendo carregadas, mostra um indicador de progresso.
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Uma vez carregadas, constrói a lista de configurações.
          final OverlayConfig config = provider.config;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: [
              // Seção Geral
              _buildSectionHeader(context, 'Geral'),
              _buildGeneralSection(context, config),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, indent: 16, endIndent: 16),

              // Seção de Dados a Exibir
              _buildSectionHeader(context, 'Personalizar Sobreposição'),
              _buildDataDisplaySection(context, config),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, indent: 16, endIndent: 16),

              // Seção de Aparência
              _buildSectionHeader(context, 'Aparência'),
              _buildAppearanceSection(context, config),
            ],
          );
        },
      ),
    );
  }

  // Os métodos de construção de seção agora recebem o context para poder chamar o provider.

  Widget _buildGeneralSection(BuildContext context, OverlayConfig config) {
    final provider = context.read<OverlayCustomizationProvider>();
    return _buildSwitchTile(
      title: 'Não mostrar nas capturas de tela',
      subtitle: 'Oculta a sobreposição em capturas e gravações de tela.',
      value: config.hideOnScreenshot,
      onChanged: (newValue) => provider.updateHideOnScreenshot(newValue),
    );
  }

  Widget _buildDataDisplaySection(BuildContext context, OverlayConfig config) {
    final provider = context.read<OverlayCustomizationProvider>();
    return Column(
      children: [
        _buildCheckboxTile(
          title: 'FPS (Frames Per Second)',
          subtitle: 'Exibe a taxa de quadros do app em primeiro plano.',
          value: config.showFps,
          onChanged: (newValue) => provider.updateShowFps(newValue ?? false),
        ),
        _buildCheckboxTile(
          title: 'Aplicativo em uso (Package Name)',
          subtitle: 'Exibe o identificador do app atual.',
          value: config.showPackageName,
          onChanged: (newValue) => provider.updateShowPackageName(newValue ?? false),
        ),
        _buildCheckboxTile(
          title: 'Utilização da CPU (%)',
          subtitle: 'Exibe o uso de CPU em tempo real (requer root ou adb).',
          value: config.showCpuUsage,
          onChanged: (newValue) => provider.updateShowCpuUsage(newValue ?? false),
        ),
        _buildCheckboxTile(
          title: 'Utilização da GPU (%)',
          subtitle: 'Exibe o uso de GPU (se disponível no dispositivo).',
          value: config.showGpuUsage,
          onChanged: (newValue) => provider.updateShowGpuUsage(newValue ?? false),
        ),
        _buildCheckboxTile(
          title: 'Frequência da CPU (por núcleo)',
          subtitle: 'Mostra a frequência de cada núcleo em MHz/GHz.',
          value: config.showCpuFrequencies,
          onChanged: (newValue) => provider.updateShowCpuFrequencies(newValue ?? false),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context, OverlayConfig config) {
    final provider = context.read<OverlayCustomizationProvider>();
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
                onChanged: (newValue) => provider.updateFontSize(newValue),
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
                onChanged: (newValue) => provider.updateBackgroundOpacity(newValue),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------------
  // Widgets Auxiliares de UI (sem alterações)
  // ---------------------------------------------------------------------------------

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
      activeColor: Colors.blueAccent,
      dense: true,
    );
  }

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
      activeColor: Colors.blueAccent,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }
}
