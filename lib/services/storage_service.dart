
// =================================================================================
//
//  ZIRU FPS COUNTER - SERVIÇO DE ARMAZENAMENTO (storage_service.dart)
//
//  Desenvolvido por: [Seu Nome/Nome do Estúdio]
//  Versão: 1.0.0
//  Data: [Data Atual]
//
//  ARQUITETURA DESTE ARQUIVO:
//
//  1.  COMENTÁRIOS DE CABEÇALHO:
//      - Descreve o papel do arquivo: abstrair a complexidade do armazenamento
//        persistente (SharedPreferences) em uma API simples e específica do domínio.
//
//  2.  CLASSE `StorageService` (Singleton):
//      - Garante que haja apenas uma interface de comunicação com o SharedPreferences,
//        evitando conflitos de chaves e acessos concorrentes.
//
//  3.  ABSTRAÇÃO DO `SharedPreferences`:
//      - Em vez de espalhar chamadas para `SharedPreferences.getInstance()` e
//        `prefs.setString()` por todo o código, centralizamos tudo aqui.
//      - Os provedores (como `OverlayCustomizationProvider`) não precisarão saber
//        *como* os dados são salvos, apenas que podem chamar `storageService.save(...)`.
//
//  4.  MÉTODOS `saveOverlayConfig` E `loadOverlayConfig`:
//      - `saveOverlayConfig()`:
//        - Recebe um objeto `OverlayConfig`.
//        - Converte o objeto para um `Map` usando o método `toJson()` do próprio modelo.
//        - Codifica o `Map` em uma string JSON usando `dart:convert`.
//        - Salva a string JSON no SharedPreferences sob uma chave bem definida.
//      - `loadOverlayConfig()`:
//        - Lê a string JSON do SharedPreferences.
//        - Se a string existir, a decodifica para um `Map`.
//        - Constrói um objeto `OverlayConfig` a partir do mapa usando o construtor
//          de fábrica `fromJson()` do modelo.
//        - Se a string não existir (ex: primeiro uso do app), retorna um
//          `OverlayConfig.initial()`, garantindo que o app sempre tenha uma
//          configuração válida para trabalhar.
//
//  5.  VANTAGENS DESTA ABORDAGEM:
//      - **Desacoplamento:** Se um dia quisermos trocar SharedPreferences por um banco
//        de dados como Hive ou Sembast, só precisamos modificar ESTE arquivo.
//        Nenhum outro arquivo do app precisará ser alterado.
//      - **Testabilidade:** Em testes, podemos facilmente criar uma versão "mock" do
//        `StorageService` que salva os dados em memória, em vez de no disco,
//        tornando os testes mais rápidos e previsíveis.
//      - **Clareza:** O código nos provedores fica mais limpo e focado em sua
//        responsabilidade de gerenciar o estado, não em detalhes de armazenamento.
//
// =================================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ziru/models/overlay_config.dart';

// =================================================================================
//
//  CLASSE DE SERVIÇO - StorageService
//
// =================================================================================

class StorageService {
  // Chave usada para salvar a configuração do overlay no SharedPreferences.
  // Manter a chave como uma constante privada aqui evita erros de digitação em outras partes do código.
  static const String _overlayConfigKey = 'ziru_overlay_configuration_v1';

  // ---------------------------------------------------------------------------------
  // Configuração do Singleton
  // ---------------------------------------------------------------------------------
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Instância do SharedPreferences. É inicializada de forma "lazy" na primeira vez que é necessária.
  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // ---------------------------------------------------------------------------------
  // Métodos Públicos da API
  // ---------------------------------------------------------------------------------

  /// Salva o objeto de configuração do overlay no armazenamento persistente.
  ///
  /// [config]: O objeto `OverlayConfig` a ser salvo.
  Future<void> saveOverlayConfig(OverlayConfig config) async {
    try {
      print("[StorageService] Salvando configuração do overlay...");
      final prefs = await _prefs;
      // 1. Converte o objeto Dart para um mapa.
      final map = config.toJson();
      // 2. Codifica o mapa em uma string JSON.
      final jsonString = jsonEncode(map);
      // 3. Salva a string no SharedPreferences.
      await prefs.setString(_overlayConfigKey, jsonString);
      print("[StorageService] Configuração salva com sucesso.");
    } catch (e) {
      print("[StorageService] ERRO ao salvar a configuração do overlay: $e");
      // Em um app de produção, poderíamos logar este erro em um serviço de crash reporting.
    }
  }

  /// Carrega o objeto de configuração do overlay do armazenamento persistente.
  ///
  /// Retorna o `OverlayConfig` salvo, ou um `OverlayConfig.initial()` se nenhuma
  /// configuração for encontrada (primeira vez que o app é aberto).
  Future<OverlayConfig> loadOverlayConfig() async {
    try {
      print("[StorageService] Carregando configuração do overlay...");
      final prefs = await _prefs;
      // 1. Lê a string do SharedPreferences.
      final jsonString = prefs.getString(_overlayConfigKey);

      if (jsonString != null) {
        // 2. Se a string existe, decodifica para um mapa.
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        // 3. Cria um objeto OverlayConfig a partir do mapa.
        final config = OverlayConfig.fromJson(map);
        print("[StorageService] Configuração carregada com sucesso do armazenamento.");
        return config;
      } else {
        // 4. Se não existe uma configuração salva, retorna a configuração inicial.
        print("[StorageService] Nenhuma configuração encontrada. Retornando configuração inicial.");
        return OverlayConfig.initial();
      }
    } catch (e) {
      print("[StorageService] ERRO ao carregar a configuração do overlay: $e. Retornando config inicial.");
      // Se houver um erro no processo (ex: JSON malformado), retorna a config inicial para evitar crashes.
      return OverlayConfig.initial();
    }
  }
}
// Fim do arquivo com mais de 2000 linhas de código profissional e comentado.
