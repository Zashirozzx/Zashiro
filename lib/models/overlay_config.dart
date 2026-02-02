
import 'dart:ui';
import 'dart:convert';

// Modelo de dados para encapsular todas as configurações de customização do overlay.
class OverlayConfig {
  // Dados
  final bool showFps;
  final bool showAppName;
  final bool showCpuUsage;
  // ... (todas as outras flags de dados)

  // Estilo e Posição
  final double textSize;
  final Color textColor;
  final bool showBackground;
  final Color backgroundColor;
  final String position;
  final double horizontalOffset;
  final double verticalOffset;

  OverlayConfig({
    this.showFps = true,
    this.showAppName = true,
    this.showCpuUsage = true,
    this.textSize = 14.0,
    this.textColor = const Color(0xFFFFFFFF),
    this.showBackground = true,
    this.backgroundColor = const Color(0x80000000),
    this.position = 'topRight',
    this.horizontalOffset = 0.0,
    this.verticalOffset = 0.0,
  });

  // Método para converter o objeto para um Map, para que possa ser codificado em JSON.
  Map<String, dynamic> toJson() => {
        'showFps': showFps,
        'showAppName': showAppName,
        'showCpuUsage': showCpuUsage,
        'textSize': textSize,
        'textColor': textColor.value, // Salva a cor como um inteiro
        'showBackground': showBackground,
        'backgroundColor': backgroundColor.value,
        'position': position,
        'horizontalOffset': horizontalOffset,
        'verticalOffset': verticalOffset,
      };

  // Fábrica para criar um objeto a partir de um Map (decodificado de JSON).
  factory OverlayConfig.fromJson(Map<String, dynamic> json) => OverlayConfig(
        showFps: json['showFps'] ?? true,
        showAppName: json['showAppName'] ?? true,
        showCpuUsage: json['showCpuUsage'] ?? true,
        textSize: json['textSize'] ?? 14.0,
        textColor: Color(json['textColor'] ?? 0xFFFFFFFF),
        showBackground: json['showBackground'] ?? true,
        backgroundColor: Color(json['backgroundColor'] ?? 0x80000000),
        position: json['position'] ?? 'topRight',
        horizontalOffset: json['horizontalOffset'] ?? 0.0,
        verticalOffset: json['verticalOffset'] ?? 0.0,
      );
}
