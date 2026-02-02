
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:ziru/ui/about_screen.dart';
import 'package:ziru/ui/customization_screen.dart';

// Data model for device information
class DeviceInfo {
  final String model;
  final String androidVersion;
  final String chipset;
  final double totalRamInGB;
  final double refreshRate;

  DeviceInfo({
    required this.model,
    required this.androidVersion,
    required this.chipset,
    required this.totalRamInGB,
    required this.refreshRate,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isServiceRunning = false;
  final String _appVersion = "v1.0.0";
  DeviceInfo? _deviceInfo;

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    double totalRam = (androidInfo.totalMem ?? 0) / (1024 * 1024 * 1024);

    setState(() {
      _deviceInfo = DeviceInfo(
        model: androidInfo.model ?? 'Desconhecido',
        androidVersion: androidInfo.version.release ?? 'Desconhecido',
        chipset: androidInfo.hardware ?? 'Desconhecido',
        totalRamInGB: totalRam,
        refreshRate: androidInfo.displayMetrics.refreshRate ?? 60.0,
      );
    });
  }

  Future<void> _checkServiceStatus() async {
    final bool? isRunning = await FlutterOverlayWindow.isActive();
    setState(() {
      _isServiceRunning = isRunning ?? false;
    });
  }

  Future<void> _toggleService() async {
    if (_isServiceRunning) {
      await FlutterOverlayWindow.closeOverlay();
      setState(() => _isServiceRunning = false);
    } else {
      bool? usageStatsGranted = await UsageStats.checkUsagePermission();
      if (!(usageStatsGranted ?? false)) {
        _showPermissionDialog('Acesso a Dados de Uso', UsageStats.grantUsagePermission);
        return;
      }
      bool? overlayGranted = await FlutterOverlayWindow.isPermissionGranted();
      if (!(overlayGranted ?? false)) {
        _showPermissionDialog('Sobrepor outros apps', FlutterOverlayWindow.requestPermission);
        return;
      }
      await FlutterOverlayWindow.showOverlay(height: 150, width: 250, alignment: OverlayAlignment.topRight);
      setState(() => _isServiceRunning = true);
    }
  }

  void _showPermissionDialog(String permissionName, VoidCallback onGrant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Permissão Necessária', style: TextStyle(color: Colors.white)),
        content: Text('A permissão "$permissionName" é necessária para o funcionamento do Ziru.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(onPressed: () { Navigator.pop(context); onGrant(); }, child: const Text('Conceder')),
        ],
      ),
    );
  }

  void _onMenuSelection(String value) {
    if (value == 'Sobre') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
    }
    // Handle 'Sobreposição do modo de compatibilidade' later
  }

  void _navigateToCustomization() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomizationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ziru'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuSelection,
            itemBuilder: (BuildContext context) {
              return {'Sobreposição do modo de compatibilidade', 'Sobre'}.map((String choice) {
                return PopupMenuItem<String>(value: choice, child: Text(choice));
              }).toList();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildServiceStatusCard(),
            const SizedBox(height: 16),
            _buildDeviceInfoCard(),
            const SizedBox(height: 16),
            _buildCustomizationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStatusCard() { /* Redacted for brevity */ return Card(color:const Color(0xFF1E1E1E),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),child:Padding(padding:const EdgeInsets.all(16.0),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(_isServiceRunning ? 'Serviço em execução' : 'Serviço parado',style:TextStyle(color:_isServiceRunning ? Colors.greenAccent : Colors.white,fontSize:18,fontWeight:FontWeight.bold),),const SizedBox(height:4),Text(_appVersion,style:const TextStyle(color:Colors.white54,fontSize:14)),const SizedBox(height:20),Center(child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:_isServiceRunning ? Colors.redAccent : Colors.blueAccent,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(8)),padding:const EdgeInsets.symmetric(horizontal:50,vertical:15),),onPressed:_toggleService,child:Text(_isServiceRunning ? 'Parar' : 'Iniciar',style:const TextStyle(fontSize:16)),),),])));}

  Widget _buildDeviceInfoCard() { /* Redacted for brevity */ return Card(color: const Color(0xFF1E1E1E),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),child: Padding(padding: const EdgeInsets.all(16.0),child: _deviceInfo == null? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)): Column(crossAxisAlignment: CrossAxisAlignment.start,children: [const Text('Informações do Dispositivo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),const SizedBox(height: 12),_buildInfoRow('Modelo', _deviceInfo!.model),_buildInfoRow('Versão do Android', _deviceInfo!.androidVersion),_buildInfoRow('Processador', _deviceInfo!.chipset),_buildInfoRow('Memória RAM', '${_deviceInfo!.totalRamInGB.toStringAsFixed(1)} GB'),_buildInfoRow('Taxa de Atualização', '${_deviceInfo!.refreshRate.toStringAsFixed(0)} Hz'),],),),);}

  Widget _buildCustomizationCard() {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _navigateToCustomization,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Customização', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) { /* Redacted for brevity */ return Padding(padding: const EdgeInsets.symmetric(vertical: 4.0),child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),],),);}
}
