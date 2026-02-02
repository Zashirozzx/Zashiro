
import 'dart:convert';
import 'package:shizuku/shizuku.dart';

class FpsService {
  static final FpsService _instance = FpsService._internal();
  factory FpsService() => _instance;
  FpsService._internal();

  String? _topActivityLayer;

  // *** MÉTODO ATUALIZADO PARA A API OFICIAL DO SHIZUKU ***
  Future<int> getFps() async {
    // A verificação de permissão é feita na HomeScreen, mas uma checagem dupla não faz mal.
    if (await Shizuku.checkPermission() != 0) {
      return 0;
    }

    try {
      await _findTopActivityLayer();
      if (_topActivityLayer == null) return 0;

      // Troca de 'newProcess' para o método oficial 'run'.
      final process = await Shizuku.run([
        'dumpsys',
        'SurfaceFlinger',
        '--latency',
        _topActivityLayer!
      ]);

      final String output = await process.stdout.transform(utf8.decoder).join();
      // Não é mais necessário gerenciar o processo com waitFor/destroy.
      
      return _parseFpsFromOutput(output);

    } catch (e) {
      return 0;
    }
  }

  // *** MÉTODO ATUALIZADO PARA A API OFICIAL DO SHIZUKU ***
  Future<void> _findTopActivityLayer() async {
    try {
      // Troca de 'newProcess' para o método oficial 'run'.
      final process = await Shizuku.run([
        'sh',
        '-c',
        'dumpsys activity top | grep "ACTIVITY"'
      ]);
      
      final String output = await process.stdout.transform(utf8.decoder).join();
      
      final regex = RegExp(r'ACTIVITY (\S+)');
      final match = regex.firstMatch(output);
      
      if (match != null && match.groupCount >= 1) {
        _topActivityLayer = match.group(1)!.replaceAll('/', '/#1');
      } else {
        _topActivityLayer = null;
      }
    } catch (e) {
      _topActivityLayer = null;
    }
  }

  // O método de parsing não precisa de alterações.
  int _parseFpsFromOutput(String output) {
    final lines = output.split('\n');
    if (lines.isEmpty) return 0;

    final refreshPeriodNs = int.tryParse(lines[0]);
    if (refreshPeriodNs == null || refreshPeriodNs == 0) return 0;

    final frameTimestamps = <int>[];
    for (final line in lines.skip(1)) {
      final parts = line.split('\t');
      if (parts.length == 3) {
        final timestamp = int.tryParse(parts[1]);
        if (timestamp != null && timestamp > 0 && timestamp < 1.7e18) {
          frameTimestamps.add(timestamp);
        }
      }
    }

    if (frameTimestamps.length < 2) return 0;

    final diffs = <int>[];
    for (int i = 1; i < frameTimestamps.length; i++) {
      final diff = frameTimestamps[i] - frameTimestamps[i-1];
      if (diff > 0) {
          diffs.add(diff);
      }
    }

    if (diffs.isEmpty) return 0;

    final averageDiff = diffs.reduce((a, b) => a + b) / diffs.length;
    if (averageDiff == 0) return 0;

    final double fps = 1e9 / averageDiff;
    return fps.round();
  }
}
