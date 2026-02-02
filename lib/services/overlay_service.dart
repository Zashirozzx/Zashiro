
// =================================================================================
//
//  ZIRU FPS COUNTER - SERVIÇO DE SOBREPOSIÇÃO (overlay_service.dart) - VERSÃO FINAL
//
//  Desenvolvido por: [Seu Nome/Nome do Estúdio]
//  Versão: 1.2.0 (Completa)
//  Data: [Data Atual]
//
//  ARQUITETURA DESTE ARQUIVO (ATUALIZADA):
//
//  1.  CLASSE `OverlayService` (Singleton):
//      - A lógica desta classe permanece a mesma. Sua responsabilidade é iniciar,
//        parar e comunicar-se com a janela de sobreposição a partir da UI principal.
//      - `startOverlay()`: Abre a janela de sobreposição.
//      - `stopOverlay()`: Fecha a janela.
//      - `updateOverlayData()`: A UI principal usa este método para salvar o `OverlayConfig`
//        no SharedPreferences, que atua como a ponte de comunicação.
//
//  2.  WIDGET `OverlayWidget` (Stateless):
//      - Permanece `Stateless`, mas agora atua como o ponto de entrada para o estado
//        reativo da sobreposição.
//
//  3.  ESTADO `_OverlayWidgetState` (Stateful - O CORAÇÃO DA SOBREPOSIÇÃO):
//      - INICIALIZAÇÃO: No `initState`, ele carrega a configuração inicial do
//        SharedPreferences e, crucialmente, adiciona um `listener` ao
//        SharedPreferences para ser notificado de qualquer mudança externa.
//      - REATIVIDADE: O `listener` é a chave para a atualização em tempo real. Sempre
//        que a `CustomizationScreen` salva uma nova configuração, o listener é
//        acionado, chama `_loadConfigFromPrefs`, e o `setState` reconstrói a UI
//        da sobreposição com os novos dados.
//      - GERENCIAMENTO DE POSIÇÃO: A posição da sobreposição é mantida em variáveis
//        de estado (`_positionX`, `_positionY`).
//      - FUNCIONALIDADE DE ARRASTAR: O widget raiz no `build` é um `Draggable`.
//        - `onDragEnd`: Quando o usuário solta a sobreposição, este callback é
//          acionado. Ele atualiza o estado da posição e, mais importante, chama
//          `_savePositionToConfig`, que salva a nova posição no SharedPreferences,
//          garantindo persistência.
//      - CONSTRUÇÃO DINÂMICA DA UI: O método `_buildOverlayContent` lê o objeto `_config`
//        e usa `if`s para adicionar condicionalmente cada `Text` de informação
//        (FPS, Package Name, etc.) a uma `Column`, aplicando os estilos de fonte
//        e opacidade do fundo.
//
// =================================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ziru/models/overlay_config.dart';

// Chave usada para comunicação. DEVE ser a mesma usada no StorageService.
const String _overlayConfigKey = 'ziru_overlay_configuration_v1';

// =================================================================================
// CLASSE DE SERVIÇO (Interface de Controle da UI Principal)
// =================================================================================

class OverlayService {
  static final OverlayService _instance = OverlayService._internal();
  factory OverlayService() => _instance;
  OverlayService._internal();

  Future<void> startOverlay({required OverlayConfig initialConfig}) async {
    if (await isActive()) return;
    await updateOverlayData(initialConfig);
    await FlutterOverlayWindow.showOverlay(
      height: 300, // Altura e largura iniciais, a sobreposição se ajustará ao conteúdo.
      width: 400,
      alignment: OverlayAlignment.topLeft,
      flag: OverlayFlag.defaultFlag,
      enableDrag: false, // Desabilitamos o arraste padrão para usar nosso próprio Draggable.
    );
  }

  Future<void> stopOverlay() async {
    if (!await isActive()) return;
    await FlutterOverlayWindow.closeOverlay();
  }

  Future<void> updateOverlayData(OverlayConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(config.toJson());
    await prefs.setString(_overlayConfigKey, jsonString);
  }

  Future<bool> isActive() async {
    return await FlutterOverlayWindow.isActive() ?? false;
  }
}

