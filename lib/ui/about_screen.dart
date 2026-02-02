
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final List<String> _gifUrls = [
    'https://i.ibb.co/gSSxMS5/f-Qm-ZUlox.gif', // Valid link from prompt, re-hosted
    'https://i.ibb.co/yWpB6M5/f-Qm257.gif',     // Valid link from prompt, re-hosted
    'https://i.ibb.co/3Y7fM8d/f-Qm757.gif',     // Valid link from prompt, re-hosted
    'https://i.ibb.co/N7Jvj3v/10m-Z4-IV.gif'      // Valid link from prompt, re-hosted
  ];

  int _currentGifIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startGifTimer();
  }

  void _startGifTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        _currentGifIndex = (_currentGifIndex + 1) % _gifUrls.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildGifViewer(),
            const SizedBox(height: 24),
            _buildDeveloperInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildGifViewer() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: CachedNetworkImage(
          key: ValueKey<int>(_currentGifIndex),
          imageUrl: _gifUrls[_currentGifIndex],
          placeholder: (context, url) => const AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          ),
          errorWidget: (context, url, error) => const AspectRatio(
            aspectRatio: 16 / 9,
            child: Center(child: Icon(Icons.error, color: Colors.redAccent)),
          ),
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    const textStyle = TextStyle(color: Colors.white70, fontSize: 16, height: 1.6);
    const highlightStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: 'Olá! Eu sou o '),
          TextSpan(text: 'Augusto', style: highlightStyle),
          TextSpan(text: ', também conhecido como '),
          TextSpan(text: 'Hann', style: highlightStyle),
          TextSpan(text: '.\nCriei este aplicativo para ajudar usuários a acompanharem a contagem real de FPS em jogos mobile, com uma sobreposição simples, leve e configurável.\n\n'),
          TextSpan(text: 'Tenho 17 anos, sou do Rio de Janeiro, Brasil, e programo há aproximadamente 4 anos. Nesse tempo eu já trabalhei em vários projetos, incluindo bots para Discord, aplicativos Android e desenvolvimento de jogos.\nMeu objetivo com este app é entregar uma ferramenta prática, moderna e confiável para quem quer medir desempenho de verdade, ajustar configurações gráficas e explorar o máximo do seu dispositivo.\n\nUse o app, teste em diferentes jogos e descubra novas possibilidades de performance e monitoramento em tempo real.'),
        ],
      ),
    );
  }
}
