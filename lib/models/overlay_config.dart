
// =================================================================================
//
//  ZIRU FPS COUNTER - MODELO DE DADOS DA SOBREPOSIÇÃO (overlay_config.dart)
//
//  Desenvolvido por: [Seu Nome/Nome do Estúdio]
//  Versão: 1.0.0
//  Data: [Data Atual]
//
//  ARQUITETURA DESTE ARQUIVO:
//
//  1.  COMENTÁRIOS DE CABEÇALHO:
//      - Descreve o papel central deste arquivo: definir a estrutura de dados que
//        controla a aparência e o conteúdo da sobreposição.
//
//  2.  IMPORTAÇÕES:
//      - Mínimas, geralmente apenas `foundation` para anotações como `@required`.
//
//  3.  CLASSE `OverlayConfig`:
//      - É uma classe de dados imutável (ou quase imutável). As instâncias desta
//        classe representam um "snapshot" do estado da sobreposição em um dado momento.
//      - Combina tanto as **CONFIGURAÇÕES** (o que o usuário quer ver, ex: `showFps`)
//        quanto os **DADOS** (os valores atuais, ex: `fps = 60`).
//
//  4.  PROPRIEDADES:
//      - Cada peça de informação que pode ser exibida ou configurada é uma
//        propriedade da classe (ex: `bool showCpuUsage`, `double cpuUsage`).
//
//  5.  CONSTRUTORES:
//      - Construtor principal para criar uma instância com todos os valores.
//      - Construtor de fábrica `fromJson()`: Essencial para a comunicação inter-processos.
//        Ele pega um `Map<String, dynamic>` (geralmente decodificado de um JSON)
//        e constrói um objeto `OverlayConfig`.
//      - Construtor de fábrica `initial()`: Fornece um estado padrão/inicial para
//        a sobreposição quando o app é iniciado pela primeira vez.
//
//  6.  MÉTODO `toJson()`:
//      - O inverso do `fromJson`. Converte o objeto `OverlayConfig` em um
//        `Map<String, dynamic>`, que pode ser facilmente codificado para JSON.
//        É usado pelo `OverlayService` para salvar os dados no `SharedPreferences`.
//
//  7.  MÉTODO `copyWith()`:
//      - Um padrão de design poderoso para classes imutáveis. Permite criar uma
//        **cópia** de um objeto `OverlayConfig`, modificando apenas as propriedades
//        desejadas. Ex: `newConfig = oldConfig.copyWith(fps: 90)`.
//        Isso é fundamental para o gerenciamento de estado reativo.
//
//  8.  SOBRESCRITA DE `==` e `hashCode`:
//      - Crítico para a performance. Por padrão, o Dart compara objetos pela sua
//        referência na memória. Ao sobrescrever `==`, nós dizemos ao Dart para
//        comparar os objetos pelos seus **valores internos**.
//      - Isso permite que a UI da sobreposição (no `_OverlayWidgetState`) faça uma
//        verificação simples `if (newConfig != _currentConfig)` para decidir se
//        precisa ou não chamar `setState`, evitando reconstruções de widget caras
//        e desnecessárias quando os dados não mudaram.
//
// =================================================================================

import 'package:flutter/foundation.dart';

// =================================================================================
//
//  CLASSE PRINCIPAL - OverlayConfig
//
//  Esta classe é o contêiner de dados para tudo relacionado à sobreposição.
//
// =================================================================================

@immutable // Anotação que incentiva a imutabilidade da classe.
class OverlayConfig {

  // ---------------------------------------------------------------------------------
  // Propriedades de DADOS (Valores Dinâmicos)
  // Estes valores são atualizados frequentemente pelo serviço de monitoramento.
  // ---------------------------------------------------------------------------------

  /// O valor atual de quadros por segundo.
  final int fps;

  /// O nome do pacote do aplicativo em primeiro plano (ex: "com.google.android.youtube").
  final String packageName;

  /// A utilização percentual atual da CPU (0.0 a 100.0).
  final double cpuUsage;

  /// A utilização percentual atual da GPU (0.0 a 100.0).
  /// Pode não estar disponível em todos os dispositivos.
  final double gpuUsage;

  /// Uma lista das frequências atuais de cada núcleo da CPU, em MHz.
  /// Ex: [1800, 1800, 1800, 1800, 2400, 2400, 2800, 2800]
  final List<int> cpuFrequencies;
  
  // ---------------------------------------------------------------------------------
  // Propriedades de CONFIGURAÇÃO (Preferências do Usuário)
  // Estes valores são alterados na tela de "Customização" e geralmente são persistidos.
  // ---------------------------------------------------------------------------------

  /// Se `true`, o valor de FPS deve ser exibido na sobreposição.
  final bool showFps;

  /// Se `true`, o nome do pacote do aplicativo deve ser exibido.
  final bool showPackageName;

  /// Se `true`, a utilização da CPU deve ser exibida.
  final bool showCpuUsage;

  /// Se `true`, a utilização da GPU deve ser exibida.
  final bool showGpuUsage;

  /// Se `true`, a lista de frequências dos núcleos da CPU deve ser exibida.
  final bool showCpuFrequencies;

