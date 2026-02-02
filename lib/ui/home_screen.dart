
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shizuku/shizuku.dart'; // API Oficial
import 'package:usage_stats/usage_stats.dart';
import 'package:ziru/models/overlay_config.dart';
import 'package:ziru/ui/about_screen.dart';
import 'package:ziru/ui/customization_screen.dart';

// --- Classes e Enums Inalterados ---
class DeviceInfo{final String model;final String androidVersion;final String chipset;final double totalRamInGB;final double refreshRate;DeviceInfo({required this.model,required this.androidVersion,required this.chipset,required this.totalRamInGB,required this.refreshRate,});}
enum ShizukuStatus { NotInstalled, NotRunning, PermissionDenied, PermissionGranted }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Estados Inalterados ---
  bool _isServiceRunning = false;
  final String _appVersion = "v1.1.0";
  DeviceInfo? _deviceInfo;
  OverlayConfig _currentConfig = OverlayConfig();
  ShizukuStatus _shizukuStatus = ShizukuStatus.NotRunning;

  @override
  void initState() {
    super.initState();
    _initShizuku(); // Inicia a lógica do Shizuku com listeners
    _loadConfig();
    _checkServiceStatus();
    _loadDeviceInfo();
  }

  @override
  void dispose() {
    // Remove os listeners para evitar memory leaks
    Shizuku.removeBinderReceivedListener(_onBinderReceived);
    Shizuku.removeBinderDeadListener(_onBinderDead);
    Shizuku.removeRequestPermissionResultListener(_onRequestPermissionResult);
    super.dispose();
  }

  // *** LÓGICA DO SHIZUKU COM LISTENERS ***
  void _initShizuku() {
    // Adiciona os listeners para reagir a mudanças de estado do Shizuku
    Shizuku.addBinderReceivedListener(_onBinderReceived);
    Shizuku.addBinderDeadListener(_onBinderDead);
    Shizuku.addRequestPermissionResultListener(_onRequestPermissionResult);
  }

  void _onBinderReceived() {
    // Chamado quando o serviço Shizuku está conectado e rodando.
    // Agora, verificamos a permissão.
    _checkPermission();
  }

  void _onBinderDead() {
    // Chamado quando o serviço Shizuku morre ou é desconectado.
    if (mounted) {
      setState(() => _shizukuStatus = ShizukuStatus.NotRunning);
    }
  }

  void _onRequestPermissionResult(int grantResult) {
    // Chamado com o resultado do pedido de permissão.
    if (grantResult == 0) { // 0 = PERMISSION_GRANTED
      if (mounted) {
        setState(() => _shizukuStatus = ShizukuStatus.PermissionGranted);
      }
    } else {
      if (mounted) {
        setState(() => _shizukuStatus = ShizukuStatus.PermissionDenied);
      }
    }
  }

  Future<void> _checkPermission() async {
    // Verifica o status da permissão. Chamado quando o binder é recebido.
    try {
      if (await Shizuku.checkPermission() == 0) {
        _onRequestPermissionResult(0);
      } else {
        if (mounted) {
          setState(() => _shizukuStatus = ShizukuStatus.PermissionDenied);
        }
      }
    } catch (e) {
       if (mounted) {
          setState(() => _shizukuStatus = ShizukuStatus.NotRunning);
       }
    }
  }

  void _requestShizukuPermission() {
    // Apenas pede a permissão. O resultado será tratado pelo listener.
    Shizuku.requestPermission();
  }
  
  // --- Métodos de Configuração e UI (sem alterações da última versão) ---
  Future<void> _loadConfig() async {final prefs=await SharedPreferences.getInstance();final String?configJson=prefs.getString('overlay_config');if(configJson!=null){try{final Map<String,dynamic>configMap=jsonDecode(configJson);setState((){_currentConfig=OverlayConfig.fromJson(configMap);});}catch(e){}}}
  Future<void> _saveConfig(OverlayConfig config) async {final prefs=await SharedPreferences.getInstance();final String configJson=jsonEncode(config.toJson());await prefs.setString('overlay_config',configJson);}
  Future<void> _navigateToCustomization() async {final newConfig=await Navigator.push(context,MaterialPageRoute(builder:(context)=>CustomizationScreen(initialConfig:_currentConfig),),);if(newConfig!=null&&newConfig is OverlayConfig){setState((){_currentConfig=newConfig;});await _saveConfig(newConfig);if(_isServiceRunning){final String configJson=jsonEncode(_currentConfig.toJson());await FlutterOverlayWindow.shareData(configJson);}}}
  Future<void> _loadDeviceInfo() async {DeviceInfoPlugin deviceInfoPlugin=DeviceInfoPlugin();AndroidDeviceInfo androidInfo=await deviceInfoPlugin.androidInfo;double totalRam=(androidInfo.totalMem??0)/(1024*1024*1024);setState((){_deviceInfo=DeviceInfo(model:androidInfo.model??'Desconhecido',androidVersion:androidInfo.version.release??'Desconhecido',chipset:androidInfo.hardware??'Desconhecido',totalRamInGB:totalRam,refreshRate:androidInfo.displayMetrics.refreshRate??60.0,);});}
  Future<void> _checkServiceStatus() async {_isServiceRunning=await FlutterOverlayWindow.isActive()??false;setState((){});}
  Future<void> _toggleService() async {if(_isServiceRunning){await FlutterOverlayWindow.closeOverlay();setState(()=>_isServiceRunning=false);}else{if(!await _checkPermissions())return;final String configJson=jsonEncode(_currentConfig.toJson());await FlutterOverlayWindow.showOverlay(height:200,width:300,alignment:_getOverlayAlignment(_currentConfig.position),flag:OverlayFlag.focusPointer,data:configJson);setState(()=>_isServiceRunning=true);}}
  OverlayAlignment _getOverlayAlignment(String position){switch(position){case'topLeft':return OverlayAlignment.topLeft;case'topRight':return OverlayAlignment.topRight;case'bottomLeft':return OverlayAlignment.bottomLeft;case'bottomRight':return OverlayAlignment.bottomRight;default:return OverlayAlignment.topRight;}}
  Future<bool> _checkPermissions() async {if(!await UsageStats.checkUsagePermission()){_showPermissionDialog('Acesso a Dados de Uso',UsageStats.grantUsagePermission);return false;}if(!await FlutterOverlayWindow.isPermissionGranted()){_showPermissionDialog('Sobrepor outros apps',FlutterOverlayWindow.requestPermission);return false;}return true;}
  void _showPermissionDialog(String permissionName,VoidCallback onGrant){showDialog(context:context,builder:(context)=>AlertDialog(backgroundColor:const Color(0xFF1E1E1E),title:const Text('Permissão Necessária',style:TextStyle(color:Colors.white)),content:Text('A permissão "$permissionName" é necessária para o funcionamento do Ziru.',style:TextStyle(color:Colors.white70)),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancelar')),TextButton(onPressed:(){Navigator.pop(context);onGrant();},child:const Text('Conceder')),],),);}
  void _onMenuSelection(String value){if(value=='Sobre'){Navigator.push(context,MaterialPageRoute(builder:(context)=>const AboutScreen()));}}

  // --- Build e Widgets permanecem inalterados ---
  @override
  Widget build(BuildContext context){return Scaffold(appBar:AppBar(title:const Text('Ziru'),actions:[PopupMenuButton<String>(onSelected:_onMenuSelection,itemBuilder:(BuildContext context){return{'Sobreposição do modo de compatibilidade','Sobre'}.map((String choice){return PopupMenuItem<String>(value:choice,child:Text(choice));}).toList();},),],),body:SingleChildScrollView(padding:const EdgeInsets.all(16.0),child:Column(children:[_buildServiceStatusCard(),const SizedBox(height:16),_buildShizukuStatusCard(),const SizedBox(height:16),_buildDeviceInfoCard(),const SizedBox(height:16),_buildCustomizationCard(),],),),);}
  Widget _buildShizukuStatusCard(){String statusText;Color statusColor;Widget?actionButton;switch(_shizukuStatus){case ShizukuStatus.NotInstalled:statusText='Shizuku não instalado';statusColor=Colors.redAccent;actionButton=ElevatedButton(onPressed:(){},child:const Text('Aprenda a instalar'));break;case ShizukuStatus.NotRunning:statusText='Shizuku não está em execução';statusColor=Colors.orangeAccent;actionButton=ElevatedButton(onPressed:(){},child:const Text('Abrir Shizuku'));break;case ShizukuStatus.PermissionDenied:statusText='Permissão do Shizuku negada';statusColor=Colors.orangeAccent;actionButton=ElevatedButton(onPressed:_requestShizukuPermission,child:const Text('Conceder Permissão'));break;case ShizukuStatus.PermissionGranted:statusText='Permissão do Shizuku concedida';statusColor=Colors.greenAccent;actionButton=null;break;}return Card(color:const Color(0xFF1E1E1E),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),child:Padding(padding:const EdgeInsets.all(16.0),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(statusText,style:TextStyle(color:statusColor,fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:4),const Text('Necessário para o contador de FPS',style:TextStyle(color:Colors.white54,fontSize:14)),if(actionButton!=null)...[const SizedBox(height:20),Center(child:actionButton)],],),),);}
  Widget _buildServiceStatusCard(){return Card(color:const Color(0xFF1E1E1E),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),child:Padding(padding:const EdgeInsets.all(16.0),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(_isServiceRunning?'Serviço em execução':'Serviço parado',style:TextStyle(color:_isServiceRunning?Colors.greenAccent:Colors.white,fontSize:18,fontWeight:FontWeight.bold),),const SizedBox(height:4),Text(_appVersion,style:const TextStyle(color:Colors.white54,fontSize:14)),const SizedBox(height:20),Center(child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:_isServiceRunning?Colors.redAccent:Colors.blueAccent,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(8)),padding:const EdgeInsets.symmetric(horizontal:50,vertical:15),),onPressed:_toggleService,child:Text(_isServiceRunning?'Parar':'Iniciar',style:const TextStyle(fontSize:16)),),),),])));}
  Widget _buildDeviceInfoCard(){return Card(color:const Color(0xFF1E1E1E),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),child:Padding(padding:const EdgeInsets.all(16.0),child:_deviceInfo==null?const Center(child:CircularProgressIndicator(color:Colors.white,strokeWidth:2)):Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Informações do Dispositivo',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)),const SizedBox(height:12),_buildInfoRow('Modelo',_deviceInfo!.model),_buildInfoRow('Versão do Android',_deviceInfo!.androidVersion),_buildInfoRow('Processador',_deviceInfo!.chipset),_buildInfoRow('Memória RAM','${_deviceInfo!.totalRamInGB.toStringAsFixed(1)} GB'),_buildInfoRow('Taxa de Atualização','${_deviceInfo!.refreshRate.toStringAsFixed(0)} Hz'),],),),);}
  Widget _buildCustomizationCard(){return Card(color:const Color(0xFF1E1E1E),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),child:InkWell(onTap:_navigateToCustomization,borderRadius:BorderRadius.circular(12),child:const Padding(padding:EdgeInsets.all(16.0),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('Customização',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)),Icon(Icons.arrow_forward_ios,color:Colors.white54,size:16),],),),),);}
  Widget _buildInfoRow(String label,String value){return Padding(padding:const EdgeInsets.symmetric(vertical:4.0),child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(label,style:const TextStyle(color:Colors.white70,fontSize:14)),Text(value,style:const TextStyle(color:Colors.white,fontSize:14,fontWeight:FontWeight.w500)),],),);}

}