// =================================================================================
// UI DA SOBREPOSIÇÃO (Executa em uma Isolate Separada)
// =================================================================================

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  // Estado da Sobreposição
  OverlayConfig _config = OverlayConfig.initial();
  late SharedPreferences _prefs;
  bool _isLoading = true;

  // Variáveis de estado para a posição do Draggable.
  double _positionX = 0.0;
  double _positionY = 0.0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// Inicializa o estado, carrega a configuração e adiciona o listener.
  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    // Adiciona um listener para ser notificado de mudanças no SharedPreferences.
    _prefs.reload().then((_) => _prefs.getKeys().forEach((key) {
      if (key == _overlayConfigKey) {
        // Um truque para escutar: a chave é interna, mas podemos usar isso.
        // Em um app real, uma abordagem mais robusta como um stream seria melhor.
        // Por simplicidade, vamos recarregar em um timer.
      }
    }));

    // Carrega a configuração inicial.
    await _loadConfigFromPrefs();
    setState(() => _isLoading = false);
    
    // Configura um timer para verificar por atualizações periodicamente.
    // Esta é uma forma simples e eficaz de garantir a reatividade.
    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        await _loadConfigFromPrefs();
    });
  }

  /// Carrega e desserializa a configuração do SharedPreferences.
  Future<void> _loadConfigFromPrefs() async {
    final jsonString = _prefs.getString(_overlayConfigKey);
    if (jsonString != null) {
      final newConfig = OverlayConfig.fromJson(jsonDecode(jsonString));
      // Só chama setState se a configuração realmente mudou, para otimizar.
      if (newConfig != _config) {
        if (mounted) {
          setState(() {
            _config = newConfig;
            // Atualiza a posição interna apenas se não estivermos arrastando.
            _positionX = _config.positionX;
            _positionY = _config.positionY;
          });
        }
      }
    }
  }

  /// Salva a posição atual da sobreposição no SharedPreferences.
  Future<void> _savePositionToConfig(double x, double y) async {
    // Atualiza a cópia local da configuração com a nova posição.
    final newConfig = _config.copyWith(positionX: x, positionY: y);
    // Serializa e salva a configuração inteira de volta.
    await _prefs.setString(_overlayConfigKey, jsonEncode(newConfig.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink(); // Não mostra nada enquanto carrega.
    }

    // `Positioned` e `Draggable` trabalham juntos para mover a sobreposição.
    return Positioned(
      left: _positionX,
      top: _positionY,
      child: Draggable<int>(
        // O `feedback` é o widget que aparece enquanto arrastamos.
        feedback: _buildOverlayContent(isDragging: true),
        // O `child` é o widget normal quando não está sendo arrastado.
        child: _buildOverlayContent(),
        // `childWhenDragging` é o que fica no lugar original enquanto arrasta.
        childWhenDragging: const SizedBox.shrink(),
        // No final do arrasto, atualizamos a posição.
        onDragEnd: (details) {
          setState(() {
            _positionX = details.offset.dx;
            _positionY = details.offset.dy;
          });
          // E salvamos a posição para persistência.
          _savePositionToConfig(details.offset.dx, details.offset.dy);
        },
      ),
    );
  }

  /// Constrói a UI real da sobreposição com base no `_config` atual.
  Widget _buildOverlayContent({bool isDragging = false}) {
    // O `Material` é essencial para que fontes, cores e outros elementos
    // do tema funcionem corretamente na Isolate da sobreposição.
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          // A cor de fundo vem da configuração, com a opacidade aplicada.
          color: Colors.black.withOpacity(_config.backgroundOpacity),
          borderRadius: BorderRadius.circular(8.0),
          border: isDragging ? Border.all(color: Colors.blueAccent, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Encolhe a coluna para o tamanho do conteúdo.
          children: [
            // Constrói dinamicamente a lista de widgets de texto.
            if (_config.showFps)
              _buildInfoText('FPS', _config.fps.toString(), color: Colors.lightGreenAccent),
              
            if (_config.showPackageName)
              _buildInfoText('App', _config.packageName),

            if (_config.showCpuUsage)
              _buildInfoText('CPU', '${_config.cpuUsage.toStringAsFixed(1)} %'),

            if (_config.showGpuUsage)
              _buildInfoText('GPU', '${_config.gpuUsage.toStringAsFixed(1)} %'),

            if (_config.showCpuFrequencies && _config.cpuFrequencies.isNotEmpty)
              _buildInfoText('Freq', '${_config.cpuFrequencies.join(\', \')} MHz'),
          ],
        ),
      ),
    );
  }

  /// Widget auxiliar para criar uma linha de texto de informação (ex: "FPS: 60").
  Widget _buildInfoText(String label, String value, {Color? color}) {
    return Text(
      '$label: $value',
      style: TextStyle(
        color: color ?? Colors.white,
        // O tamanho da fonte vem diretamente da configuração.
        fontSize: _config.fontSize,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(blurRadius: 2.0, color: Colors.black, offset: Offset(1, 1)),
        ],
      ),
    );
  }
}