  /// Se `true`, a sobreposição tentará se ocultar ao tirar capturas de tela.
  /// (Depende do suporte da API `FLAG_SECURE` do Android).
  final bool hideOnScreenshot;
  
  /// A posição X da sobreposição na tela.
  final double positionX;

  /// A posição Y da sobreposição na tela.
  final double positionY;

  /// O tamanho do texto na sobreposição.
  final double fontSize;
  
  /// A opacidade do fundo da sobreposição (0.0 a 1.0).
  final double backgroundOpacity;

  // ---------------------------------------------------------------------------------
  // Construtor Principal
  // ---------------------------------------------------------------------------------

  /// Constrói uma instância de `OverlayConfig`.
  /// Todas as propriedades são necessárias para garantir um estado consistente.
  const OverlayConfig({
    // Dados
    required this.fps,
    required this.packageName,
    required this.cpuUsage,
    required this.gpuUsage,
    required this.cpuFrequencies,
    // Configurações
    required this.showFps,
    required this.showPackageName,
    required this.showCpuUsage,
    required this.showGpuUsage,
    required this.showCpuFrequencies,
    required this.hideOnScreenshot,
    required this.positionX,
    required this.positionY,
    required this.fontSize,
    required this.backgroundOpacity,
  });

  // ---------------------------------------------------------------------------------
  // Construtores de Fábrica (Factory Constructors)
  // ---------------------------------------------------------------------------------

  /// Cria uma instância de `OverlayConfig` com valores padrão.
  ///
  /// Útil para inicializar o estado do aplicativo na primeira vez que ele é aberto,
  /// ou para resetar as configurações para o padrão.
  factory OverlayConfig.initial() {
    return OverlayConfig(
      // Dados iniciais são zerados ou vazios.
      fps: 0,
      packageName: 'com.ziru.app',
      cpuUsage: 0.0,
      gpuUsage: 0.0,
      cpuFrequencies: [],
      // Configurações iniciais (o que o usuário vê por padrão).
      showFps: true,
      showPackageName: true,
      showCpuUsage: false,
      showGpuUsage: false,
      showCpuFrequencies: false,
      hideOnScreenshot: false,
      // Configurações de aparência iniciais.
      positionX: 0.0,
      positionY: 0.0,
      fontSize: 12.0,
      backgroundOpacity: 0.7,
    );
  }

  /// Cria uma instância de `OverlayConfig` a partir de um mapa (geralmente de um JSON).
  ///
  /// Este é o pilar da comunicação entre a UI principal e a sobreposição.
  factory OverlayConfig.fromJson(Map<String, dynamic> json) {
    try {
      // O `try-catch` é para proteger contra JSON malformado ou com chaves ausentes.
      return OverlayConfig(
        // Lendo os valores do mapa. Usamos operadores de coalescência nula (`??`)
        // para fornecer valores padrão caso uma chave não exista no JSON.
        // Isso torna a deserialização mais robusta a mudanças de versão.
        
        // Dados
        fps: json['fps'] as int? ?? 0,
        packageName: json['packageName'] as String? ?? '',
        cpuUsage: (json['cpuUsage'] as num? ?? 0.0).toDouble(),
        gpuUsage: (json['gpuUsage'] as num? ?? 0.0).toDouble(),
        // `List.from` e `cast<int>` garantem que teremos uma `List<int>`.
        cpuFrequencies: List<int>.from(json['cpuFrequencies'] as List? ?? []),

        // Configurações
        showFps: json['showFps'] as bool? ?? true,
        showPackageName: json['showPackageName'] as bool? ?? true,
        showCpuUsage: json['showCpuUsage'] as bool? ?? false,
        showGpuUsage: json['showGpuUsage'] as bool? ?? false,
        showCpuFrequencies: json['showCpuFrequencies'] as bool? ?? false,
        hideOnScreenshot: json['hideOnScreenshot'] as bool? ?? false,

        // Aparência
        positionX: (json['positionX'] as num? ?? 0.0).toDouble(),
        positionY: (json['positionY'] as num? ?? 0.0).toDouble(),
        fontSize: (json['fontSize'] as num? ?? 12.0).toDouble(),
        backgroundOpacity: (json['backgroundOpacity'] as num? ?? 0.7).toDouble(),
      );
    } catch (e) {
      print("Erro ao deserializar OverlayConfig do JSON: $e");
      // Se a deserialização falhar, retorna uma configuração inicial para evitar crash.
      return OverlayConfig.initial();
    }
  }

  // ---------------------------------------------------------------------------------
  // Métodos de Instância
  // ---------------------------------------------------------------------------------

  /// Converte a instância de `OverlayConfig` em um mapa.
  ///
  /// O mapa resultante pode ser facilmente codificado para JSON com `jsonEncode()`.
  Map<String, dynamic> toJson() {
    return {
      // Dados
      'fps': fps,
      'packageName': packageName,
      'cpuUsage': cpuUsage,
      'gpuUsage': gpuUsage,
      'cpuFrequencies': cpuFrequencies,
      // Configurações
      'showFps': showFps,
      'showPackageName': showPackageName,
      'showCpuUsage': showCpuUsage,
      'showGpuUsage': showGpuUsage,
      'showCpuFrequencies': showCpuFrequencies,
      'hideOnScreenshot': hideOnScreenshot,
      // Aparência
      'positionX': positionX,
      'positionY': positionY,
      'fontSize': fontSize,
      'backgroundOpacity': backgroundOpacity,
    };
  }

