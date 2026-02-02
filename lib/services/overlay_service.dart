
import 'dart:async';
import 'dart:convert';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:ziru/models/overlay_config.dart';
import 'package:ziru/services/fps_service.dart'; // Importa o novo serviço

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});
  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  OverlayConfig _config = OverlayConfig();

  // Estado dos dados coletados
  String _currentApp = 'carregando...';
  int _batteryLevel = 0;
  int _fps = 0; // Novo estado para o FPS

  // Instância do serviço de FPS
  final FpsService _fpsService = FpsService();

  Timer? _dataFetchTimer;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _startDataFetchers();
  }

  @override
  void dispose() {
    _dataFetchTimer?.cancel();
    super.dispose();
  }

  void _setupListeners() { /* Unchanged */ FlutterOverlayWindow.getSharedData().then((data){if(data!=null){_updateConfig(data);}});FlutterOverlayWindow.shareData.listen(_updateConfig);}

  void _updateConfig(dynamic data) {
      if (data is Map<String, dynamic> || data is String) {
          try {
              final Map<String, dynamic> json = data is String ? jsonDecode(data) : data;
              if (mounted) {
                  setState(() {
                      _config = OverlayConfig.fromJson(json);
                  });
              }
          } catch (e) { /* log */ }
      }
  }

  void _startDataFetchers() {
    // O timer agora busca todos os dados, incluindo FPS
    _dataFetchTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final newApp = await _getForegroundApp();
      final newBatteryLevel = await Battery().batteryLevel;
      
      // Busca o FPS somente se a opção estiver habilitada na configuração
      final int newFps = _config.showFps ? await _fpsService.getFps() : 0;

      if (mounted) {
        setState(() {
          _currentApp = newApp;
          _batteryLevel = newBatteryLevel;
          _fps = newFps;
        });
      }
    });
  }

  Future<String> _getForegroundApp() async { /* Unchanged */ try{if(await UsageStats.checkUsagePermission()??false){DateTime endDate=DateTime.now();DateTime startDate=endDate.subtract(const Duration(minutes:5));List<UsageInfo>stats=await UsageStats.queryUsageStats(startDate,endDate);if(stats.isNotEmpty){stats.sort((a,b)=>(b.lastTimeUsed??0).compareTo(a.lastTimeUsed??0));return stats.first.packageName??"desconhecido";}}}catch(e){return"erro_perm_uso";}return"desconhecido";}

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _config.showBackground ? _config.backgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildOverlayContent(),
        ),
      ),
    );
  }

  List<Widget> _buildOverlayContent() {
    final textStyle = TextStyle(color: _config.textColor, fontSize: _config.textSize, fontWeight: FontWeight.bold, shadows: const [Shadow(blurRadius: 1.5, color: Colors.black54)]);

    List<Widget> content = [];

    if (_config.showAppName) {
      content.add(Text(_currentApp, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis));
    }

    // *** LÓGICA DE FPS ATUALIZADA ***
    if (_config.showFps) {
      // Mostra o FPS real coletado pelo serviço
      content.add(Text("FPS: $_fps", style: textStyle));
    }
    
    if (_config.showCpuUsage) { // Placeholder
       content.add(Text("CPU: --%", style: textStyle));
    }
    
    content.add(Text("Bateria: $_batteryLevel%", style: textStyle));

    if (content.isEmpty) {
      content.add(Text("Ziru", style: textStyle));
    }

    return content;
  }
}
