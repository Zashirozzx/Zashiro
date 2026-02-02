
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ziru/models/overlay_config.dart';

class CustomizationScreen extends StatefulWidget {
  final OverlayConfig initialConfig;

  const CustomizationScreen({super.key, required this.initialConfig});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

enum OverlayPosition { topLeft, topRight, bottomLeft, bottomRight }

class _CustomizationScreenState extends State<CustomizationScreen> {
  // Local state for all UI controls
  late bool _showFps, _showAppName, _showCpuUsage;
  late double _textSize;
  late Color _textColor;
  late bool _showBackground;
  late Color _backgroundColor;
  late OverlayPosition _overlayPosition;
  late double _horizontalOffset, _verticalOffset;

  @override
  void initState() {
    super.initState();
    // Initialize local state from the config passed to the widget
    final config = widget.initialConfig;
    _showFps = config.showFps;
    _showAppName = config.showAppName;
    _showCpuUsage = config.showCpuUsage;
    _textSize = config.textSize;
    _textColor = config.textColor;
    _showBackground = config.showBackground;
    _backgroundColor = config.backgroundColor;
    _overlayPosition = OverlayPosition.values.firstWhere((e) => e.name == config.position, orElse: () => OverlayPosition.topRight);
    _horizontalOffset = config.horizontalOffset;
    _verticalOffset = config.verticalOffset;
  }

  // Method to create a new OverlayConfig from the current local state
  OverlayConfig _buildCurrentConfig() {
    return OverlayConfig(
      showFps: _showFps,
      showAppName: _showAppName,
      showCpuUsage: _showCpuUsage,
      textSize: _textSize,
      textColor: _textColor,
      showBackground: _showBackground,
      backgroundColor: _backgroundColor,
      position: _overlayPosition.name,
      horizontalOffset: _horizontalOffset,
      verticalOffset: _verticalOffset,
    );
  }

  // UI Helper methods (unchanged)
  Widget _buildSectionTitle(String title) { return Padding(padding: const EdgeInsets.only(top: 24.0, bottom: 8.0), child: Text(title, style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold))); }
  Widget _buildCheckboxOption(String title, bool value, ValueChanged<bool?> onChanged) { return CheckboxListTile(title: Text(title, style: const TextStyle(color: Colors.white)), value: value, onChanged: onChanged, activeColor: Colors.blueAccent, controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero); }
  Widget _buildToggleOption(String title, String subtitle, bool value, ValueChanged<bool> onChanged) { return SwitchListTile(title: Text(title, style: const TextStyle(color: Colors.white)), subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)), value: value, onChanged: onChanged, activeColor: Colors.blueAccent, contentPadding: EdgeInsets.zero); }
  Widget _buildSliderOption(String title, double value, double min, double max, ValueChanged<double> onChanged) { return ListTile(contentPadding: EdgeInsets.zero, title: Text(title, style: const TextStyle(color: Colors.white)), subtitle: Slider(value: value, min: min, max: max, divisions: (max - min).toInt(), label: value.round().toString(), onChanged: onChanged, activeColor: Colors.blueAccent), trailing: Text(value.round().toString(), style: const TextStyle(color: Colors.white, fontSize: 16)));}
  Widget _buildColorPickerOption(String title, Color color, ValueChanged<Color> onColorChanged) { return ListTile(contentPadding: EdgeInsets.zero, title: Text(title, style: const TextStyle(color: Colors.white)), trailing: GestureDetector(onTap: () => _showColorPickerDialog(color, onColorChanged), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white54))),));}
  void _showColorPickerDialog(Color initialColor, ValueChanged<Color> onColorChanged) { showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Selecione uma cor'), content: SingleChildScrollView(child: ColorPicker(pickerColor: initialColor, onColorChanged: onColorChanged)), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('FECHAR'))]));}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customização'),
        // The back button will now automatically pop the scope
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _buildCurrentConfig()),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, _buildCurrentConfig());
          return true;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('DADOS NA SOBREPOSIÇÃO'),
              _buildCheckboxOption('FPS (Frames Per Second)', _showFps, (v) => setState(() => _showFps = v!)),
              _buildCheckboxOption('Aplicativo em uso (package name)', _showAppName, (v) => setState(() => _showAppName = v!)),
              _buildCheckboxOption('Utilização da CPU (%)', _showCpuUsage, (v) => setState(() => _showCpuUsage = v!)),
              
              _buildSectionTitle('ESTILO E POSIÇÃO'),
              _buildSliderOption('Tamanho do texto', _textSize, 8, 32, (v) => setState(() => _textSize = v)),
              _buildColorPickerOption('Cor do texto', _textColor, (c) => setState(() => _textColor = c)),
              _buildToggleOption('Fundo', 'Liga/desliga fundo atrás do texto', _showBackground, (v) => setState(() => _showBackground = v)),
              if (_showBackground) _buildColorPickerOption('Cor de fundo', _backgroundColor, (c) => setState(() => _backgroundColor = c)),
              
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Posição', style: TextStyle(color: Colors.white)),
                trailing: DropdownButton<OverlayPosition>(
                  value: _overlayPosition,
                  dropdownColor: const Color(0xFF1E1E1E),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) => setState(() => _overlayPosition = v!),
                  items: OverlayPosition.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                ),
              ),
              _buildSliderOption('Deslocamento horizontal', _horizontalOffset, -100, 100, (v) => setState(() => _horizontalOffset = v)),
              _buildSliderOption('Deslocamento vertical', _verticalOffset, -100, 100, (v) => setState(() => _verticalOffset = v)),
            ],
          ),
        ),
      ),
    );
  }
}
