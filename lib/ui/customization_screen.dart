
import 'package:flutter/material.dart';

class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({super.key});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  // State for 'Geral' section
  bool _hideInScreenshot = false;

  // State for 'Dados' section
  bool _showFps = true;
  bool _showAppName = true;
  bool _showCpuUsage = false;
  bool _showCpuFrequency = false;
  bool _showCpuTemp = false;
  bool _showGpuTemp = false;
  bool _showBatteryTemp = false;
  bool _showRamUsageAbsolute = false;
  bool _showRamUsagePercent = false;
  bool _showNetworkUpload = false;
  bool _showNetworkDownload = false;
  bool _showBatteryCurrent = false;
  bool _showBatteryVoltage = false;
  bool _showPowerConsumption = false;
  bool _showConsumptionPerFrame = false;

  // --- Helper method for building section titles ---
  Widget _buildSectionTitle(String title) { /* ... */ return Padding(padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),child: Text(title,style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold),),);}

  // --- Helper method for building toggle options ---
  Widget _buildToggleOption(String title, String subtitle, bool value, ValueChanged<bool> onChanged) { /* ... */ return ListTile(contentPadding: EdgeInsets.zero,title: Text(title, style: const TextStyle(color: Colors.white)),subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),trailing: Switch(value: value,onChanged: onChanged,activeColor: Colors.blueAccent,inactiveThumbColor: Colors.grey,),);}

  // --- Helper method for building checkbox options ---
  Widget _buildCheckboxOption(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blueAccent,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customização'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('GERAL'),
            _buildToggleOption(
              'Não mostrar nas capturas de tela',
              'Oculta a sobreposição em capturas e gravações de tela.',
              _hideInScreenshot,
              (newValue) => setState(() => _hideInScreenshot = newValue),
            ),

            _buildSectionTitle('PERSONALIZAR SOBREPOSIÇÃO - DADOS'),
            _buildCheckboxOption('FPS (Frames Per Second)', _showFps, (v) => setState(() => _showFps = v!)),
            _buildCheckboxOption('Aplicativo em uso (package name)', _showAppName, (v) => setState(() => _showAppName = v!)),
            _buildCheckboxOption('Utilização da CPU (%)', _showCpuUsage, (v) => setState(() => _showCpuUsage = v!)),
            _buildCheckboxOption('Frequência da CPU (por núcleo)', _showCpuFrequency, (v) => setState(() => _showCpuFrequency = v!)),
            _buildCheckboxOption('Temperatura da CPU (°C)', _showCpuTemp, (v) => setState(() => _showCpuTemp = v!)),
            _buildCheckboxOption('Temperatura da GPU (°C)', _showGpuTemp, (v) => setState(() => _showGpuTemp = v!)),
            _buildCheckboxOption('Temperatura da bateria (°C)', _showBatteryTemp, (v) => setState(() => _showBatteryTemp = v!)),
            _buildCheckboxOption('Uso de memória (RAM total em uso)', _showRamUsageAbsolute, (v) => setState(() => _showRamUsageAbsolute = v!)),
            _buildCheckboxOption('Uso de memória (%)', _showRamUsagePercent, (v) => setState(() => _showRamUsagePercent = v!)),
            _buildCheckboxOption('Velocidade de upload (rede)', _showNetworkUpload, (v) => setState(() => _showNetworkUpload = v!)),
            _buildCheckboxOption('Velocidade de download (rede)', _showNetworkDownload, (v) => setState(() => _showNetworkDownload = v!)),
            _buildCheckboxOption('Corrente da bateria (mA)', _showBatteryCurrent, (v) => setState(() => _showBatteryCurrent = v!)),
            _buildCheckboxOption('Tensão da bateria (V)', _showBatteryVoltage, (v) => setState(() => _showBatteryVoltage = v!)),
            _buildCheckboxOption('Consumo de energia (W)', _showPowerConsumption, (v) => setState(() => _showPowerConsumption = v!)),
            _buildCheckboxOption('Consumo por quadro (J/frame)', _showConsumptionPerFrame, (v) => setState(() => _showConsumptionPerFrame = v!)),
            
            _buildSectionTitle('PERSONALIZAR SOBREPOSIÇÃO - ESTILO E POSIÇÃO'),
            // ... Sliders and color pickers will go here ...
          ],
        ),
      ),
    );
  }
}