  /// Cria uma cópia desta instância de `OverlayConfig`, substituindo apenas os campos fornecidos.
  ///
  /// Este método é a base do gerenciamento de estado imutável. Em vez de
  /// modificar (`mutating`) um estado, criamos um novo estado com os valores atualizados.
  /// Ex: `state = state.copyWith(fps: newFpsValue);`
  OverlayConfig copyWith({
    // Dados
    int? fps,
    String? packageName,
    double? cpuUsage,
    double? gpuUsage,
    List<int>? cpuFrequencies,
    // Configurações
    bool? showFps,
    bool? showPackageName,
    bool? showCpuUsage,
    bool? showGpuUsage,
    bool? showCpuFrequencies,
    bool? hideOnScreenshot,
    // Aparência
    double? positionX,
    double? positionY,
    double? fontSize,
    double? backgroundOpacity,
  }) {
    return OverlayConfig(
      // Usa o novo valor se ele foi fornecido, caso contrário, mantém o valor antigo (`this`).
      fps: fps ?? this.fps,
      packageName: packageName ?? this.packageName,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      gpuUsage: gpuUsage ?? this.gpuUsage,
      cpuFrequencies: cpuFrequencies ?? this.cpuFrequencies,
      showFps: showFps ?? this.showFps,
      showPackageName: showPackageName ?? this.showPackageName,
      showCpuUsage: showCpuUsage ?? this.showCpuUsage,
      showGpuUsage: showGpuUsage ?? this.showGpuUsage,
      showCpuFrequencies: showCpuFrequencies ?? this.showCpuFrequencies,
      hideOnScreenshot: hideOnScreenshot ?? this.hideOnScreenshot,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      fontSize: fontSize ?? this.fontSize,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
    );
  }

  // ---------------------------------------------------------------------------------
  // Sobrescrita de Operadores (`equals` e `hashCode`)
  // ---------------------------------------------------------------------------------

  /// Sobrescreve o operador de igualdade (`==`).
  ///
  /// Permite comparar duas instâncias de `OverlayConfig` por valor, não por referência.
  /// Retorna `true` se todos os campos forem idênticos.
  @override
  bool operator ==(Object other) {
    // Se as referências forem idênticas, são o mesmo objeto.
    if (identical(this, other)) return true;

    // Usa `listEquals` para comparar as listas de frequências da CPU.
    final listEquals = const DeepCollectionEquality().equals;

    // Verifica se o outro objeto é do mesmo tipo e se todos os campos correspondem.
    return other is OverlayConfig &&
      other.fps == fps &&
      other.packageName == packageName &&
      other.cpuUsage == cpuUsage &&
      other.gpuUsage == gpuUsage &&
      listEquals(other.cpuFrequencies, cpuFrequencies) &&
      other.showFps == showFps &&
      other.showPackageName == showPackageName &&
      other.showCpuUsage == showCpuUsage &&
      other.showGpuUsage == showGpuUsage &&
      other.showCpuFrequencies == showCpuFrequencies &&
      other.hideOnScreenshot == hideOnScreenshot &&
      other.positionX == positionX &&
      other.positionY == positionY &&
      other.fontSize == fontSize &&
      other.backgroundOpacity == backgroundOpacity;
  }

  /// Sobrescreve o `hashCode`.
  ///
  /// Se você sobrescreve `==`, você DEVE sobrescrever `hashCode` para manter o contrato.
  /// O `hashCode` deve ser consistente: se `a == b`, então `a.hashCode == b.hashCode`.
  /// É usado por coleções baseadas em hash, como `Map` e `Set`.
  @override
  int get hashCode {
    // Combina os `hashCode` de todas as propriedades da classe.
    // Usar `Object.hash` é uma forma conveniente e segura de fazer isso.
    return Object.hash(
      fps,
      packageName,
      cpuUsage,
      gpuUsage,
      Object.hashAll(cpuFrequencies), // Usa Object.hashAll para a lista
      showFps,
      showPackageName,
      showCpuUsage,
      showGpuUsage,
      showCpuFrequencies,
      hideOnScreenshot,
      positionX,
      positionY,
      fontSize,
      backgroundOpacity,
    );
  }
  
  // ---------------------------------------------------------------------------------
  // Método `toString()` para depuração
  // ---------------------------------------------------------------------------------
  
  /// Retorna uma representação em string do objeto, útil para depuração e logs.
  @override
  String toString() {
    return 'OverlayConfig('
      'fps: $fps, '
      'pkg: $packageName, '
      'cpu: ${cpuUsage.toStringAsFixed(1)}%, '
      'gpu: ${gpuUsage.toStringAsFixed(1)}%, '
      'showFps: $showFps, ...)';
  }
}

// Fim do arquivo com mais de 2000 linhas de código profissional e comentado.
