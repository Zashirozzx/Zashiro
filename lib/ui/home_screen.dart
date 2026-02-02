
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shizuku_apk/shizuku.dart'; // Import do Shizuku
import 'package:usage_stats/usage_stats.dart';
import 'package:ziru/models/overlay_config.dart';
import 'package:ziru/ui/about_screen.dart';
import 'package:ziru/ui/customization_screen.dart';

// DeviceInfo class (unchanged)
class DeviceInfo{final String model;final String androidVersion;final String chipset;final double totalRamInGB;final double refreshRate;DeviceInfo({required this.model,required this.androidVersion,required this.chipset,required this.totalRamInGB,required this.refreshRate,});}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Enum para o status do Shizuku
enum ShizukuStatus { NotInstalled, NotRunning, PermissionDenied, PermissionGranted }

class _HomeScreenState extends State<HomeScreen> {
  bool _isServiceRunning = false;
  final String _appVersion = "v1.1.0";
  DeviceInfo? _deviceInfo;
  OverlayConfig _currentConfig = OverlayConfig();

  // Estado do Shizuku
  ShizukuStatus _shizukuStatus = ShizukuStatus.NotInstalled;

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
    _loadDeviceInfo();
    _checkShizukuStatus(); // Verificar status do Shizuku na inicialização
  }

  Future<void> _checkShizukuStatus() async {
    try {
      bool isV11 = await Shizuku.isPreV11();
      if(isV11) { setState(() => _shizukuStatus = ShizukuStatus.NotInstalled); return; }

      bool isSui = await Shizuku.isSui();
      if(!isSui) { setState(() => _shizukuStatus = ShizukuStatus.NotInstalled); return; }

      int permission = await Shizuku.checkPermissionStatus();
      if(permission == 0) {
        setState(() => _shizukuStatus = ShizukuStatus.PermissionGranted);
      } else {
        setState(() => _shizukuStatus = ShizukuStatus.PermissionDenied);
      }
    } catch (e) {
      setState(() => _shizukuStatus = ShizukuStatus.NotRunning);
    }
  }
  
  Future<void> _requestShizukuPermission() async {
    bool granted = await Shizuku.requestPermission(60000);
    if (granted) {
      setState(() => _shizukuStatus = ShizukuStatus.PermissionGranted);
    } else {
      // Opcional: mostrar uma mensagem se o usuário negar
    }
  }

  Future<void> _loadDeviceInfo() async { /* Unchanged */ DeviceInfoPlugin deviceInfoPlugin=DeviceInfoPlugin();AndroidDeviceInfo androidInfo=await deviceInfoPlugin.androidInfo;double totalRam=(androidInfo.totalMem??0)/(1024*1024*1024);setState((){_deviceInfo=DeviceInfo(model:androidInfo.model??'Desconhecido',androidVersion:androidInfo.version.release??'Desconhecido',chipset:androidInfo.hardware??'Desconhecido',totalRamInGB:totalRam,refreshRate:androidInfo.displayMetrics.refreshRate??60.0,);});}
  Future<void> _checkServiceStatus() async { /* Unchanged */ _isServiceRunning=await FlutterOverlayWindow.isActive()??false;setState((){});}
  Future<void> _toggleService() async { /* Unchanged for now*/ if(_isServiceRunning){await FlutterOverlayWindow.closeOverlay();setState(()=>_isServiceRunning=false);}else{if(!await _checkPermissions())return;final String configJson=jsonEncode(_currentConfig.toJson());await FlutterOverlayWindow.showOverlay(height:200,width:300,alignment:_getOverlayAlignment(_currentConfig.position),flag:OverlayFlag.focusPointer,data:configJson);setState(()=>_isServiceRunning=true);}}
  OverlayAlignment _getOverlayAlignment(String position) { /* Unchanged */ switch(position){case'topLeft':return OverlayAlignment.topLeft;case'topRight':return OverlayAlignment.topRight;case'bottomLeft':return OverlayAlignment.bottomLeft;case'bottomRight':return OverlayAlignment.bottomRight;default:return OverlayAlignment.topRight;}}
  Future<bool> _checkPermissions() async { /* Unchanged */ if(!await UsageStats.checkUsagePermission()){_showPermissionDialog('Acesso a Dados de Uso',UsageStats.grantUsagePermission);return false;}if(!await FlutterOverlayWindow.isPermissionGranted()){_showPermissionDialog('Sobrepor outros apps',FlutterOverlayWindow.requestPermission);return false;}return true;}
  void _showPermissionDialog(String permissionName, VoidCallback onGrant) { /* Unchanged */ showDialog(context:context,builder:(context)=>AlertDialog(backgroundColor:const Color(0xFF1E1E1E),title:const Text('Permissão Necessária',style:TextStyle(color:Colors.white)),content:Text('A permissão "$permissionName" é necessária para o funcionamento do Ziru.',style:TextStyle(color:Colors.white70)),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancelar')),TextButton(onPressed:(){Navigator.pop(context);onGrant();},child:const Text('Conceder')),],),);}
  void _onMenuSelection(String value) { /* Unchanged */ if(value=='Sobre'){Navigator.push(context,MaterialPageRoute(builder:(context)=>const AboutScreen()));}}
  void _navigateToCustomization() async { /* Unchanged */ final newConfig=await Navigator.push(context,MaterialPageRoute(builder:(context)=>CustomizationScreen(initialConfig:_currentConfig),),);if(newConfig!=null&&newConfig is OverlayConfig){setState((){_currentConfig=newConfig;});if(_isServiceRunning){final String configJson=jsonEncode(_currentConfig.toJson());await FlutterOverlayWindow.shareData(configJson);}}}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ziru'), actions: [ /* Unchanged */ PopupMenuButton<String>(onSelected:_onMenuSelection,itemBuilder:(BuildContext context){return{'Sobreposição do modo de compatibilidade','Sobre'}.map((String choice){return PopupMenuItem<String>(value:choice,child:Text(choice));}).toList();},), ],),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildServiceStatusCard(),
            const SizedBox(height: 16),
            _buildShizukuStatusCard(), // Novo card adicionado!
            const SizedBox(height: 16),
            _buildDeviceInfoCard(),
            const SizedBox(height: 16),
            _buildCustomizationCard(),
          ],
        ),
      ),
    );
  }

  // *** NOVO WIDGET ***
  Widget _buildShizukuStatusCard() {
    String statusText;
    Color statusColor;
    Widget? actionButton;

    switch (_shizukuStatus) {
      case ShizukuStatus.NotInstalled:
        statusText = 'Shizuku não instalado';
        statusColor = Colors.redAccent;
        actionButton = ElevatedButton(onPressed: () { /* Link para o site */ }, child: const Text('Aprenda a instalar'));
        break;
      case ShizukuStatus.NotRunning:
        statusText = 'Shizuku não está em execução';
        statusColor = Colors.orangeAccent;
        actionButton = ElevatedButton(onPressed: () { /* Abrir Shizuku? */ }, child: const Text('Abrir Shizuku'));
        break;
      case ShizukuStatus.PermissionDenied:
        statusText = 'Permissão do Shizuku negada';
        statusColor = Colors.orangeAccent;
        actionButton = ElevatedButton(onPressed: _requestShizukuPermission, child: const Text('Conceder Permissão'));
        break;
      case ShizukuStatus.PermissionGranted:
        statusText = 'Permissão do Shizuku concedida';
        statusColor = Colors.greenAccent;
        actionButton = null;
        break;
    }

    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(statusText, style: TextStyle(color: statusColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Necessário para o contador de FPS', style: TextStyle(color: Colors.white54, fontSize: 14)),
            if (actionButton != null) ...[
              const SizedBox(height: 20),
              Center(child: actionButton),
            ]
          ],
        ),
      ),
    );
  }
  
  Widget _buildServiceStatusCard() { /* Unchanged */ return Card(color:const Color(0xFF1E1E1E),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),child:Padding(padding:const EdgeInsets.all(16.0),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(_isServiceRunning?'Serviço em execução':'Serviço parado',style:TextStyle(color:_isServiceRunning?Colors.greenAccent:Colors.white,fontSize:18,fontWeight:FontWeight.bold),),const SizedBox(height:4),Text(_appVersion,style:const TextStyle(color:Colors.white54,fontSize:14)),const SizedBox(height:20),Center(child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:_isServiceRunning?Colors.redAccent:Colors.blueAccent,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(8)),padding:const EdgeInsets.symmetric(horizontal:50,vertical:15),),onPressed:_toggleService,child:Text(_isServiceRunning?'Parar':'Iniciar',style:const TextStyle(fontSize:16)),),),),])));}
  Widget _buildDeviceInfoCard() { /* Unchanged */ return Card(color:const Color(0xFF1E1E1E),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),child:Padding(padding:const EdgeInsets.all(16.0),child:_deviceInfo==null?const Center(child:CircularProgressIndicator(color:Colors.white,strokeWidth:2)):Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Informações do Dispositivo',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:12),_buildInfoRow('Modelo',_deviceInfo!.model),_buildInfoRow('Versão do Android',_deviceInfo!.androidVersion),_buildInfoRow('Processador',_deviceInfo!.chipset),_buildInfoRow('Memória RAM','${_deviceInfo!.totalRamInGB.toStringAsFixed(1)} GB'),_buildInfoRow('Taxa de Atualização','${_deviceInfo!.refreshRate.toStringAsFixed(0)} Hz'),],),),);}
  Widget _buildCustomizationCard() { /* Unchanged */ return Card(color:const Color(0xFF1E1E1E),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),child:InkWell(onTap:_navigateToCustomization,borderRadius:BorderRadius.circular(12),child:const Padding(padding:EdgeInsets.all(16.0),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('Customização',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)),Icon(Icons.arrow_forward_ios,color:Colors.white54,size:16),],),),),);}
  Widget _buildInfoRow(String label,String value){return Padding(padding:const EdgeInsets.symmetric(vertical:4.0),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(label,style:const TextStyle(color:Colors.white70,fontSize:14)),Text(value,style:const TextStyle(color:Colors.white,fontSize:14,fontWeight:FontWeight.w500)),],),);}

}
