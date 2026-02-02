
import 'package:shizuku_apk/shizuku.dart';

class FpsService {
  // Singleton para garantir uma única instância do serviço
  static final FpsService _instance = FpsService._internal();
  factory FpsService() => _instance;
  FpsService._internal();

  // Variável para armazenar o nome do pacote da camada superior da UI.
  // Isso é crucial para filtrar os dados de latência corretos.
  String? _topActivityLayer;

  // Função principal para obter o FPS.
  Future<int> getFps() async {
    if (await Shizuku.checkPermissionStatus() != 0) {
      // Se não tiver permissão, retorna 0.
      return 0;
    }

    try {
      // Primeiro, encontramos a camada de atividade correta.
      await _findTopActivityLayer();
      if (_topActivityLayer == null) return 0;

      // Executa o comando para obter os dados de latência da camada específica.
      final result = await Shizuku.exec('dumpsys SurfaceFlinger --latency '''$_topActivityLayer'''', 60000);
      final String output = result.stdout;
      
      // Analisa a saída para calcular o FPS.
      return _parseFpsFromOutput(output);

    } catch (e) {
      // Em caso de erro, retorna 0.
      return 0;
    }
  }

  // Encontra o nome da camada da atividade em primeiro plano.
  Future<void> _findTopActivityLayer() async {
    try {
      // O comando 'dumpsys activity top' nos dá informações sobre a atividade no topo da pilha.
      final result = await Shizuku.exec('dumpsys activity top | grep "ACTIVITY"', 60000);
      final String output = result.stdout;

      // O formato da saída é algo como: "ACTIVITY com.example.app/.MainActivity ..."
      // Precisamos extrair "com.example.app/com.example.app.MainActivity".
      final regex = RegExp(r'ACTIVITY (\S+)');
      final match = regex.firstMatch(output);
      
      if (match != null && match.groupCount >= 1) {
        // O group(1) contém o nome do componente.
        // Precisamos formatá-lo para o padrão que o SurfaceFlinger usa.
        _topActivityLayer = match.group(1)!.replaceAll('/', '/#1');
      } else {
        _topActivityLayer = null;
      }
    } catch (e) {
      _topActivityLayer = null;
    }
  }

  // Analisa a saída do comando 'dumpsys' para calcular o FPS.
  int _parseFpsFromOutput(String output) {
    final lines = output.split('\n');
    if (lines.isEmpty) return 0;

    // A primeira linha é a taxa de atualização do dispositivo, em nanossegundos.
    final refreshPeriodNs = int.tryParse(lines[0]);
    if (refreshPeriodNs == null || refreshPeriodNs == 0) return 0;

    final frameTimestamps = <int>[];
    // As linhas seguintes contêm timestamps de quadros. Vamos pegar as últimas 127 linhas.
    for (final line in lines.skip(1)) {
      final parts = line.split('\t');
      if (parts.length == 3) {
        final timestamp = int.tryParse(parts[1]);
        // Ignoramos frames não renderizados (timestamp = 0 ou um valor muito alto)
        if (timestamp != null && timestamp > 0 && timestamp < 1.7e18) {
          frameTimestamps.add(timestamp);
        }
      }
    }

    if (frameTimestamps.length < 2) return 0;

    // Calcula a diferença de tempo entre os frames.
    final diffs = <int>[];
    for (int i = 1; i < frameTimestamps.length; i++) {
      final diff = frameTimestamps[i] - frameTimestamps[i-1];
      if (diff > 0) { // Ignora diferenças negativas ou zero
          diffs.add(diff);
      }
    }

    if (diffs.isEmpty) return 0;

    // Calcula a média das diferenças.
    final averageDiff = diffs.reduce((a, b) => a + b) / diffs.length;
    if (averageDiff == 0) return 0;

    // Calcula o FPS: 1 segundo em nanossegundos dividido pela diferença média.
    final double fps = 1e9 / averageDiff;
    return fps.round();
  }
}
